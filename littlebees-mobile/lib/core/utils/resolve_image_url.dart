import '../config/app_config.dart';

String? resolveImageUrl(String? rawUrl) {
  if (rawUrl == null || rawUrl.isEmpty) return null;
  if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) {
    return rawUrl;
  }

  if (rawUrl.startsWith('/')) {
    return '${AppConfig.apiBaseUrl}$rawUrl';
  }

  return rawUrl;
}
