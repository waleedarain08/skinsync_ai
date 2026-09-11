import 'dart:io';

import 'package:face_detection_tflite/face_detection_tflite.dart';
import 'package:flutter/material.dart';

/// Holds the detection result when user taps on a facial area
class FaceAreaResult {
  final String mainArea; // e.g. "Eyes", "Cheeks", "Lips", "Nose", "Forehead", "Chin", "Jawline", "Temple", "Eyebrow", "Under Eye"
  final String detailArea; // e.g. "Left Eye", "Right Cheek", "Upper Lip", "Nose Tip", etc.
  final Offset tapPosition; // Local tap position on widget
  final double normX; // Normalized X on original image [0..1]
  final double normY; // Normalized Y on original image [0..1]
  final double relX; // Relative X within face bounding box [0..1]
  final double relY; // Relative Y within face bounding box [0..1]
  final bool isInsideFace;

  FaceAreaResult({
    required this.mainArea,
    required this.detailArea,
    required this.tapPosition,
    required this.normX,
    required this.normY,
    required this.relX,
    required this.relY,
    this.isInsideFace = true,
  });

  String get displayName => detailArea.isNotEmpty ? detailArea : mainArea;
}

class FaceAreaDetectorUtil {
  static FaceDetector? _detector;
  static final Map<String, Face?> _faceCache = {};

  /// Ensures detector instance is ready
  static Future<void> _ensureDetectorInitialized() async {
    if (_detector != null) return;
    try {
      _detector = await FaceDetector.create(
        minScore: 0.30,
        minFaceSize: 0.05,
      );
    } catch (e) {
      debugPrint('FaceAreaDetectorUtil init error: $e');
    }
  }

  /// Detect face area from a tap on the face image
  static Future<FaceAreaResult> detectAreaFromTap({
    required String imagePath,
    required Offset tapPosition,
    required Size widgetSize,
    required String pose, // 'front', 'left', 'right'
  }) async {
    // 1. Get original image resolution
    Size imageSize = await _getImageSize(imagePath);
    if (imageSize.width == 0 || imageSize.height == 0) {
      imageSize = const Size(1080, 1920); // Standard camera portrait fallback
    }

    // 2. Map widget tap position (BoxFit.cover) to normalized image position [0..1]
    final normCoords = _widgetToNormalizedImageCoords(
      tapPosition: tapPosition,
      widgetSize: widgetSize,
      imageSize: imageSize,
    );
    final normX = normCoords.dx;
    final normY = normCoords.dy;

    // 3. Try to get cached Face detection or run detector on file
    Face? face = _faceCache[imagePath];
    if (face == null && File(imagePath).existsSync()) {
      await _ensureDetectorInitialized();
      if (_detector != null) {
        try {
          final faces = await _detector!.detectFacesFromFilepath(imagePath);
          if (faces.isNotEmpty) {
            face = faces.first;
            _faceCache[imagePath] = face;
          }
        } catch (e) {
          debugPrint('Error detecting faces in FaceAreaDetectorUtil: $e');
        }
      }
    }

    // 4. Determine relative coordinates within face bounding box
    double relX;
    double relY;
    bool isInside = true;

    if (face != null) {
      final bbox = face.boundingBox;
      final double faceLeft = bbox.topLeft.x / imageSize.width;
      final double faceRight = bbox.topRight.x / imageSize.width;
      final double faceTop = bbox.topLeft.y / imageSize.height;
      final double faceBottom = bbox.bottomLeft.y / imageSize.height;

      final double faceW = (faceRight - faceLeft).abs();
      final double faceH = (faceBottom - faceTop).abs();

      if (faceW > 0 && faceH > 0) {
        relX = (normX - faceLeft) / faceW;
        relY = (normY - faceTop) / faceH;

        if (relX < -0.15 || relX > 1.15 || relY < -0.15 || relY > 1.15) {
          isInside = false;
        }
      } else {
        relX = (normX - 0.20) / 0.60;
        relY = (normY - 0.15) / 0.70;
      }
    } else {
      // Fallback assuming standard centered face frame
      relX = (normX - 0.20) / 0.60;
      relY = (normY - 0.15) / 0.70;
    }

    if (!isInside) {
      return FaceAreaResult(
        mainArea: "Outside Face",
        detailArea: "Background / Outside Face Area",
        tapPosition: tapPosition,
        normX: normX,
        normY: normY,
        relX: relX,
        relY: relY,
        isInsideFace: false,
      );
    }

    // 5. Classify facial area based on pose and relative coordinates
    final areaPair = _classifyRegion(relX, relY, pose);

    return FaceAreaResult(
      mainArea: areaPair.key,
      detailArea: areaPair.value,
      tapPosition: tapPosition,
      normX: normX,
      normY: normY,
      relX: relX,
      relY: relY,
      isInsideFace: true,
    );
  }

  /// Reads image dimensions from file bytes
  static Future<Size> _getImageSize(String path) async {
    try {
      final file = File(path);
      if (!file.existsSync()) return Size.zero;
      final bytes = await file.readAsBytes();
      final decoded = await decodeImageFromList(bytes);
      return Size(decoded.width.toDouble(), decoded.height.toDouble());
    } catch (_) {
      return Size.zero;
    }
  }

  /// Converts widget tap position on a BoxFit.cover image to normalized [0..1] coordinates on original image
  static Offset _widgetToNormalizedImageCoords({
    required Offset tapPosition,
    required Size widgetSize,
    required Size imageSize,
  }) {
    final scaleX = widgetSize.width / imageSize.width;
    final scaleY = widgetSize.height / imageSize.height;

    // BoxFit.cover uses the larger scale factor
    final scale = scaleX > scaleY ? scaleX : scaleY;

    final scaledW = imageSize.width * scale;
    final scaledH = imageSize.height * scale;

    final offsetX = (scaledW - widgetSize.width) / 2;
    final offsetY = (scaledH - widgetSize.height) / 2;

    final imgX = (tapPosition.dx + offsetX) / scale;
    final imgY = (tapPosition.dy + offsetY) / scale;

    final normX = (imgX / imageSize.width).clamp(0.0, 1.0);
    final normY = (imgY / imageSize.height).clamp(0.0, 1.0);

    return Offset(normX, normY);
  }

  /// Classifies face region according to relative coordinates and pose
  static MapEntry<String, String> _classifyRegion(
    double relX,
    double relY,
    String pose,
  ) {
    if (pose == 'left') {
      return _classifyLeftProfile(relX, relY);
    } else if (pose == 'right') {
      return _classifyRightProfile(relX, relY);
    } else {
      return _classifyFrontProfile(relX, relY);
    }
  }

  /// Front View Classification
  static MapEntry<String, String> _classifyFrontProfile(
    double relX,
    double relY,
  ) {
    // 1. Forehead (top portion)
    if (relY < 0.22) {
      if (relX < 0.25) return const MapEntry("Temple", "Temples");
      if (relX > 0.75) return const MapEntry("Temple", "Temples");
      return const MapEntry("Forehead", "Forehead");
    }

    // 2. Eyebrows & Glabella (upper-mid)
    if (relY >= 0.22 && relY < 0.32) {
      if (relX < 0.44) return const MapEntry("Eyebrow", "Eyebrow Lift");
      if (relX > 0.56) return const MapEntry("Eyebrow", "Eyebrow Lift");
      return const MapEntry("Glabella", "Glabella Line");
    }

    // 3. Eyes & Crows Feet (mid)
    if (relY >= 0.32 && relY < 0.44) {
      if (relX < 0.28) return const MapEntry("Crows Feet", "Crows Feet");
      if (relX > 0.72) return const MapEntry("Crows Feet", "Crows Feet");
      if (relX < 0.46) return const MapEntry("Eyes", "Left Eye");
      if (relX > 0.54) return const MapEntry("Eyes", "Right Eye");
      return const MapEntry("Nose", "Bunny Lines");
    }

    // 4. Under Eye / Tear Trough / Jelly-Roll
    if (relY >= 0.44 && relY < 0.52) {
      if (relX < 0.42) return const MapEntry("Under Eye", "Tear Trough / Under-Eye Jelly-Roll");
      if (relX > 0.58) return const MapEntry("Under Eye", "Tear Trough / Under-Eye Jelly-Roll");
      return const MapEntry("Nose", "Bunny Lines");
    }

    // 5. Nose (central strip)
    if (relX >= 0.42 && relX <= 0.58 && relY >= 0.32 && relY < 0.68) {
      if (relY < 0.52) return const MapEntry("Nose", "Bunny Lines");
      if (relY < 0.60) return const MapEntry("Nose", "Nasal Tip Lift");
      return const MapEntry("Nose", "Nose Flare Reduction");
    }

    // 6. Cheeks & Preauricular
    if (relY >= 0.48 && relY < 0.72) {
      if (relX < 0.22) return const MapEntry("Preauricular", "Preauricular Area");
      if (relX > 0.78) return const MapEntry("Preauricular", "Preauricular Area");
      if (relX < 0.42) return const MapEntry("Cheeks", "Cheeks/Middle Face Volume");
      if (relX > 0.58) return const MapEntry("Cheeks", "Cheeks/Middle Face Volume");
      return const MapEntry("Nasolabial", "Nasolabial Fold");
    }

    // 7. Lips / Mouth / Gummy Smile / Lip Flip / Marionette / Downturned
    if (relY >= 0.68 && relY < 0.82) {
      if (relX >= 0.28 && relX <= 0.72) {
        if (relX < 0.38) return const MapEntry("Mouth", "Downturned Mouth Corners / Marionette Lines");
        if (relX > 0.62) return const MapEntry("Mouth", "Downturned Mouth Corners / Marionette Lines");
        if (relY < 0.72) return const MapEntry("Lips", "Gummy Smile");
        if (relY < 0.76) return const MapEntry("Lips", "Lip Flip / Lips");
        return const MapEntry("Lips", "Perioral Line");
      }
    }

    // 8. Chin / Jawline / Masseter / Pre-Jowl
    if (relY >= 0.82) {
      if (relX < 0.28) return const MapEntry("Masseter", "Masseter Reduction");
      if (relX > 0.72) return const MapEntry("Masseter", "Masseter Reduction");
      if (relX < 0.38) return const MapEntry("Jawline", "Jawline / Pre-Jowl");
      if (relX > 0.62) return const MapEntry("Jawline", "Jawline / Pre-Jowl");
      if (relY > 0.90) return const MapEntry("Chin", "Chin Shadow Area");
      return const MapEntry("Chin", "Chin Dimpling / Chin");
    }

    return const MapEntry("Face", "Face Area");
  }

  /// Left Profile Classification
  static MapEntry<String, String> _classifyLeftProfile(
    double relX,
    double relY,
  ) {
    if (relY < 0.25) return const MapEntry("Forehead", "Forehead");
    if (relY < 0.35) {
      if (relX < 0.60) return const MapEntry("Eyebrow", "Left Eyebrow");
      return const MapEntry("Temple", "Left Temple");
    }
    if (relY < 0.46) {
      if (relX < 0.55) return const MapEntry("Eyes", "Left Eye");
      return const MapEntry("Nose", "Nose Bridge");
    }
    if (relY < 0.54) {
      if (relX < 0.50) return const MapEntry("Under Eye", "Left Under Eye");
      return const MapEntry("Nose", "Nose Tip");
    }
    if (relY < 0.72) {
      if (relX < 0.65) return const MapEntry("Cheeks", "Left Cheek");
      return const MapEntry("Lips", "Lips");
    }
    if (relY >= 0.72 && relY < 0.84) return const MapEntry("Lips", "Mouth / Lips");
    return const MapEntry("Chin", "Left Jawline / Chin");
  }

  /// Right Profile Classification
  static MapEntry<String, String> _classifyRightProfile(
    double relX,
    double relY,
  ) {
    if (relY < 0.25) return const MapEntry("Forehead", "Forehead");
    if (relY < 0.35) {
      if (relX > 0.40) return const MapEntry("Eyebrow", "Right Eyebrow");
      return const MapEntry("Temple", "Right Temple");
    }
    if (relY < 0.46) {
      if (relX > 0.45) return const MapEntry("Eyes", "Right Eye");
      return const MapEntry("Nose", "Nose Bridge");
    }
    if (relY < 0.54) {
      if (relX > 0.50) return const MapEntry("Under Eye", "Right Under Eye");
      return const MapEntry("Nose", "Nose Tip");
    }
    if (relY < 0.72) {
      if (relX > 0.35) return const MapEntry("Cheeks", "Right Cheek");
      return const MapEntry("Lips", "Lips");
    }
    if (relY >= 0.72 && relY < 0.84) return const MapEntry("Lips", "Mouth / Lips");
    return const MapEntry("Chin", "Right Jawline / Chin");
  }

  /// Resource cleanup
  static void dispose() {
    _detector?.dispose();
    _detector = null;
    _faceCache.clear();
  }
}
