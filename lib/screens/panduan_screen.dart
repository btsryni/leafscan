import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/ambient_background.dart';

/// Clean step-by-step diagnostic guide for coffee leaves.
class PanduanScreen extends StatelessWidget {
  const PanduanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = [
      (
        '1',
        'Buka Fitur Analisis',
        'Arahkan ke menu analisis yang terletak di bagian tengah bawah screen dengan ikon daun hijau.'
      ),
      (
        '2',
        'Ambil atau Pilih Foto',
        'Anda bisa langsung mengambil foto daun kopi menggunakan kamera perangkat Anda atau memilih gambar daun dari galeri foto.'
      ),
      (
        '3',
        'Ikuti Panduan Foto',
        'Pastikan foto daun kopi terlihat jelas, tidak buram, terfokus pada area bercak/terinfeksi, serta mendapatkan pencahayaan yang cukup.'
      ),
      (
        '4',
        'Proses Analisis Otomatis',
        'Sistem kecerdasan buatan (AI) kami akan secara otomatis memproses dan mencocokkan gambar daun kopi yang Anda unggah.'
      ),
      (
        '5',
        'Lihat Hasil Analisis',
        'Hasil diagnosis penyakit daun kopi akan muncul secara detail beserta tingkat akurasi kecocokan AI.'
      ),
      (
        '6',
        'Baca Rekomendasi',
        'Sistem akan memberikan rekomendasi penanganan konkret, solusi pencegahan, serta tata cara pemulihan tanaman.'
      ),
      (
        '7',
        'Simpan Hasil Deteksi (Opsional)',
        'Hasil diagnosis akan secara otomatis tersimpan ke dalam database lokal yang dapat diakses kembali melalui menu riwayat.'
      ),
    ];

    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ── Custom Header ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Panduan Analisis',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Step list ──
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  itemCount: steps.length,
                  itemBuilder: (context, index) {
                    final step = steps[index];
                    return _buildStepCard(
                      number: step.$1,
                      title: step.$2,
                      description: step.$3,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Numbered guide list card
  Widget _buildStepCard({
    required String number,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Circular number index
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Title & Detail Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.5,
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
