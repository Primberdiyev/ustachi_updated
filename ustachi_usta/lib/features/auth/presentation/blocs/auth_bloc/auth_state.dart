part of 'auth_bloc.dart';

@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState({
    @Default(Statuses.initial) Statuses sendCodeStatus,
    @Default(Statuses.initial) Statuses resendCodeStatus,
    @Default(Statuses.initial) Statuses verifyCodeStatus,
    @Default(Statuses.initial) Statuses updateProfileStatus,
    Failure? failure,

    @Default('') String phoneNumber,

    @Default(false) bool isNewUser,
  }) = _AuthState;
}
