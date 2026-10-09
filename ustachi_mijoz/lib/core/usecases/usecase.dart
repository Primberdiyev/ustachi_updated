import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/core/utils/either.dart';
import 'package:equatable/equatable.dart';

abstract class UseCase<Result, Params> {
  Future<Either<Failure, Result>> call(Params params);
}

abstract class StreamUseCase<Result, Params> {
  Stream<Result> call(Params params);
}

class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}
