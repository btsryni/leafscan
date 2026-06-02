import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/detection_result.dart';
import '../widgets/ambient_background.dart';
import '../services/history_service.dart';

/// Screen displaying interactive circular gauge, result metrics, and penanganan solutions.
class ResultScreen extends StatefulWidget {
  final DetectionResult result;

  const ResultScreen({super.key, required this.result});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _gaugeController;
  late Animation<double> _gaugeAnimation;
  bool _isSaved = false;

  ImageProvider _getImageProvider(String path) {
    if (path.startsWith('assets/')) {
      return AssetImage(path);
    } else if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    } else {
      return FileImage(File(path));
    }
  }

  @override
  void initState() {
    super.initState();
    _gaugeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _gaugeAnimation = Tween<double>(
      begin: 0.0,
      end: widget.result.confidence / 100.0,
    ).animate(CurvedAnimation(
      parent: _gaugeController,
      curve: Curves.easeOutCubic,
    ));
    _gaugeController.forward();
    _checkIfSaved();
  }

  Future<void> _checkIfSaved() async {
    final history = await HistoryService().getHistory();
    final alreadySaved = history.any((item) => item.id == widget.result.id);
    if (mounted) {
      setState(() {
        _isSaved = alreadySaved;
      });
    }
  }

  @override
  void dispose() {
    _gaugeController.dispose();
    super.dispose();
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
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Hasil Analisis',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Diagnostic Body ──
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                      // Animated Circular Gauge Score Indicator
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: AnimatedBuilder(
                          animation: _gaugeAnimation,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: _GaugePainter(
                                progress: _gaugeAnimation.value,
                                color: _typeColor,
                              ),
                              child: Center(
                                child: Text(
                                  '${(_gaugeAnimation.value * 100).toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: _typeColor,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

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
                      const SizedBox(height: 18),

                      // Title and Bookmark Option row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  'Tingkat Kepercayaan AI: ${result.confidence.toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              _isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              color: AppColors.primary,
                              size: 28,
                            ),
                            onPressed: () async {
                              final historyService = HistoryService();
                              final messenger = ScaffoldMessenger.of(context);
                              if (_isSaved) {
                                await historyService.deleteResult(widget.result.id);
                                setState(() {
                                  _isSaved = false;
                                });
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Hasil deteksi dihapus dari favorit & riwayat!',
                                      style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
                                    ),
                                    backgroundColor: AppColors.primary,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              } else {
                                await historyService.addResult(widget.result);
                                setState(() {
                                  _isSaved = true;
                                });
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Hasil deteksi disimpan ke favorit & riwayat!',
                                      style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
                                    ),
                                    backgroundColor: AppColors.primary,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Dynamic Details accordion rows
                      _buildInfoSection(
                        title: 'Gejala Infeksi',
                        content: result.gejala,
                        icon: Icons.medical_information_outlined,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoSection(
                        title: 'Penyebab Utama',
                        content: result.penyebab,
                        icon: Icons.bug_report_outlined,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoSection(
                        title: 'Rekomendasi Penanganan',
                        content: result.caraPencegahan,
                        icon: Icons.health_and_safety_outlined,
                      ),

                      const SizedBox(height: 24),

                      // "Kembali" primary execution button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                          ),
                          child: const Text(
                            'Selesai',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
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

  /// Builds a details accordion style row card in result screen
  Widget _buildInfoSection({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
              const SizedBox(width: 8),
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
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 12,
              height: 1.5,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter representing dynamic circular score meter
class _GaugePainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final Color color;

  _GaugePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Track
    final bgPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Active
    final activePaint = Paint()
      ..color = color
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
