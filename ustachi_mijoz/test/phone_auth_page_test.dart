
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/core/utils/either.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/core/components/base_button.dart';
import 'package:ustachi/features/auth/domain/entities/auth_tokens_entity.dart';
import 'package:ustachi/features/auth/domain/entities/auth_user_entity.dart';
import 'package:ustachi/features/auth/domain/entities/send_code_result_entity.dart';
import 'package:ustachi/features/auth/domain/repositories/auth_repository.dart';
import 'package:ustachi/features/auth/domain/usecases/send_code_usecase.dart';
import 'package:ustachi/features/auth/domain/usecases/update_me_usecase.dart';
import 'package:ustachi/features/auth/domain/usecases/verify_code_usecase.dart';
import 'package:ustachi/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:ustachi/features/auth/presentation/router/auth_router.dart';
import 'package:ustachi/features/auth/presentation/view/phone_auth_page.dart';

class _FakeRepo implements AuthRepository {
  @override
  Future<Either<Failure, SendCodeResultEntity>> sendCode(SendCodeParams params) => throw UnimplementedError();
  @override
  Future<Either<Failure, AuthTokensEntity>> verifyCode(VerifyCodeParams params) => throw UnimplementedError();
  @override
  Future<Either<Failure, AuthTokensEntity>> exchangeTelegramCode(String code) => throw UnimplementedError();
  @override
  Future<Either<Failure, AuthUserEntity>> me() => throw UnimplementedError();
  @override
  Future<Either<Failure, AuthUserEntity>> updateMe(UpdateMeParams params) => throw UnimplementedError();
  @override
  Future<Either<Failure, void>> logout() => throw UnimplementedError();
}

class _RecordingRouter implements AuthRouter {
  bool otpRequested = false;

  @override
  void replaceWithHome(BuildContext context) {}
  @override
  void replaceWithPhoneAuth(BuildContext context) {}
  @override
  void navigateToOtpConfirm(BuildContext context, {required String phoneNumber}) {
    otpRequested = true;
  }
  @override
  void replaceWithCompleteProfile(BuildContext context) {}
}

Future<void> _pump(WidgetTester tester, _RecordingRouter router) async {
  final repo = _FakeRepo();
  final bloc = AuthBloc(
    sendCodeUseCase: SendCodeUseCase(repo),
    verifyCodeUseCase: VerifyCodeUseCase(repo),
    updateMeUseCase: UpdateMeUseCase(repo),
  );
  await tester.pumpWidget(TranslationProvider(
    child: ScreenUtilInit(
      designSize: const Size(428, 926),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) => MaterialApp(
        home: BlocProvider<AuthBloc>.value(value: bloc, child: PhoneAuthPage(router: router)),
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('telefon maydoni darhol ko\'rinadi va asosiy tugma shu', (tester) async {
    final router = _RecordingRouter();
    await _pump(tester, router);

    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.widgetWithText(BaseButton, 'Davom etish'), findsOneWidget);

    expect(find.text('SMS orqali kirish'), findsNothing);
  });

  testWidgets('Telegram tugmasi qo\'shimcha variant sifatida pastda turadi', (tester) async {
    await _pump(tester, _RecordingRouter());

    expect(find.text('Telegram orqali kirish'), findsOneWidget);
    expect(find.text('yoki'), findsOneWidget);

    final phoneTop = tester.getTopLeft(find.byType(TextFormField)).dy;
    final telegramTop = tester.getTopLeft(find.text('Telegram orqali kirish')).dy;
    expect(phoneTop, lessThan(telegramTop));
  });

  testWidgets('telefon kiritib davom etish — OTP so\'raladi', (tester) async {
    final router = _RecordingRouter();
    await _pump(tester, router);

    await tester.enterText(find.byType(TextFormField), '901234567');
    await tester.tap(find.widgetWithText(BaseButton, 'Davom etish'));
    await tester.pump();

    expect(find.text('Telefon raqamni to\'g\'ri kiriting'), findsNothing);
  });
}
