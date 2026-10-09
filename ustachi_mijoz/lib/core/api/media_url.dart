import 'package:ustachi/core/api/api_urls.dart';

String? mediaUrl(String? path) {
  final value = path?.trim() ?? '';
  if (value.isEmpty) return null;
  if (value.startsWith('http://') || value.startsWith('https://')) {
    return value;
  }
  final base = ApiUrls.baseUrl.endsWith('/')
      ? ApiUrls.baseUrl.substring(0, ApiUrls.baseUrl.length - 1)
      : ApiUrls.baseUrl;
  return value.startsWith('/') ? '$base$value' : '$base/$value';
}
