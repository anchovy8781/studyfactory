import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectionResult {
  const FaceDetectionResult({
    required this.faceDetected,
    this.eyesOpen,
    this.lookingAtCamera,
    this.drowsy,
  });

  final bool faceDetected;
  final bool? eyesOpen;
  final bool? lookingAtCamera;
  final bool? drowsy;

  double get focusScore {
    if (!faceDetected) return 40.0;
    double score = 70.0;
    if (lookingAtCamera == true) score += 20.0;
    if (eyesOpen == true) score += 10.0;
    if (drowsy == true) score -= 20.0;
    return score.clamp(0.0, 100.0);
  }
}

class FaceDetectionService {
  FaceDetectionService()
      : _detector = FaceDetector(
          options: FaceDetectorOptions(
            enableClassification: true,
            performanceMode: FaceDetectorMode.accurate,
          ),
        );

  final FaceDetector _detector;

  Future<FaceDetectionResult?> analyzeFromFile(String filePath) async {
    try {
      final inputImage = InputImage.fromFile(File(filePath));
      final faces = await _detector.processImage(inputImage);

      if (faces.isEmpty) {
        return const FaceDetectionResult(faceDetected: false);
      }

      final face = faces.first;
      final leftEye = face.leftEyeOpenProbability ?? 1.0;
      final rightEye = face.rightEyeOpenProbability ?? 1.0;
      final avgEye = (leftEye + rightEye) / 2;
      final yaw = (face.headEulerAngleY ?? 0).abs();
      final pitch = (face.headEulerAngleX ?? 0).abs();

      return FaceDetectionResult(
        faceDetected: true,
        eyesOpen: avgEye > 0.5,
        drowsy: avgEye < 0.3,
        lookingAtCamera: yaw < 25 && pitch < 20,
      );
    } catch (e) {
      debugPrint('[FaceDetection] $e');
      return null;
    }
  }

  void dispose() => _detector.close();
}
