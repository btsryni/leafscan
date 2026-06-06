import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/detection_result.dart';
import 'panduan_screen.dart';
import 'about_screen.dart';
import 'disease_detail_screen.dart';

/// Home dashboard — greetings, banner, disease shortcuts, action items.
class HomeScreen extends StatelessWidget {
  final VoidCallback onNavigateToDeteksi;
  final VoidCallback onNavigateToRiwayat;

  const HomeScreen({
    super.key,
    required this.onNavigateToDeteksi,
    required this.onNavigateToRiwayat,
  });

  @override
  Widget build(BuildContext context) {
    final diseases = DetectionResult.staticSamples;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'LeafScan',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            color: AppColors.primary,
            letterSpacing: 0.5,
            fontFamily: 'Serif',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.error_rounded, color: AppColors.primary, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Coffee Plantation Header Banner Image (Asset halaman home) ──
              Container(
                width: double.infinity,
                height: 175,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: RotatedBox(
                    quarterTurns: 3, // Rotate 90 degrees counter-clockwise to make it horizontal landscape correctly
                    child: Image.asset(
                      'assets/placeholder/Asset halaman home.png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Subtitle Description ──
              const Text(
                'Penyakit Daun Kopi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'kenali jenis-jenis penyakit yang umum menyerang daun kopi',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),

              // ── Horizontal Rectangular Scrolling Disease Cards ──
              _buildDiseaseCardsList(context, diseases),
              const SizedBox(height: 28),

              // ── Primary Action Rows ──
              _buildMenuCard(
                icon: Icons.menu_book_rounded,
                title: 'Panduan Analisis Penyakit',
                subtitle: 'Yuk, pelajari cara deteksi daun kopi',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PanduanScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildMenuCard(
                icon: Icons.history_rounded,
                title: 'Riwayat Analisis',
                subtitle: 'Lihat semua hasil deteksi tanamanmu sebelumnya',
                onTap: onNavigateToRiwayat,
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the horizontal sliding disease cards list matching Screenshot 2
  Widget _buildDiseaseCardsList(BuildContext context, List<DetectionResult> diseases) {
    return SizedBox(
      height: 145,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: diseases.length,
        itemBuilder: (context, index) {
          final sample = diseases[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DiseaseDetailScreen(result: sample),
                ),
              );
            },
            child: Container(
              width: 165,
              margin: const EdgeInsets.only(right: 14),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Leaf image area — horizontal rectangular with rotated image
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: RotatedBox(
                          quarterTurns: 1, // Rotate 90 degrees to make it horizontal landscape
                          child: Image.asset(
                            sample.imageUrl,
                            fit: BoxFit.contain, // Fit it perfectly without cutting
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: AppColors.lightGreen,
                              child: const Icon(Icons.broken_image, color: AppColors.primary),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Label bar centered in a box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    decoration: const BoxDecoration(
                      color: AppColors.lightGreen,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      border: Border(
                        top: BorderSide(color: AppColors.border, width: 0.8),
                      ),
                    ),
                    child: Text(
                      sample.diseaseName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds the menu card triggers in Home Screen
  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.lightGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 26),
                ),
                const SizedBox(width: 16),
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
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textHint, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
