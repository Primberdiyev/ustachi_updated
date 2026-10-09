import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/core/usecases/usecase.dart';
import 'package:ustachi/features/auth/presentation/blocs/auth_status.dart';
import 'package:ustachi/features/splash/domain/entities/splash_destination.dart';
import 'package:ustachi/features/splash/domain/use_cases/clear_session_use_case.dart';
import 'package:ustachi/features/splash/domain/use_cases/resolve_startup_use_case.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc({
    required ResolveStartupUseCase resolveStartupUseCase,
    required ClearSessionUseCase clearSessionUseCase,
  })  : _resolveStartupUseCase = resolveStartupUseCase,
        _clearSessionUseCase = clearSessionUseCase,
        super(const SplashState()) {
    on<CheckTokenAvailableEvent>(_onStarted);
    on<ClearSessionAndOpenAuthEvent>(_onClearSessionAndOpenAuth);
  }

  final ResolveStartupUseCase _resolveStartupUseCase;
  final ClearSessionUseCase _clearSessionUseCase;

  static const _minVisibleDuration = Duration(milliseconds: 1200);

  Future<void> _onStarted(
    CheckTokenAvailableEvent event,
    Emitter<SplashState> emit,
  ) async {
    emit(
      state.copyWith(
        status: Statuses.loading,
        clearDestination: true,
        clearFailure: true,
      ),
    );

    final minVisible = Future<void>.delayed(_minVisibleDuration);
    final result = await _resolveStartupUseCase(NoParams());
    await minVisible;
    if (result.isRight) {
      emit(
        state.copyWith(
          status: Statuses.success,
          destination: result.right,
          clearFailure: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: Statuses.failure,
        failure: result.left,
        clearDestination: true,
      ),
    );
  }

  Future<void> _onClearSessionAndOpenAuth(
    ClearSessionAndOpenAuthEvent event,
    Emitter<SplashState> emit,
  ) async {
    emit(
      state.copyWith(
        status: Statuses.loading,
        clearDestination: true,
        clearFailure: true,
      ),
    );

    final result = await _clearSessionUseCase(NoParams());
    if (result.isRight) {
      emit(
        state.copyWith(
          status: Statuses.success,
          destination: SplashDestination.phoneAuth,
          clearFailure: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: Statuses.failure,
        failure: result.left,
        clearDestination: true,
      ),
    );
  }
}
