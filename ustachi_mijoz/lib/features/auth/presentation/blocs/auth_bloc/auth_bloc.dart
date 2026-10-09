import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/features/auth/domain/usecases/send_code_usecase.dart';
import 'package:ustachi/features/auth/domain/usecases/update_me_usecase.dart';
import 'package:ustachi/features/auth/domain/usecases/verify_code_usecase.dart';
import 'package:ustachi/features/auth/presentation/blocs/auth_status.dart';

part 'auth_bloc.freezed.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required SendCodeUseCase sendCodeUseCase,
    required VerifyCodeUseCase verifyCodeUseCase,
    required UpdateMeUseCase updateMeUseCase,
  })  : _sendCodeUseCase = sendCodeUseCase,
        _verifyCodeUseCase = verifyCodeUseCase,
        _updateMeUseCase = updateMeUseCase,
        super(const AuthState()) {
    on<AuthCodeRequested>(_onCodeRequested);
    on<AuthCodeResendRequested>(_onCodeResendRequested);
    on<AuthCodeSubmitted>(_onCodeSubmitted);
    on<AuthProfileSubmitted>(_onProfileSubmitted);
  }

  final SendCodeUseCase _sendCodeUseCase;
  final VerifyCodeUseCase _verifyCodeUseCase;
  final UpdateMeUseCase _updateMeUseCase;

  Future<void> _onCodeRequested(
    AuthCodeRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        sendCodeStatus: Statuses.loading,
        resendCodeStatus: Statuses.initial,
        verifyCodeStatus: Statuses.initial,
        failure: null,
        phoneNumber: event.phoneNumber,
      ),
    );

    final result = await _sendCodeUseCase(
      SendCodeParams(phoneNumber: event.phoneNumber),
    );

    if (result.isRight) {
      emit(
        state.copyWith(
          sendCodeStatus: Statuses.success,

          isNewUser: result.right.isNewUser,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        sendCodeStatus: Statuses.failure,
        failure: result.left,
      ),
    );
  }

  Future<void> _onCodeResendRequested(
    AuthCodeResendRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        resendCodeStatus: Statuses.loading,
        verifyCodeStatus: Statuses.initial,
        failure: null,
      ),
    );

    final result = await _sendCodeUseCase(
      SendCodeParams(phoneNumber: event.phoneNumber),
    );

    emit(
      result.isRight
          ? state.copyWith(resendCodeStatus: Statuses.success)
          : state.copyWith(
              resendCodeStatus: Statuses.failure,
              failure: result.left,
            ),
    );
  }

  Future<void> _onCodeSubmitted(
    AuthCodeSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        verifyCodeStatus: Statuses.loading,
        resendCodeStatus: Statuses.initial,
        failure: null,
      ),
    );

    final result = await _verifyCodeUseCase(
      VerifyCodeParams(
        phoneNumber: event.phoneNumber,
        code: event.code,
      ),
    );

    if (result.isRight) {
      emit(
        state.copyWith(
          verifyCodeStatus: Statuses.success,
          isNewUser: result.right.isNewUser,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        verifyCodeStatus: Statuses.failure,
        failure: result.left,
      ),
    );
  }

  Future<void> _onProfileSubmitted(
    AuthProfileSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        updateProfileStatus: Statuses.loading,
        failure: null,
      ),
    );

    final result = await _updateMeUseCase(
      UpdateMeParams(
        fullName: event.fullName,
        photoPath: event.photoPath,
        regionId: event.regionId,
        districtId: event.districtId,
        address: event.address,
      ),
    );

    emit(
      result.isRight
          ? state.copyWith(updateProfileStatus: Statuses.success)
          : state.copyWith(
              updateProfileStatus: Statuses.failure,
              failure: result.left,
            ),
    );
  }
}
