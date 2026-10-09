import 'package:dio/dio.dart';
import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/features/profile/data/master_profile_api.dart';
import 'package:ustachi/features/profile/domain/models/user_model.dart';
import 'package:ustachi/features/profile/domain/repository/profile_repository.dart';

enum MasterOnboardingStep { personal, professional, ready, retry, signIn }

class MasterOnboardingResult {
  const MasterOnboardingResult(this.step, {this.user});
  final MasterOnboardingStep step;
  final UserModel? user;
}

class MasterOnboardingCheck {
  MasterOnboardingCheck(this.users, this.professional);
  final ProfileRepository users;
  final MasterProfileApi professional;

  Future<MasterOnboardingResult> call() async {
    try {
      final result = await users.getUserData();
      if (result.isLeft) {
        final failure = result.left;
        return MasterOnboardingResult(
          failure is ServerFailure && [401, 403].contains(failure.statusCode)
              ? MasterOnboardingStep.signIn
              : MasterOnboardingStep.retry,
        );
      }
      final user = result.right;
      if (!user.isActive) {
        return const MasterOnboardingResult(MasterOnboardingStep.signIn);
      }
      if (!user.hasRequiredProfile) {
        return MasterOnboardingResult(MasterOnboardingStep.personal,
            user: user);
      }
      final profile =
          await professional.readWithStatus(rejectUnauthorized: true);
      if (profile.data?.isComplete ?? false) {
        return MasterOnboardingResult(MasterOnboardingStep.ready, user: user);
      }
      return MasterOnboardingResult(
        profile.reachable
            ? MasterOnboardingStep.professional
            : MasterOnboardingStep.retry,
        user: user,
      );
    } on DioException catch (error) {
      return MasterOnboardingResult(
        [401, 403].contains(error.response?.statusCode)
            ? MasterOnboardingStep.signIn
            : MasterOnboardingStep.retry,
      );
    } catch (_) {
      return const MasterOnboardingResult(MasterOnboardingStep.retry);
    }
  }
}
