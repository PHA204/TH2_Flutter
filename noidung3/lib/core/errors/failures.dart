// lib/core/errors/failures.dart
// lib/core/errors/failures.dart
class Failure {
  final String message;
  
  const Failure(this.message);
  
  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  ServerFailure(String message) : super(message);
}

class ValidationFailure extends Failure {
  ValidationFailure(String message) : super(message);
}

class NetworkFailure extends Failure {
  NetworkFailure(String message) : super(message);
}