
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/core/components/base_button.dart';
import 'package:ustachi/core/icons/telegram_icon.dart';
import 'package:ustachi/core/utils/either.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
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

class _NoopRouter implements AuthRouter {
  @override
  void replaceWithHome(BuildContext context) {}
  @override
  void replaceWithPhoneAuth(BuildContext context) {}
  @override
  void navigateToOtpConfirm(BuildContext context, {required String phoneNumber}) {}
  @override
  void replaceWithCompleteProfile(BuildContext context) {}
}

Future<void> _pump(WidgetTester tester) async {
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
        home: BlocProvider<AuthBloc>.value(value: bloc, child: PhoneAuthPage(router: _NoopRouter())),
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('telefon maydoni asosiy, Telegram tugmasi ikonka bilan pastda', (tester) async {
    await _pump(tester);

    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.widgetWithText(BaseButton, 'Davom etish'), findsOneWidget);
    expect(find.text('yoki'), findsOneWidget);
    expect(find.text('Telegram orqali kirish'), findsOneWidget);
    expect(find.byType(TelegramIcon), findsOneWidget);

    expect(find.textContaining('bepul'), findsNothing);

    final phoneTop = tester.getTopLeft(find.byType(TextFormField)).dy;
    final telegramTop = tester.getTopLeft(find.text('Telegram orqali kirish')).dy;
    expect(phoneTop, lessThan(telegramTop));
  });
}
