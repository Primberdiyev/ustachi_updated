part of 'profile_bloc.dart';

abstract class ProfileEvent {
  const ProfileEvent();
}

class GetUserDataEvent extends ProfileEvent {}

class ClearProfileEvent extends ProfileEvent {
  const ClearProfileEvent();
}
