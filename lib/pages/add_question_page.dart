import 'package:flutter/material.dart';

// ── MODEL HALAMAN ──
class SurveyPage {
  String namaHalaman;
  List<String> daftarPertanyaan;
  List<TextEditingController> titleControllers;
  List<TextEditingController> questionControllers;
  List<List<TextEditingController>> optionControllers;

  SurveyPage({required this.namaHalaman})
      : daftarPertanyaan = [],
        titleControllers = [],
        questionControllers = [],
        optionControllers = [];

  void dispose() {
    for (var c in titleControllers) c.dispose();
    for (var c in questionControllers) c.dispose();
    for (var list in optionControllers) {
      for (var c in list) c.dispose();
    }
  }
}

class AddQuestionPage extends StatefulWidget {
  final String surveyId;
  final String surveyTitle;
  final String clientSlug;
  final String projectSlug;

  const AddQuestionPage({
    super.key,
    required this.surveyId,
    required this.surveyTitle,
    required this.clientSlug,
    required this.projectSlug,
  });

  @override
  State<AddQuestionPage> createState() => _AddQuestionPageState();
}

class _AddQuestionPageState extends State<AddQuestionPage> {
  // ── DAFTAR HALAMAN ──
  late List<SurveyPage> pages;
  int currentPageIndex = 0;

  // ── QUESTIONS ──
  final List<Map<String, dynamic>> daftarTipe = [
    {"judul": "Text",           "icon": Icons.text_fields},
    {"judul": "Single Choice",  "icon": Icons.radio_button_checked},
    {"judul": "Multiple Choice","icon": Icons.check_box},
    {"judul": "Number Scale",   "icon": Icons.pin},
    {"judul": "Dropdown",       "icon": Icons.arrow_drop_down_circle},
    {"judul": "Cellphone",      "icon": Icons.smartphone},
    {"judul": "Matrix Choice",  "icon": Icons.grid_view},
    {"judul": "Document",       "icon": Icons.insert_drive_file},
  ];

  // ── DESCRIPTIONS ──
  final List<Map<String, dynamic>> daftarDeskripsi = [
    {"judul": "Image",     "icon": Icons.image},
    {"judul": "Paragraph", "icon": Icons.format_align_left},
  ];

  bool _hasOptions(String tipe) =>
      ["Single Choice", "Multiple Choice", "Dropdown"].contains(tipe);

  @override
  void initState() {
    super.initState();
    pages = [SurveyPage(namaHalaman: "Halaman 1")];
  }

  @override
  void dispose() {
    for (var p in pages) p.dispose();
    super.dispose();
  }

  // ── TAMBAH HALAMAN BARU ──
  void _addPage() {
    setState(() {
      pages.add(SurveyPage(namaHalaman: "Halaman ${pages.length + 1}"));
      currentPageIndex = pages.length - 1;
    });
  }

  // ── HAPUS HALAMAN ──
  void _deletePage(int index) {
    if (pages.length == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Minimal harus ada 1 halaman")),
      );
      return;
    }
    setState(() {
      pages[index].dispose();
      pages.removeAt(index);
      if (currentPageIndex >= pages.length) {
        currentPageIndex = pages.length - 1;
      }
    });
  }

  SurveyPage get currentPage => pages[currentPageIndex];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    return isMobile
        ? _buildMobileLayout()
        : const Scaffold(body: Center(child: Text("Desktop Layout")));
  }

  // ── GRID ITEM WIDGET ──
  Widget _buildDraggableItem(Map<String, dynamic> item) {
    return Draggable<String>(
      data: item["judul"],
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item["icon"], color: Colors.white, size: 28),
              const SizedBox(height: 4),
              Text(item["judul"],
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item["icon"], color: Colors.green, size: 26),
            const SizedBox(height: 4),
            Text(
              item["judul"],
              style: const TextStyle(
                  fontSize: 10,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── PREVIEW per TIPE ──
  Widget _buildPreview(String tipe, int index) {
    final page = currentPage;

    if (tipe == "Cellphone") {
      return TextField(
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          hintText: "08xxxxx",
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon:
              const Icon(Icons.smartphone, color: Colors.grey, size: 18),
          enabledBorder:
              const UnderlineInputBorder(borderSide: BorderSide(color: Colors.green)),
          focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.green, width: 2)),
        ),
      );
    }

    if (tipe == "Number Scale") {
      return Row(
        children: List.generate(
          5,
          (i) => Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 36,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text("${i + 1}",
                    style:
                        const TextStyle(color: Colors.green, fontSize: 13)),
              ),
            ),
          ),
        ),
      );
    }

    if (tipe == "Text") {
      return TextField(
        decoration: InputDecoration(
          hintText: "Short answer text",
          hintStyle: TextStyle(color: Colors.grey.shade400),
          enabledBorder:
              const UnderlineInputBorder(borderSide: BorderSide(color: Colors.green)),
          focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.green, width: 2)),
        ),
      );
    }

    if (tipe == "Document") {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Row(
          children: [
            Icon(Icons.upload_file, color: Colors.green),
            SizedBox(width: 8),
            Text("Upload dokumen", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (tipe == "Image") {
      return Container(
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(6),
          color: Colors.grey.shade50,
        ),
        child: const Center(
          child: Icon(Icons.add_photo_alternate_outlined,
              color: Colors.green, size: 32),
        ),
      );
    }

    if (tipe == "Paragraph") {
      return TextField(
        maxLines: 3,
        decoration: InputDecoration(
          hintText: "Tulis paragraf di sini...",
          hintStyle: TextStyle(color: Colors.grey.shade400),
          border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.green)),
        ),
      );
    }

    if (_hasOptions(tipe)) {
      final opts = page.optionControllers[index];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...opts.asMap().entries.map((entry) {
            final i = entry.key;
            final ctrl = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    tipe == "Multiple Choice"
                        ? Icons.check_box_outline_blank
                        : tipe == "Dropdown"
                            ? Icons.circle
                            : Icons.radio_button_unchecked,
                    color: Colors.grey,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: ctrl,
                      decoration: InputDecoration(
                        hintText: "Option text",
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.green)),
                        focusedBorder: const UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.green, width: 2)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child:
                        const Text("Quest", style: TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        page.optionControllers[index].removeAt(i);
                      });
                    },
                    child:
                        const Icon(Icons.close, size: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              setState(() {
                page.optionControllers[index].add(TextEditingController());
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
            ),
            child: const Text("Add Options",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      );
    }

    if (tipe == "Matrix Choice") {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text("Matrix rows & columns di sini...",
            style: TextStyle(fontSize: 12, color: Colors.grey)),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildMobileLayout() {
    final page = currentPage;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text("Tambah Pertanyaan - ${widget.surveyTitle}"),
        backgroundColor: Colors.green,
      ),
      body: Row(
        children: [

          // ================= LEFT COLUMN =================
          Container(
            width: 150,
            color: Colors.white,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // ── QUESTIONS GRID ──
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(10),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 0.9,
                          ),
                          itemCount: daftarTipe.length,
                          itemBuilder: (context, index) =>
                              _buildDraggableItem(daftarTipe[index]),
                        ),

                        // ── DESCRIPTIONS HEADER ──
                        Container(
                          width: double.infinity,
                          color: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: const Text(
                            "DESCRIPTIONS",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          ),
                        ),

                        // ── DESCRIPTIONS GRID ──
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(10),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 0.9,
                          ),
                          itemCount: daftarDeskripsi.length,
                          itemBuilder: (context, index) =>
                              _buildDraggableItem(daftarDeskripsi[index]),
                        ),

                        // ── DIVIDER ──
                        Divider(color: Colors.grey.shade300, height: 1),

                        // ── DAFTAR HALAMAN ──
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "HALAMAN",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),

                        ...pages.asMap().entries.map((entry) {
                          final i = entry.key;
                          final p = entry.value;
                          final isActive = i == currentPageIndex;
                          return GestureDetector(
                            onTap: () {
                              setState(() => currentPageIndex = i);
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? Colors.green.shade50
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isActive
                                      ? Colors.green
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.description_outlined,
                                    size: 14,
                                    color: isActive
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      p.namaHalaman,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: isActive
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isActive
                                            ? Colors.green
                                            : Colors.black87,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  // Hapus halaman
                                  if (pages.length > 1)
                                    GestureDetector(
                                      onTap: () => _deletePage(i),
                                      child: Icon(Icons.close,
                                          size: 14,
                                          color: Colors.grey.shade500),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }),

                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),

                // ── ADD PAGE BUTTON ──
                InkWell(
                  onTap: _addPage,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                          top: BorderSide(color: Colors.grey.shade300)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.add_box_outlined,
                                size: 18, color: Colors.green),
                            SizedBox(width: 6),
                            Text(
                              "Add Page",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        Icon(Icons.chevron_right,
                            size: 18, color: Colors.green),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ================= CENTER COLUMN =================
          Expanded(
            child: Column(
              children: [
                // ── HEADER HALAMAN AKTIF ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  color: Colors.green.shade50,
                  child: Row(
                    children: [
                      const Icon(Icons.description_outlined,
                          color: Colors.green, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        page.namaHalaman,
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "(${page.daftarPertanyaan.length} pertanyaan)",
                        style: TextStyle(
                            color: Colors.green.shade400, fontSize: 12),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: DragTarget<String>(
                    onAcceptWithDetails: (details) {
                      setState(() {
                        page.daftarPertanyaan.add(details.data);
                        page.titleControllers
                            .add(TextEditingController(text: "title"));
                        page.questionControllers
                            .add(TextEditingController());
                        if (_hasOptions(details.data)) {
                          page.optionControllers
                              .add([TextEditingController()]);
                        } else {
                          page.optionControllers.add([]);
                        }
                      });
                    },
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: candidateData.isNotEmpty
                                ? Colors.green
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: page.daftarPertanyaan.isEmpty
                            ? const Center(
                                child: Text(
                                  "Drag tipe pertanyaan ke sini",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                itemCount: page.daftarPertanyaan.length,
                                itemBuilder: (context, index) {
                                  final tipe =
                                      page.daftarPertanyaan[index];
                                  return Card(
                                    margin: const EdgeInsets.only(
                                        bottom: 12),
                                    elevation: 1,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [

                                          // ── TITLE FIELD ──
                                          Row(
                                            children: [
                                              Expanded(
                                                child: TextField(
                                                  controller: page
                                                      .titleControllers[index],
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.w500,
                                                  ),
                                                  decoration:
                                                      const InputDecoration(
                                                    border: InputBorder.none,
                                                    enabledBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.green,
                                                          width: 1.5),
                                                    ),
                                                    focusedBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.green,
                                                          width: 2),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              PopupMenuButton<String>(
                                                icon: const Icon(
                                                    Icons.more_vert),
                                                onSelected: (value) {
                                                  if (value == "delete") {
                                                    setState(() {
                                                      page.daftarPertanyaan
                                                          .removeAt(index);
                                                      page.titleControllers
                                                          .removeAt(index);
                                                      page.questionControllers
                                                          .removeAt(index);
                                                      page.optionControllers
                                                          .removeAt(index);
                                                    });
                                                  } else if (value ==
                                                      "duplicate") {
                                                    setState(() {
                                                      page.daftarPertanyaan
                                                          .insert(index + 1,
                                                              tipe);
                                                      page.titleControllers
                                                          .insert(
                                                        index + 1,
                                                        TextEditingController(
                                                            text: page
                                                                .titleControllers[
                                                                    index]
                                                                .text),
                                                      );
                                                      page.questionControllers
                                                          .insert(
                                                        index + 1,
                                                        TextEditingController(
                                                            text: page
                                                                .questionControllers[
                                                                    index]
                                                                .text),
                                                      );
                                                      page.optionControllers
                                                          .insert(
                                                        index + 1,
                                                        page.optionControllers[
                                                                index]
                                                            .map((c) =>
                                                                TextEditingController(
                                                                    text: c
                                                                        .text))
                                                            .toList(),
                                                      );
                                                    });
                                                  } else if (value ==
                                                      "make_optional") {
                                                    // TODO: logika opsional
                                                  } else if (value
                                                      .startsWith("type_")) {
                                                    final newType = value
                                                        .replaceFirst(
                                                            "type_", "");
                                                    setState(() {
                                                      page.daftarPertanyaan[
                                                              index] =
                                                          newType;
                                                      for (var c in page
                                                          .optionControllers[
                                                              index]) {
                                                        c.dispose();
                                                      }
                                                      page.optionControllers[
                                                              index] =
                                                          _hasOptions(newType)
                                                              ? [
                                                                  TextEditingController()
                                                                ]
                                                              : [];
                                                    });
                                                  }
                                                },
                                                itemBuilder: (context) => [
                                                  const PopupMenuItem<
                                                      String>(
                                                    enabled: false,
                                                    height: 32,
                                                    child: Text(
                                                      "CHANGE TYPE",
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.grey,
                                                        letterSpacing: 1,
                                                      ),
                                                    ),
                                                  ),
                                                  ...daftarTipe.map((t) =>
                                                      PopupMenuItem<String>(
                                                        value:
                                                            "type_${t['judul']}",
                                                        height: 36,
                                                        child: Row(
                                                          children: [
                                                            Icon(t['icon'],
                                                                size: 16,
                                                                color: Colors
                                                                    .green),
                                                            const SizedBox(
                                                                width: 8),
                                                            Text(t['judul']),
                                                          ],
                                                        ),
                                                      )),
                                                  const PopupMenuDivider(),
                                                  const PopupMenuItem<
                                                      String>(
                                                    value: "make_optional",
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                            Icons
                                                                .check_box_outline_blank,
                                                            size: 18),
                                                        SizedBox(width: 8),
                                                        Text("Make Optional"),
                                                      ],
                                                    ),
                                                  ),
                                                  const PopupMenuItem<
                                                      String>(
                                                    value: "duplicate",
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.copy,
                                                            size: 18),
                                                        SizedBox(width: 8),
                                                        Text("Duplicate"),
                                                      ],
                                                    ),
                                                  ),
                                                  const PopupMenuDivider(),
                                                  const PopupMenuItem<
                                                      String>(
                                                    value: "delete",
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                            Icons
                                                                .delete_outline,
                                                            size: 18,
                                                            color: Colors.red),
                                                        SizedBox(width: 8),
                                                        Text("Delete",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .red)),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 12),

                                          // ── QUESTION FIELD ──
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                  Icons.drag_indicator,
                                                  color: Colors.grey),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: TextField(
                                                  controller: page
                                                      .questionControllers[
                                                          index],
                                                  decoration: InputDecoration(
                                                    hintText:
                                                        "Insert question here",
                                                    hintStyle: TextStyle(
                                                      color: Colors
                                                          .grey.shade400,
                                                      fontStyle:
                                                          FontStyle.italic,
                                                    ),
                                                    enabledBorder:
                                                        const UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.green),
                                                    ),
                                                    focusedBorder:
                                                        const UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.green,
                                                          width: 2),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 10),

                                          // ── BADGE REQUIRED ──
                                          Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                  color:
                                                      Colors.red.shade200),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.error,
                                                    color:
                                                        Colors.red.shade400,
                                                    size: 14),
                                                const SizedBox(width: 4),
                                                Text(
                                                  "Required",
                                                  style: TextStyle(
                                                    color:
                                                        Colors.red.shade400,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          const SizedBox(height: 12),

                                          // ── PREVIEW per TIPE ──
                                          _buildPreview(tipe, index),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      );
                    },
                  ),
                ),

                // ── SAVE BUTTON ──
                Container(
                  padding: const EdgeInsets.all(12),
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Survey berhasil disimpan"),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(double.infinity, 45),
                    ),
                    child: const Text(
                      "SIMPAN SURVEY",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}