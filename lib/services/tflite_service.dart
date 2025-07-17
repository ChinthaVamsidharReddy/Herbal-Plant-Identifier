import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class TFLiteService {
  Interpreter? _interpreter;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _interpreter = await Interpreter.fromAsset('assets/herbal_model.tflite');
      _isInitialized = true;
    } catch (e) {
      print('Error initializing TFLite: $e');
      throw Exception('Failed to initialize TFLite model');
    }
  }

  Future<Map<String, dynamic>> runInference(File imageFile) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Load and preprocess the image
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Resize image to 224x224 (common input size for many models)
      final resizedImage = img.copyResize(image, width: 224, height: 224);
      
      // Convert to float array and normalize
      final input = List.generate(1, (index) => List.generate(
        224, (y) => List.generate(224, (x) {
          final pixel = resizedImage.getPixel(x, y);
          return [
            pixel.r / 255.0,
            pixel.g / 255.0,
            pixel.b / 255.0,
          ];
        }),
      ));

      // Prepare output tensor as 2D list [1, 40]
      final output = List.generate(1, (_) => List.filled(40, 0.0));

      // Run inference
      _interpreter!.run(input, output);
      final outputList = output[0]; // Get the first row

      // Find the class with highest probability and its confidence
      int maxIndex = 0;
      double maxValue = outputList[0];
      for (int i = 1; i < outputList.length; i++) {
        if (outputList[i] > maxValue) {
          maxValue = outputList[i];
          maxIndex = i;
        }
      }
      return {
        'index': maxIndex,
        'confidence': maxValue,
        'probabilities': outputList,
      };
    } catch (e) {
      print('Error during inference: $e');
      return {
        'index': 0,
        'confidence': 0.0,
        'probabilities': List.filled(40, 0.0),
      };
    }
  }

  void dispose() {
    _interpreter?.close();
    _isInitialized = false;
  }
} 