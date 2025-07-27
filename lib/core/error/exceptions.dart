class CacheException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  CacheException(this.message, [this.stackTrace]);

  @override
  String toString() => 'CacheException: $message';
}

class ServerException implements Exception {
  final String message;
  final int? statusCode;
  final StackTrace? stackTrace;

  ServerException(this.message, {this.statusCode, this.stackTrace});

  @override
  String toString() => 'ServerException: $message';
}

class NetworkException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  NetworkException(this.message, [this.stackTrace]);

  @override
  String toString() => 'NetworkException: $message';
}
