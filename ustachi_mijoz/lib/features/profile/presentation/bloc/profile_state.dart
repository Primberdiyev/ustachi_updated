part of 'profile_bloc.dart';

@freezed
abstract class ProfileState with _$ProfileState {
  const factory ProfileState({
    @Default(Statuses.initial) Statuses getUserDataStatus,
    UserModel? userModel,
    Failure? failure,
  }) = _ProfileState;
}
