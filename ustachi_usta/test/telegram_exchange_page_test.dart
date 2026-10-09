
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/core/utils/either.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/auth/domain/entities/auth_tokens_entity.dart';
import 'package:ustachi/features/auth/domain/entities/auth_user_entity.dart';
import 'package:ustachi/features/auth/domain/entities/send_code_result_entity.dart';
import 'package:ustachi/features/auth/domain/usecases/send_code_usecase.dart';
import 'package:ustachi/features/auth/domain/usecases/update_me_usecase.dart';
import 'package:ustachi/features/auth/domain/usecases/verify_code_usecase.dart';
import 'package:ustachi/features/auth/domain/repositories/auth_repository.dart';
import 'package:ustachi/features/auth/presentation/router/auth_router.dart';
import 'package:ustachi/features/auth/presentation/view/telegram_exchange_page.dart';
import 'package:ustachi/features/profile/domain/models/user_model.dart';
import 'package:ustachi/features/profile/domain/repository/profile_repository.dart';
import 'package:ustachi/features/profile/domain/use_cases/get_user_data_use_case.dart';
import 'package:ustachi/features/profile/presentation/bloc/profile_bloc.dart';

class _StubRepo implements AuthRepository {
  _StubRepo(this.result);
  final Either<Failure, AuthTokensEntity> result;
  String? lastCode;

  @override
  Future<Either<Failure, AuthTokensEntity>> exchangeTelegramCode(String code) async {
    lastCode = code;
    return result;
  }

  @override
  Future<Either<Failure, SendCodeResultEntity>> sendCode(SendCodeParams params) => throw UnimplementedError();
  @override
  Future<Either<Failure, AuthTokensEntity>> verifyCode(VerifyCodeParams params) => throw UnimplementedError();
  @override
  Future<Either<Failure, AuthUserEntity>> me() => throw UnimplementedError();
  @override
  Future<Either<Failure, AuthUserEntity>> updateMe(UpdateMeParams params) => throw UnimplementedError();
  @override
  Future<Either<Failure, void>> logout() => throw UnimplementedError();
}

class _RecordingRouter implements AuthRouter {
  bool homeCalled = false;
  @override
  void replaceWithHome(BuildContext context) => homeCalled = true;
  @override
  void replaceWithPhoneAuth(BuildContext context) {}
  @override
  void navigateToOtpConfirm(BuildContext context, {required String phoneNumber}) {}
  @override
  void replaceWithCompleteProfile(BuildContext context) {}
}

Future<void> _pump(WidgetTester tester, {required AuthRepository repo, required AuthRouter router}) async {
  final sl = GetIt.instance;
  sl.registerLazySingleton<AuthRepository>(() => repo);
  addTearDown(() => sl.unregister<AuthRepository>());

  await tester.pumpWidget(TranslationProvider(
    child: ScreenUtilInit(
      designSize: const Size(428, 926),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) => MaterialApp(
        home: BlocProvider<ProfileBloc>(
          create: (_) => ProfileBloc(getUserDataUseCase: GetUserDataUseCase(repository: _NoopProfileRepository())),
          child: TelegramExchangePage(code: 'one-time-test-code-1234567890', router: router),
        ),
      ),
    ),
  ));

  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

class _NoopProfileRepository implements ProfileRepository {
  @override
  Future<Either<Failure, UserModel>> getUserData() => throw UnimplementedError();
}

void main() {
  testWidgets('muvaffaqiyatli almashinuv — HAR DOIM Home (yangi/eski farqsiz)', (tester) async {
    final router = _RecordingRouter();
    await _pump(
      tester,
      repo: _StubRepo(Right(const AuthTokensEntity(accessToken: 'a', refreshToken: 'r', isNewUser: true))),
      router: router,
    );

    expect(router.homeCalled, isTrue);
  });

  testWidgets('xato bo\'lsa qayta urinish va SMS variantlari ko\'rsatiladi', (tester) async {
    final router = _RecordingRouter();
    await _pump(
      tester,
      repo: _StubRepo(Left(const ServerFailure('Server xatosi', 500))),
      router: router,
    );

    expect(router.homeCalled, isFalse);
    expect(find.text('Qayta urinish'), findsOneWidget);
    expect(find.text('Botda qayta boshlash'), findsOneWidget);
    expect(find.text('SMS orqali kirish'), findsOneWidget);
  });
}
