import 'package:ustachi/core/api/error/validation_error.dart';
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String errorMessage;
  final ValidationError? validationError;

  const Failure(this.errorMessage, {this.validationError});

  @override
  List<Object?> get props => [errorMessage, validationError];
}

class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure(super.errorMessage, this.statusCode,
      {super.validationError});
}

class CancelTokenFailure extends Failure {
  final int? statusCode;

  const CancelTokenFailure(super.errorMessage, this.statusCode);
}

class CacheFailure extends Failure {
  const CacheFailure(super.errorMessage);
}

class ParsingFailure extends Failure {
  const ParsingFailure(super.errorMessage);
}
