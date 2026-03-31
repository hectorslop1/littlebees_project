import 'dart:io';
import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../api/endpoints.dart';

class FileUploadService {
  final ApiClient _api = ApiClient.instance;

  FileUploadResult _mapResult(Map<String, dynamic> response) {
    return FileUploadResult(
      fileId: response['id'] as String? ?? response['fileId'] as String,
      filename: response['filename'] as String? ?? '',
      url: response['url'] as String? ?? response['storageKey'] as String?,
      mimeType: response['mimeType'] as String? ?? '',
      sizeBytes: _parseSizeBytes(response['sizeBytes']),
    );
  }

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

      return _mapResult(response);
    } catch (e) {
      throw Exception('Error al subir archivo: $e');
    }
  }

  Future<FileUploadResult> getFileById(String fileId) async {
    try {
      final response = await _api.get<Map<String, dynamic>>(
        Endpoints.file(fileId),
      );
      return _mapResult(response);
    } catch (e) {
      throw Exception('Error al obtener archivo: $e');
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

int _parseSizeBytes(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
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

  factory FileUploadResult.fromJson(Map<String, dynamic> json) {
    return FileUploadResult(
      fileId: json['id'] as String? ?? json['fileId'] as String,
      filename: json['filename'] as String? ?? '',
      url: json['url'] as String? ?? json['storageKey'] as String?,
      mimeType: json['mimeType'] as String? ?? '',
      sizeBytes: _parseSizeBytes(json['sizeBytes']),
    );
  }

  String get displaySize {
    final mb = sizeBytes / (1024 * 1024);
    if (mb < 1) {
      final kb = sizeBytes / 1024;
      return '${kb.toStringAsFixed(1)} KB';
    }
    return '${mb.toStringAsFixed(1)} MB';
  }
}
