part of 'splash_bloc.dart';

class SplashState extends Equatable {
  const SplashState({
    this.status = Statuses.initial,
    this.destination,
    this.failure,
  });

  final Statuses status;
  final SplashDestination? destination;
  final Failure? failure;

  SplashState copyWith({
    Statuses? status,
    SplashDestination? destination,
    Failure? failure,
    bool clearDestination = false,
    bool clearFailure = false,
  }) {
    return SplashState(
      status: status ?? this.status,
      destination: clearDestination ? null : (destination ?? this.destination),
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [status, destination, failure];
}
