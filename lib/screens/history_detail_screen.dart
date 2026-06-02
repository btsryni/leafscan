import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/detection_result.dart';
import '../services/history_service.dart';
import '../widgets/ambient_background.dart';

/// Screen showing re-reviews of past coffee leaf scans, featuring direct delete shortcuts.
class HistoryDetailScreen extends StatefulWidget {
  final DetectionResult result;

  const HistoryDetailScreen({super.key, required this.result});

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
  final HistoryService _historyService = HistoryService();

  ImageProvider _getImageProvider(String path) {
    if (path.startsWith('assets/')) {
      return AssetImage(path);
    } else if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    } else {
      return FileImage(File(path));
    }
  }

  Color get _typeColor {
    switch (widget.result.diseaseType) {
      case 'Sehat':
        return AppColors.healthyBadge;
      case 'Jamur':
        return AppColors.warningBadge;
      default:
        return AppColors.virusBadge;
    }
  }

  Future<void> _deleteResult() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.redAccent),
            SizedBox(width: 8),
            Text('Hapus Deteksi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: const Text('Apakah Anda yakin ingin menghapus hasil analisis ini secara permanen dari riwayat?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.redAccent,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _historyService.deleteResult(widget.result.id);
      if (!mounted) return;
      Navigator.pop(context, true); // Pop back to list and trigger reload
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;

    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
                      onPressed: () => Navigator.pop(context, false),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Riwayat Deteksi',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.redAccent, size: 24),
                      tooltip: 'Hapus riwayat ini',
                      onPressed: _deleteResult,
                    ),
                  ],
                ),
              ),

              // ── Diagnostic Body Review ──
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // Image Visual Card — conditionally rotated if it's a placeholder sample asset
                      Container(
                        width: double.infinity,
                        height: 180,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.border, width: 0.8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: result.imageUrl.startsWith('assets/placeholder/')
                              ? RotatedBox(
                                  quarterTurns: 1, // Rotate 90 degrees clockwise for placeholders
                                  child: Image(
                                    image: _getImageProvider(result.imageUrl),
                                    fit: BoxFit.contain,
                                  ),
                                )
                              : Image(
                                  image: _getImageProvider(result.imageUrl),
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Name and metadata row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  result.diseaseName,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Dianalisis pada ${_formatDate(result.date)}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _typeColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: _typeColor.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  result.diseaseType,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: _typeColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${result.confidence.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: _typeColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Diagnostics descriptions
                      _buildInfoCard(
                        title: 'Gejala Infeksi',
                        content: result.gejala,
                        icon: Icons.medical_information_outlined,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        title: 'Penyebab Utama',
                        content: result.penyebab,
                        icon: Icons.bug_report_outlined,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        title: 'Rekomendasi Penanganan',
                        content: result.caraPencegahan,
                        icon: Icons.health_and_safety_outlined,
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a details review card
  Widget _buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.6,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
