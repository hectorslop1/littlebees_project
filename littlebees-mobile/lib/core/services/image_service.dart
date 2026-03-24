import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  /// Capturar foto desde la cámara
  Future<File?> capturePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo == null) return null;

      return File(photo.path);
    } catch (e) {
      debugPrint('Error capturing photo: $e');
      rethrow;
    }
  }

  /// Seleccionar foto desde la galería
  Future<File?> pickFromGallery() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo == null) return null;

      return File(photo.path);
    } catch (e) {
      debugPrint('Error picking photo: $e');
      rethrow;
    }
  }

  /// Grabar video con la cámara
  Future<File?> captureVideo({
    Duration maxDuration = const Duration(seconds: 60),
  }) async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: maxDuration,
      );

      if (video == null) return null;

      return File(video.path);
    } catch (e) {
      debugPrint('Error capturing video: $e');
      rethrow;
    }
  }

  /// Seleccionar video desde la galería
  Future<File?> pickVideoFromGallery({
    Duration maxDuration = const Duration(seconds: 60),
  }) async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: maxDuration,
      );

      if (video == null) return null;

      return File(video.path);
    } catch (e) {
      debugPrint('Error picking video: $e');
      rethrow;
    }
  }

  /// Mostrar opciones de cámara o galería
  Future<File?> pickImage({bool allowGallery = true}) async {
    // Por defecto, usar cámara directamente
    // Si se necesita selector, se puede implementar un dialog
    return capturePhoto();
  }

  /// Convertir archivo a bytes para upload
  Future<Uint8List> fileToBytes(File file) async {
    return await file.readAsBytes();
  }

  /// Obtener tamaño del archivo en MB
  double getFileSizeInMB(File file) {
    final bytes = file.lengthSync();
    return bytes / (1024 * 1024);
  }

  /// Validar que el archivo no exceda el límite
  bool validateFileSize(File file, {double maxSizeMB = 10.0}) {
    return getFileSizeInMB(file) <= maxSizeMB;
  }
}
