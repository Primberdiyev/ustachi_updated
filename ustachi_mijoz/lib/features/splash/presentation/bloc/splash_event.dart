part of 'splash_bloc.dart';

abstract class SplashEvent {
  const SplashEvent();
}

class CheckTokenAvailableEvent extends SplashEvent {
  const CheckTokenAvailableEvent();
}

class ClearSessionAndOpenAuthEvent extends SplashEvent {
  const ClearSessionAndOpenAuthEvent();
}
