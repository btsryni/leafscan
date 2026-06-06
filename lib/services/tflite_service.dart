import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

enum ModelType { mobileNetV2, resNet50, xception }

class TfliteService {
  static final TfliteService _instance = TfliteService._internal();
  factory TfliteService() => _instance;
  TfliteService._internal();

  // ==========================================
  // === MULTI-MODEL BUILD CONFIGURATION SWITCHER ===
  // ==========================================
  // To build MobileNetV2 APK: set this to ModelType.mobileNetV2
  // To build ResNet50 APK: set this to ModelType.resNet50
  // To build Xception APK: set this to ModelType.xception
  static const ModelType activeModel = ModelType.resNet50;

  Interpreter? _interpreter;
  bool _isModelLoaded = false;

  // The 7 specific classes the models were trained on (alphabetically sorted)
  final List<String> _labels = [
    'Bercak Daun',
    'Daun Sehat',
    'Embun Jelaga',
    'Hawar Daun',
    'Karat Daun',
    'Penggorok Daun',
    'Tungau Laba-laba Merah',
  ];

  List<String> get labels => _labels;

  // Get current active model configuration details
  String get activeModelName => switch (activeModel) {
        ModelType.mobileNetV2 => 'MobileNetV2',
        ModelType.resNet50 => 'ResNet50',
        ModelType.xception => 'Xception',
      };

  String get activeModelFile => switch (activeModel) {
        ModelType.mobileNetV2 => 'best_MobileNetV2_Beta.tflite',
        ModelType.resNet50 => 'best_ResNet50_Beta.tflite',
        ModelType.xception => 'best_Xception_Beta.tflite',
      };

  // Initialize and load the TFLite model from assets
  Future<void> loadModel() async {
    if (_isModelLoaded) return;
    try {
      final options = InterpreterOptions()..threads = 4;
      final modelAssetPath = 'assets/tflite/$activeModelFile';
      _interpreter = await Interpreter.fromAsset(
        modelAssetPath,
        options: options,
      );
      _isModelLoaded = true;
      debugPrint("TFLite Model ($activeModelName) loaded successfully from $modelAssetPath.");
    } catch (e) {
      debugPrint("Failed to load TFLite Model ($activeModelName): $e");
    }
  }

  // Preprocess the input image and run inference based on current model type
  Future<Map<String, dynamic>> classifyImage(File imageFile) async {
    await loadModel();
    if (_interpreter == null) {
      throw Exception("TFLite interpreter is not initialized for $activeModelName.");
    }

    // 1. Decode image bytes
    final Uint8List imageBytes = await imageFile.readAsBytes();
    final img.Image? originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) {
      throw Exception("Failed to decode image bytes.");
    }

    // 2. Center crop the image to 1:1 square ratio to avoid distortion (squishing) and resize to 224x224
    final int origWidth = originalImage.width;
    final int origHeight = originalImage.height;
    final int size = origWidth < origHeight ? origWidth : origHeight;
    final int cropX = (origWidth - size) ~/ 2;
    final int cropY = (origHeight - size) ~/ 2;

    final img.Image croppedImage = img.copyCrop(
      originalImage,
      x: cropX,
      y: cropY,
      width: size,
      height: size,
    );

    final img.Image resizedImage = img.copyResize(croppedImage, width: 224, height: 224);

    // 3. Prepare Float32 input tensor: shape [1, 224, 224, 3]
    var input = List.generate(
      1,
      (_) => List.generate(
        224,
        (_) => List.generate(
          224,
          (_) => List.filled(3, 0.0),
        ),
      ),
    );

    // Apply model-specific channel ordering and preprocessing formula
    if (activeModel == ModelType.mobileNetV2 || activeModel == ModelType.xception) {
      // MobileNetV2 & Xception: RGB order with [-1.0, 1.0] scaling
      for (int y = 0; y < 224; y++) {
        for (int x = 0; x < 224; x++) {
          final pixel = resizedImage.getPixel(x, y);
          final double r = (pixel.r.toDouble() - 127.5) / 127.5;
          final double g = (pixel.g.toDouble() - 127.5) / 127.5;
          final double b = (pixel.b.toDouble() - 127.5) / 127.5;

          input[0][y][x][0] = r;
          input[0][y][x][1] = g;
          input[0][y][x][2] = b;
        }
      }
    } else {
      // ResNet50: BGR order with ImageNet mean subtraction (no division)
      // Blue mean: 103.939, Green mean: 116.779, Red mean: 123.680
      for (int y = 0; y < 224; y++) {
        for (int x = 0; x < 224; x++) {
          final pixel = resizedImage.getPixel(x, y);
          final double b = pixel.b.toDouble() - 103.939; // Blue first
          final double g = pixel.g.toDouble() - 116.779; // Green second
          final double r = pixel.r.toDouble() - 123.680; // Red third

          input[0][y][x][0] = b;
          input[0][y][x][1] = g;
          input[0][y][x][2] = r;
        }
      }
    }

    // 4. Prepare Float32 output tensor: shape [1, 7] for the 7 classes
    var output = List.generate(1, (_) => List.filled(7, 0.0));

    // 5. Run inference
    _interpreter!.run(input, output);

    // 6. Post-process: Extract class probabilities
    final List<double> probabilities = List<double>.from(output[0]);
    
    // Find class with the maximum probability score
    double maxProb = -100.0;
    int maxIndex = -1;
    for (int i = 0; i < probabilities.length; i++) {
      if (probabilities[i] > maxProb) {
        maxProb = probabilities[i];
        maxIndex = i;
      }
    }

    double confidence = maxProb;
    if (confidence < 0.0) confidence = 0.0;
    if (confidence > 1.0) confidence = 0.95;
    final double confidencePercentage = confidence * 100.0;

    final String detectedDisease = _labels[maxIndex];

    return {
      'diseaseName': detectedDisease,
      'confidence': double.parse(confidencePercentage.toStringAsFixed(1)),
      'probabilities': probabilities,
    };
  }

  // Preprocess the input asset image and run inference based on current model type
  Future<Map<String, dynamic>> classifyAsset(String assetPath) async {
    await loadModel();
    if (_interpreter == null) {
      throw Exception("TFLite interpreter is not initialized for $activeModelName.");
    }

    // 1. Load image bytes from assets using rootBundle
    final ByteData assetData = await rootBundle.load(assetPath);
    final Uint8List imageBytes = assetData.buffer.asUint8List();

    final img.Image? originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) {
      throw Exception("Failed to decode asset image bytes.");
    }

    // 2. Center crop the image to 1:1 square ratio to avoid distortion (squishing) and resize to 224x224
    final int origWidth = originalImage.width;
    final int origHeight = originalImage.height;
    final int size = origWidth < origHeight ? origWidth : origHeight;
    final int cropX = (origWidth - size) ~/ 2;
    final int cropY = (origHeight - size) ~/ 2;

    final img.Image croppedImage = img.copyCrop(
      originalImage,
      x: cropX,
      y: cropY,
      width: size,
      height: size,
    );

    final img.Image resizedImage = img.copyResize(croppedImage, width: 224, height: 224);

    // 3. Prepare Float32 input tensor: shape [1, 224, 224, 3]
    var input = List.generate(
      1,
      (_) => List.generate(
        224,
        (_) => List.generate(
          224,
          (_) => List.filled(3, 0.0),
        ),
      ),
    );

    // Apply model-specific channel ordering and preprocessing formula
    if (activeModel == ModelType.mobileNetV2 || activeModel == ModelType.xception) {
      // MobileNetV2 & Xception: RGB order with [-1.0, 1.0] scaling
      for (int y = 0; y < 224; y++) {
        for (int x = 0; x < 224; x++) {
          final pixel = resizedImage.getPixel(x, y);
          final double r = (pixel.r.toDouble() - 127.5) / 127.5;
          final double g = (pixel.g.toDouble() - 127.5) / 127.5;
          final double b = (pixel.b.toDouble() - 127.5) / 127.5;

          input[0][y][x][0] = r;
          input[0][y][x][1] = g;
          input[0][y][x][2] = b;
        }
      }
    } else {
      // ResNet50: BGR order with ImageNet mean subtraction (no division)
      for (int y = 0; y < 224; y++) {
        for (int x = 0; x < 224; x++) {
          final pixel = resizedImage.getPixel(x, y);
          final double b = pixel.b.toDouble() - 103.939; // Blue first
          final double g = pixel.g.toDouble() - 116.779; // Green second
          final double r = pixel.r.toDouble() - 123.680; // Red third

          input[0][y][x][0] = b;
          input[0][y][x][1] = g;
          input[0][y][x][2] = r;
        }
      }
    }

    // 4. Prepare Float32 output tensor: shape [1, 7] for the 7 classes
    var output = List.generate(1, (_) => List.filled(7, 0.0));

    // 5. Run inference
    _interpreter!.run(input, output);

    // 6. Post-process: Extract class probabilities
    final List<double> probabilities = List<double>.from(output[0]);
    
    double maxProb = -100.0;
    int maxIndex = -1;
    for (int i = 0; i < probabilities.length; i++) {
      if (probabilities[i] > maxProb) {
        maxProb = probabilities[i];
        maxIndex = i;
      }
    }

    double confidence = maxProb;
    if (confidence < 0.0) confidence = 0.0;
    if (confidence > 1.0) confidence = 0.95;
    final double confidencePercentage = confidence * 100.0;

    final String detectedDisease = _labels[maxIndex];

    return {
      'diseaseName': detectedDisease,
      'confidence': double.parse(confidencePercentage.toStringAsFixed(1)),
      'probabilities': probabilities,
    };
  }

  // Dispose resources when done
  void close() {
    _interpreter?.close();
    _isModelLoaded = false;
  }
}
