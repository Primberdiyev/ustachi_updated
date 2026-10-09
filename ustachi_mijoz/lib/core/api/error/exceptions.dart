
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException(this.message, this.statusCode);
}

class CancelTokenException implements Exception {
  final String message;
  final int? statusCode;

  CancelTokenException(this.message, this.statusCode);
}

class CacheException implements Exception {
  final String message;

  CacheException(this.message);
}

class ParsingException implements Exception {
  final String message;

  ParsingException(this.message);
}
