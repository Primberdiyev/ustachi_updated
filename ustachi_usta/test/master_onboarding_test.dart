import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/core/utils/either.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/auth/domain/services/master_onboarding_check.dart';
import 'package:ustachi/features/auth/presentation/view/master_onboarding_gate.dart';
import 'package:ustachi/features/profile/data/master_profile_api.dart';
import 'package:ustachi/features/profile/domain/models/user_model.dart';
import 'package:ustachi/features/profile/domain/repository/profile_repository.dart';

UserModel user({String name = 'Usta', int? region = 1, int? district = 2}) =>
    UserModel(
      id: 7,
      phoneNumber: '+998901234567',
      fullName: name,
      isActive: true,
      dataJoined: '',
      photo: '',
      regionId: region,
      districtId: district,
    );

class Users implements ProfileRepository {
  Either<Failure, UserModel> result = Right(user());
  @override
  Future<Either<Failure, UserModel>> getUserData() async => result;
}

class Professional extends MasterProfileApi {
  Professional() : super(Dio());
  MasterProfileData? data;
  bool reachable = true;
  Object? error;
  int calls = 0;
  @override
  Future<({MasterProfileData? data, bool reachable})> readWithStatus(
      {bool rejectUnauthorized = false}) async {
    expect(rejectUnauthorized, isTrue);
    calls++;
    if (error != null) throw error!;
    return (data: data, reachable: reachable);
  }
}

void main() {
  group('onboarding decisions', () {
    late Users users;
    late Professional professional;
    late MasterOnboardingCheck check;
    setUp(() {
      users = Users();
      professional = Professional();
      check = MasterOnboardingCheck(users, professional);
    });
    test(
        'interrupted registration resumes personal details before professional requests',
        () async {
      for (final incomplete in [
        user(name: ''),
        user(region: null),
        user(district: null)
      ]) {
        users.result = Right(incomplete);
        expect((await check()).step, MasterOnboardingStep.personal);
        expect(professional.calls, 0);
      }
    });
    test(
        'existing OTP account without a professional profile resumes selection',
        () async {
      expect((await check()).step, MasterOnboardingStep.professional);
    });
    test('offline unknown or incomplete professional data requires retry',
        () async {
      professional.reachable = false;
      expect((await check()).step, MasterOnboardingStep.retry);
      professional.data = const MasterProfileData(experienceYears: 2);
      expect((await check()).step, MasterOnboardingStep.retry);
    });
    test(
        'previously completed offline profile can enter, including zero experience',
        () async {
      professional.reachable = false;
      professional.data =
          const MasterProfileData(specialtyId: 1, experienceYears: 0);
      expect((await check()).step, MasterOnboardingStep.ready);
    });
    test('network failure without cached personal details requires retry',
        () async {
      users.result = Left(const ServerFailure('offline', null));
      expect((await check()).step, MasterOnboardingStep.retry);
    });
    test('auth rejection never falls back to offline completion', () async {
      for (final code in [401, 403]) {
        users.result = Left(ServerFailure('expired', code));
        expect((await check()).step, MasterOnboardingStep.signIn);
        users.result = Right(user());
        professional.error = DioException(
          requestOptions: RequestOptions(path: '/profile'),
          response: Response(
              statusCode: code,
              requestOptions: RequestOptions(path: '/profile')),
        );
        expect((await check()).step, MasterOnboardingStep.signIn);
      }
    });
    test('legacy cache with location names remains usable', () {
      final cached = UserModel.fromJson({
        'id': 7,
        'full_name': 'Usta',
        'region_name': 'Toshkent',
        'district_name': 'Yunusobod'
      });
      expect(cached.hasRequiredProfile, isTrue);
    });
  });

  testWidgets(
      'main is not constructed before checks, steps cannot be skipped with back',
      (tester) async {
    var step = MasterOnboardingStep.personal;
    var builtMain = 0;
    final initial = Completer<MasterOnboardingResult>();
    var first = true;
    await tester.pumpWidget(TranslationProvider(
        child: MaterialApp(initialRoute: '/gate', routes: {
      '/': (_) => const Scaffold(body: Text('behind gate')),
      '/gate': (_) => MasterOnboardingGate(
            check: () async {
              if (first) {
                first = false;
                return initial.future;
              }
              return MasterOnboardingResult(step, user: user());
            },
            personalBuilder: (_, saved) => Scaffold(
                body: TextButton(
                    onPressed: () {
                      step = MasterOnboardingStep.professional;
                      saved();
                    },
                    child: const Text('save personal'))),
            professionalBuilder: (saved) => Scaffold(
                body: TextButton(
                    onPressed: () {
                      step = MasterOnboardingStep.ready;
                      saved();
                    },
                    child: const Text('save professional'))),
            readyBuilder: (_) {
              builtMain++;
              return const Scaffold(body: Text('main'));
            },
            onSignIn: () {},
          ),
    })));
    expect(builtMain, 0);
    initial.complete(MasterOnboardingResult(step, user: user()));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('save personal'), findsOneWidget);
    expect(builtMain, 0);
    await tester.tap(find.text('save personal'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('save professional'), findsOneWidget);
    expect(builtMain, 0);
    await tester.tap(find.text('save professional'));
    await tester.pumpAndSettle();
    expect(find.text('main'), findsOneWidget);
  });

  for (final trigger in ['resume', 'reconnect', 'button']) {
    testWidgets('failed check retries on $trigger without duplicate requests',
        (tester) async {
      var calls = 0;
      final reconnects = StreamController<void>();
      addTearDown(reconnects.close);
      await tester.pumpWidget(TranslationProvider(
          child: MaterialApp(
              home: MasterOnboardingGate(
        check: () async => MasterOnboardingResult(++calls == 1
            ? MasterOnboardingStep.retry
            : MasterOnboardingStep.ready),
        personalBuilder: (_, __) => const SizedBox(),
        professionalBuilder: (_) => const SizedBox(),
        readyBuilder: (_) => const Text('main'),
        reconnects: reconnects.stream,
        onSignIn: () {},
      ))));
      await tester.pumpAndSettle();
      expect(find.text('main'), findsNothing);
      if (trigger == 'resume') {
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        tester.binding
            .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      } else if (trigger == 'reconnect') {
        reconnects.add(null);
      } else {
        await tester.tap(find.byType(ElevatedButton));
      }
      await tester.pumpAndSettle();
      expect(calls, 2);
      expect(find.text('main'), findsOneWidget);
    });
  }
}
