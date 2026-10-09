import 'package:dio/dio.dart';
import 'package:ustachi/core/api/error/dio_error_handler.dart';
import 'package:ustachi/core/api/error/exceptions.dart';
import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/core/utils/either.dart';

mixin SafeCaller {
  Future<Either<Failure, T>> safeCall<T>(Future<T> Function() call) async {
    try {
      final result = await call();
      return Right(result);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          e.message,
          e.statusCode,
        ),
      );
    } on DioException catch (e) {
      return Left(
        DioErrorHandler.withDioError(error: e).failure,
      );
    } catch (e) {
      return Left(
        ParsingFailure(
          e.toString(),
        ),
      );
    }
  }
}
