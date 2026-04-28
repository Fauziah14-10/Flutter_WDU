import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';

class SurveySummaryPage extends StatelessWidget {
  final String surveyTitle;
  final String projectName;
  final Duration duration;
  final DateTime completionTime;
  final double? latitude;
  final double? longitude;

  const SurveySummaryPage({
    super.key,
    required this.surveyTitle,
    required this.projectName,
    required this.duration,
    required this.completionTime,
    this.latitude,
    this.longitude,
  });

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours} Jam ${duration.inMinutes.remainder(60)} Menit';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} Menit ${duration.inSeconds.remainder(60)} Detik';
    } else {
      return '${duration.inSeconds} Detik';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Mencegah kembali ke form survey
      child: Scaffold(
        backgroundColor: AppTheme.monBgColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                // Icon Berhasil
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.monGreenPale,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppTheme.monGreenMid,
                    size: 80,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  "Survey Terkirim!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.monTextDark,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Terima kasih atas partisipasi Anda dalam pengisian kuesioner ini.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 48),
                
                // Card Ringkasan
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        icon: Icons.assignment_outlined,
                        label: "Kuesioner",
                        value: surveyTitle,
                      ),
                      const Divider(height: 32),
                      _buildInfoRow(
                        icon: Icons.calendar_today_outlined,
                        label: "Waktu Pengisian",
                        value: _formatDateTime(completionTime),
                      ),
                      const Divider(height: 32),
                      _buildInfoRow(
                        icon: Icons.timer_outlined,
                        label: "Lama Mengisi",
                        value: _formatDuration(duration),
                      ),
                      const Divider(height: 32),
                      _buildInfoRow(
                        icon: Icons.location_on_outlined,
                        label: "Lokasi (GPS)",
                        value: latitude != null && longitude != null
                            ? "$latitude, $longitude"
                            : "Tidak terdeteksi",
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                
                // Tombol Kembali
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.monGreenMid,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Kembali ke Beranda",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.monBgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.monGreenMid, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.monTextDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
