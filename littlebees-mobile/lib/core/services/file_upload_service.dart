import 'dart:io';
import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../api/endpoints.dart';

class FileUploadService {
  final ApiClient _api = ApiClient.instance;

  /// Subir archivo al servidor
  /// Retorna el ID del archivo y la URL
  Future<FileUploadResult> uploadFile({
    required File file,
    required String purpose,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
        'purpose': purpose,
      });

      final response = await _api.upload<Map<String, dynamic>>(
        Endpoints.fileUpload,
        formData: formData,
        onSendProgress: (sent, total) {
          if (onProgress != null && total > 0) {
            onProgress(sent / total);
          }
        },
      );

      return FileUploadResult(
        fileId: response['id'] as String,
        filename: response['filename'] as String,
        url: response['storageKey'] as String?,
        mimeType: response['mimeType'] as String,
        sizeBytes: response['sizeBytes'] as int,
      );
    } catch (e) {
      throw Exception('Error al subir archivo: $e');
    }
  }

  /// Subir foto de entrada/salida
  Future<FileUploadResult> uploadCheckInOutPhoto(File photo) async {
    return uploadFile(file: photo, purpose: 'attendance_photo');
  }

  /// Subir foto de actividad
  Future<FileUploadResult> uploadActivityPhoto(File photo) async {
    return uploadFile(file: photo, purpose: 'activity_photo');
  }

  /// Subir documento
  Future<FileUploadResult> uploadDocument(File file) async {
    return uploadFile(file: file, purpose: 'document');
  }
}

class FileUploadResult {
  final String fileId;
  final String filename;
  final String? url;
  final String mimeType;
  final int sizeBytes;

  FileUploadResult({
    required this.fileId,
    required this.filename,
    this.url,
    required this.mimeType,
    required this.sizeBytes,
  });

  String get displaySize {
    final mb = sizeBytes / (1024 * 1024);
    if (mb < 1) {
      final kb = sizeBytes / 1024;
      return '${kb.toStringAsFixed(1)} KB';
    }
    return '${mb.toStringAsFixed(1)} MB';
  }
}
