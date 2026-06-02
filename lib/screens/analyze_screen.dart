import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_colors.dart';
import '../models/detection_result.dart';
import '../services/tflite_service.dart';
import 'result_screen.dart';

/// Screen for taking leaf photos or selecting files, featuring real TFLite neural-net analysis.
class AnalyzeScreen extends StatefulWidget {
  final VoidCallback onScanCompleted;

  const AnalyzeScreen({super.key, required this.onScanCompleted});

  @override
  State<AnalyzeScreen> createState() => _AnalyzeScreenState();
}

class _AnalyzeScreenState extends State<AnalyzeScreen>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();

  XFile? _pickedFile;
  DetectionResult? _selectedSample;
  bool _isAnalyzing = false;
  String _scanningStatus = 'Mengunggah gambar...';
  late AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  /// Helper to render image from various sources (asset, file, or network)
  Widget _buildImage(String path, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Container(
          width: width,
          height: height,
          color: AppColors.lightGreen,
          child: const Icon(Icons.broken_image_rounded, color: AppColors.primary),
        ),
      );
    } else if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Container(
          width: width,
          height: height,
          color: AppColors.lightGreen,
          child: const Icon(Icons.broken_image_rounded, color: AppColors.primary),
        ),
      );
    } else {
      return Image.file(
        File(path),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Container(
          width: width,
          height: height,
          color: AppColors.lightGreen,
          child: const Icon(Icons.broken_image_rounded, color: AppColors.primary),
        ),
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _pickedFile = image;
          _selectedSample = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal mengakses media: $e',
            style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.darkGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _showSamplePicker() {
    final samples = DetectionResult.staticSamples;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Pilih dari contoh penyakit',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: samples.length,
            itemBuilder: (context, index) {
              final sample = samples[index];
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedSample = sample;
                    _pickedFile = null;
                  });
                  Navigator.pop(ctx);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.lightGreen,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: RotatedBox(
                          quarterTurns: 1, // Rotate 90 degrees to display horizontally without crop
                          child: _buildImage(
                            sample.imageUrl,
                            width: 36, // Swaps constraints: displays as width 55, height 36 on screen
                            height: 55,
                            fit: BoxFit.contain, // Fit perfectly, never crop the leaf
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sample.diseaseName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                            ),
                            Text(
                              sample.diseaseType,
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.primary),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _startRealAnalysis() async {
    if (_pickedFile == null && _selectedSample == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Silakan pilih foto daun terlebih dahulu!',
            style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _scanningStatus = 'Membaca gambar daun...';
    });
    _radarController.repeat();

    try {
      // Premium Multi-Stage Scan UX delays
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      setState(() => _scanningStatus = 'AI menganalisis struktur klorofil...');

      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      setState(() => _scanningStatus = 'Mengekstraksi fitur bercak patogen...');

      // Execute real neural-net inference
      final Map<String, dynamic> inferenceResult;
      if (_selectedSample != null) {
        inferenceResult = await TfliteService().classifyAsset(_selectedSample!.imageUrl);
      } else {
        inferenceResult = await TfliteService().classifyImage(File(_pickedFile!.path));
      }

      final String detectedLabel = inferenceResult['diseaseName'] as String;
      final double confidence = inferenceResult['confidence'] as double;
      final String imagePath = _selectedSample != null ? _selectedSample!.imageUrl : _pickedFile!.path;

      // Construct a valid result object
      final DetectionResult finalResult = DetectionResult.fromClassification(
        detectedLabel: detectedLabel,
        confidence: confidence,
        customImagePath: imagePath,
        isLocalFile: _selectedSample == null,
      );

      setState(() {
        _isAnalyzing = false;
      });
      _radarController.stop();

      if (!mounted) return;
      // Navigate to detailed diagnosis page
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(result: finalResult),
        ),
      );

      widget.onScanCompleted();
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
      _radarController.stop();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menganalisis gambar: $e',
            style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analisis Penyakit'),
      ),
      body: Stack(
        children: [
          // ── Dashboard content ──
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Camera Visual Picker Frame
                  _buildPickerFrame(),
                  const SizedBox(height: 20),

                  // Button actions
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt_rounded, size: 18),
                          label: const Text('Kamera'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library_rounded, size: 18),
                          label: const Text('Galeri'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Demo Sample Trigger
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _showSamplePicker,
                      icon: const Icon(Icons.science_rounded, size: 18),
                      label: const Text('Pilih dari contoh penyakit'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary, width: 1.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Photo Guidelines Checklist Card
                  _buildGuideCard(),

                  const SizedBox(height: 28),

                  // "Analisis Penyakit" Trigger Button
                  if (_pickedFile != null || _selectedSample != null)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _startRealAnalysis,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentGreen,
                          foregroundColor: AppColors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        child: const Text(
                          'Analisis Penyakit',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 110),
                ],
              ),
            ),
          ),

          // ── Glowing Radar AI Scanner Loader Overlay ──
          if (_isAnalyzing) _buildScanningOverlay(),
        ],
      ),
    );
  }

  /// Dashed visual frame representing camera snapshot target area
  Widget _buildPickerFrame() {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 2.0,
          style: BorderStyle.solid, // Uses premium solid border with rounded curves
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: _pickedFile != null
            ? _buildImage(_pickedFile!.path)
            : _selectedSample != null
                ? RotatedBox(
                    quarterTurns: 1, // Rotate 90 degrees clockwise for placeholders
                    child: _buildImage(_selectedSample!.imageUrl, fit: BoxFit.contain),
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_search_rounded, size: 54, color: AppColors.primary),
                      SizedBox(height: 12),
                      Text(
                        'Belum ada gambar',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Silakan pilih gambar di bawah',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  /// Photo capture guideline row checklists
  Widget _buildGuideCard() {
    final guidelines = [
      'Gunakan pencahayaan yang cukup',
      'Ambil foto dekat dan detail agar daun terlihat jelas',
      'Hindari gambar yang buram atau gelap',
      'Fokus pada area yang terinfeksi bercak',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
          const Text(
            'Panduan Pengambilan Gambar',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: guidelines.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      color: AppColors.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Premium organic radar AI overlay with L-shaped brackets
  Widget _buildScanningOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.75),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Center target bracket
              Stack(
                alignment: Alignment.center,
                children: [
                  // Symmetrical outwards L-shaped focus brackets
                  SizedBox(
                    width: 240,
                    height: 240,
                    child: CustomPaint(
                      painter: _BracketPainter(),
                    ),
                  ),

                  // Oscillating radar scanning line
                  AnimatedBuilder(
                    animation: _radarController,
                    builder: (context, child) {
                      final val = _radarController.value;
                      return Positioned(
                        top: 240 * val,
                        left: 10,
                        right: 10,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                AppColors.primary.withValues(alpha: 0.8),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // Render cropped crop thumbnail inside scanning target
                  SizedBox(
                    width: 220,
                    height: 220,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _pickedFile != null
                          ? _buildImage(_pickedFile!.path)
                          : RotatedBox(
                              quarterTurns: 1, // Rotate 90 degrees clockwise for placeholders
                              child: _buildImage(_selectedSample!.imageUrl, fit: BoxFit.contain),
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),

              // Animated loading radar indicator
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              const SizedBox(height: 16),

              // Status description text
              Text(
                _scanningStatus,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Harap tunggu sebentar...',
                style: TextStyle(
                  color: Color(0xFFCBD5E1),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Draws outwards L-shaped green corner focus coordinates
class _BracketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const armLength = 24.0;

    // Top Left Bracket
    canvas.drawLine(const Offset(0, 0), const Offset(armLength, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, armLength), paint);

    // Top Right Bracket
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - armLength, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, armLength), paint);

    // Bottom Left Bracket
    canvas.drawLine(Offset(0, size.height), Offset(armLength, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - armLength), paint);

    // Bottom Right Bracket
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - armLength, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - armLength), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
