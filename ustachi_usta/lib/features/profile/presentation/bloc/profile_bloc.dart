import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/core/usecases/usecase.dart';
import 'package:ustachi/features/auth/presentation/blocs/auth_status.dart';
import 'package:ustachi/features/profile/domain/models/user_model.dart';
import 'package:ustachi/features/profile/domain/use_cases/get_user_data_use_case.dart';

part 'profile_bloc.freezed.dart';
part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({required GetUserDataUseCase getUserDataUseCase})
      : _getUserDataUseCase = getUserDataUseCase,
        super(const ProfileState()) {
    on<GetUserDataEvent>(getUserData);
    on<ClearProfileEvent>(_clearProfile);
  }
  final GetUserDataUseCase _getUserDataUseCase;

  Future<void> getUserData(
      GetUserDataEvent event, Emitter<ProfileState> emit) async {
    emit(
      state.copyWith(
        getUserDataStatus: Statuses.loading,
        failure: null,
      ),
    );
    await Future.delayed(Duration(seconds: 1));
    final result = await _getUserDataUseCase(
      NoParams(),
    );

    if (result.isRight) {
      emit(
        state.copyWith(
          getUserDataStatus: Statuses.success,
          userModel: result.right,
          failure: null,
        ),
      );
    } else {
      final failure = result.left;
      final shouldClearUser = failure is ServerFailure &&
          <int>[401, 403].contains(failure.statusCode);

      emit(
        state.copyWith(
          failure: failure,
          getUserDataStatus: Statuses.failure,
          userModel: shouldClearUser ? null : state.userModel,
        ),
      );
    }
  }

  void _clearProfile(
    ClearProfileEvent event,
    Emitter<ProfileState> emit,
  ) {
    emit(const ProfileState());
  }
}
