x# Offline Mode Documentation - WDU-Flutter (CAPI)

## Overview

Dokument ini menjelaskan desain offline mode untuk WDU-Flutter agar dapat digunakan sebagai Computer Assisted Personal Interviewing (CAPI) yang dapat menangani offline filling.

## 1. Use Cases Utama

| # | Use Case | Trigger | Ação |
|---|----------|---------|------|
| UC-01 | **Initial Sync** | Login berhasil | Download survey definitions terbaru |
| UC-02 | **View Offline Survey** | Buka survey list tanpa koneksi | Tampilkan dari local cache |
| UC-03 | **Fill Survey Offline** | User isi form survey tanpa koneksi | Simpan jawaban ke local |
| UC-04 | **Auto Sync** | Koneksi kembali tersedia | Kirim pending submissions |
| UC-05 | **Manual Sync** | User tekan tombol "Kirim Data" | Force submit semua pending |
| UC-06 | **Force Refresh** | User tekan tombol "Refresh Survey" | Fetch survey terbaru dari server |
| UC-07 | **Conflict Detection** | Submit / Sync | Deteksi versi tidak cocok |
| UC-08 | **Retry Failed** | Submit gagal | Retry dengan exponential backoff |

---

## 2. Arsitektur Data Offline

```
┌─────────────────────────────────────────────────────────────┐
│                    LOCAL STORAGE (Hive)                    │
├──────────────────┬──────────────────┬───────────────────────┤
│    survey_cache │   answer_offline │     sync_queue        │
│  (survey def)   │  (draft answers) │  (pending submissions)│
├──────────────────┼──────────────────┼───────────────────────┤
│ • questions     │ • respondent_id  │ • survey_id          │
│ • options       │ • answers       │ • respondent_id      │
│ • skip_logic    │ • status        │ • answers            │
│ • conditions    │ • updated_at    │ • created_at         │
│ • survey_id     │ • is_dirty       │ • retry_count        │
│ • version       │                 │ • status             │
└──────────────────┴──────────────────┴───────────────────────┘
```

### Sync Strategy

**A. Auto Sync:**
- Listen network connectivity (connectivity_plus)
- Saat online → otomatis proses `sync_queue`
- Jika survey definition berubah (version check) → auto fetch latest

**B. Manual Sync (Tombol):**
- Force sync semua pending
- Force refresh survey definitions
- Handle error individual (bukan semua gagal)

**C. Conflict Resolution:**
- Cek `version` survey dari server
- Jika server version > local → fetch terbaru, notify user
- Untuk submit: jika conflict, flag untuk review manual

---

## 3. Alur Kerja Utama

### UC-01: Initial Sync (Login → Download Survey)

```
┌─────────────┐     ┌──────────────────┐     ┌─────────────────┐
│   Login     │────>│  Auth Success    │────>│  Fetch Surveys  │
└─────────────┘     │  (Simpan token)  │     │  Definitions   │
                   └──────────────────┘     └────────┬────────┘
                                                    │
                          ┌──────────────────────────┘
                          ▼
                   ┌────────────────┐      ┌─────────────────┐
                   │  Save to Hive  │────> │  Show Survey    │
                   │  survey_cache  │      │  List           │
                   └────────────────┘      └─────────────────┘
```

### UC-02: View Offline Survey (Tanpa Koneksi)

```
┌─────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  App Start  │────>│  Check Internet  │────>│   No Connection │
└─────────────┘     └────────┬─────────┘     └────────┬────────┘
                              │                         │
                              │ Yes                     ▼
                              └────────────────────────►┌────────────────┐
                            ┌──────────────────┐        │ Load dari Hive │
                            │  Fetch from API  │        │ survey_cache   │
                            └────────┬────────┘        └────────────────┘
                                      │                         │
                                      ▼                         ▼
                            ┌────────────────┐        ┌────────────────┐
                            │  Update Cache  │        │  Show Survey   │
                            │  & Show List   │        │  List (Offline)│
                            └────────────────┘        └────────────────┘
```

### UC-03: Fill Survey Offline

```
┌─────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  Open       │────>│  Load Survey     │────>│  Show Form      │
│  Survey     │     │  Questions      │     │  (from cache)   │
└─────────────┘     └──────────────────┘     └────────┬────────┘
                                                      │
                                    ┌───────────────┘
                                    ▼
                         ┌────────────────────┐
                         │  User Input Answer │
                         └──────────┬─────────┘
                                    │
                                    ▼
                         ┌────────────────────┐     ┌─────────────────┐
                         │  Save to Hive      │────>│  Set status:    │
                         │  answer_offline   │     │  PENDING        │
                         └────────────────────┘     └─────────────────┘
```

### UC-04: Auto Sync (当 Koneksi Kembali)

```
┌─────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  Network    │─���─��>│  OnConnectivity   │────>│  Get All        │
│  Available │     │  Changed (Online) │     │  PENDING items  │
└─────────────┘     └──────────────────┘     └────────┬────────┘
                                                      │
                         ┌─────────────────────────────┘
                         ▼
                   ┌────────────┐     ┌─────────────────┐
                   │  Submit    │────>│  Success?       │
                   │  to API    │     │                 │
                   └─────┬──────┘     └────────┬────────┘
                         │                      ├──────────┐ No
                         │ Yes                  │         │
                         ▼              ┌───────▼──────┐
                   ┌────────────┐     │  Increment    │
                   │  Update    │     │  retry_count  │
                   │  Status    │     │  Max 3x?      │
                   │  DONE     │     │  → FAILED     │
                   └───────────┘     └────────────────┘
```

### UC-05: Manual Sync (Tombol "Kirim Data")

```
┌─────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  User Klik   │────>│  Show Progress    │────>│  Loop Submit    │
│  "Kirim"    │     │  Dialog          │     │  All PENDING    │
└─────────────┘     └──────────────────┘     └────────┬────────┘
                                                      │
                                    ┌───────────────┘
                                    ▼
                         ┌────────────────────┐
                         │  Submit Each       │
                         │  One by One        │
                         └──────────┬─────────┘
                                    │
                    ┌──────────────┼──────────────┐
                    ▼              ▼              ▼
               ┌─────────┐   ┌───────────┐   ┌───────────┐
               │ Success│   │ Retry     │   │ Failed    │
               │ → DONE │   │ → PENDING │   │ → FAILED  │
               └─────────┘   └───────────┘   └───────────┘
                    │              │              │
                    └──────────────┴──────────────┘
                                    │
                                    ▼
                         ┌────────────────────┐
                         │  Show Result      │
                         │  Summary         │
                         └────────────────────┘
```

### UC-06: Force Refresh (Tombol "Perbarui Data")

```
┌─────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  User Klik  │────>│  Fetch Survey    │────>│  Compare        │
│  "Refresh" │     │  Definitions     │     │  Version        │
└─────────────┘     └────────┬─────────┘     └────────┬────────┘
                              │                      │
            ┌─────────────────┼──────────────────────┤
            │                 │                      │
            ▼                 ▼                      ▼
     ┌─────────────┐   ┌─────────────┐         ┌─────────────┐
     │ No Change  │   │ Has Changes│         │ Has Error  │
     │ → Use Cache│   │ → Update   │         │ → Show Error│
     └─────────────┘   │ Cache      │         └─────────────┘
                       │ Notify User│
                       └─────────────┘
```

---

## 4. Data Models untuk Offline Storage

### Hive Box: survey_cache

```dart
class SurveyCache {
  int surveyId;
  String title;
  String slug;
  List<QuestionCache> questions;
  String status;
  DateTime lastUpdated;
  int version; // Untuk conflict detection
}
```

### Hive Box: answer_offline

```dart
class AnswerOffline {
  int surveyId;
  String respondentId; // UUID atau timestamp
  int enumeratorId;
  Map<String, dynamic> answers; // question_id -> value
  String status; // DRAFT, PENDING, SYNCED, FAILED
  DateTime createdAt;
  DateTime updatedAt;
  bool isDirty; // Perlu sync
}
```

### Hive Box: sync_queue

```dart
class SyncQueueItem {
  int id; // Auto increment
  int surveyId;
  String respondentId;
  Map<String, dynamic> answers;
  String status; // PENDING, IN_PROGRESS, DONE, FAILED
  DateTime createdAt;
  int retryCount;
  String? errorMessage;
}
```

---

## 5. Key Implementation Points

### 5.1 Initial Sync Flow
1. User login → dapat auth token
2. Fetch survey definitions dari API
3. Parse & simpan ke Hive `survey_cache`
4. Load survey list dari local

### 5.2 Offline Answering Flow
1. Load survey dari Hive cache
2. User isi form
3. Simpan ke `answer_offline` dengan status DRAFT
4. Tampilkan indikator "Belum Terkirim"

### 5.3 Sync Queue Flow
1. connectivity_plus detect online
2. Get all PENDING items dari sync_queue
3. Submit ke Laravel API one-by-one
4. Update status: DONE/SYNCED atau FAILED
5. Show notification hasil sync

### 5.4 Multi-Respondent Handling
- `respondent_id` adalah unique identifier per submission
- Satu enumerator bisa isi banyak respondent
- Satu survey bisa isi lebih dari 1 respondent

---

## 6. API Endpoints yang Diperlukan

### 6.1 Untuk Sync Survey Definitions
```
GET /api/clients/{clientSlug}/projects/{projectSlug}/surveys
GET /api/clients/{clientSlug}/projects/{projectSlug}/surveys/{surveySlug}
```

### 6.2 Untuk Submit Answers
```
POST /api/submissions
Body: {
  survey_id: int,
  respondent_id: string,
  enumerator_id: int,
  answers: Map<String, dynamic>,
  device_info: {...}
}
```

---

## 7. Dependencies yang Diperlukan

```yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  connectivity_plus: ^6.0.0
  uuid: ^4.0.0
  path_provider: ^2.1.0
```

---

## 8. Error Handling

| Scenario | Handling |
|----------|----------|
| Submit gagal (network error) | Simpan ke queue, retry otomatis saat online |
| Submit gagal (validation error) | Tampilkan error, biarkan user edit |
| Survey version conflict | Notify user, force refresh |
| Local data corrupted | Clear cache, re-download |
| Max retry exceeded | Mark FAILED, tampilkan manual retry button |