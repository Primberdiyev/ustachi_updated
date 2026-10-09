
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/profile/data/master_profile_api.dart';
import 'package:ustachi/features/profile/presentation/view/specialty_question_page.dart';

const _rom = MasterSpecialty(id: 1, name: 'Rom ustasi', code: 'rom');

const _gisht = MasterSpecialty(
  id: 3,
  name: 'G\'isht teruvchi',
  code: 'gisht',
  unit: 'dona',
  unitQuestion: 'Bitta g\'ishtni qanchadan terasiz?',
);

const _tom = MasterSpecialty(
  id: 4,
  name: 'Tom yopuvchi',
  code: 'tom',
  unitQuestion: 'Qanday tomni necha pulga yopasiz?',
  noteByMaster: true,
);

Future<SpecialtyAnswers?> _open(
  WidgetTester tester, {
  required MasterSpecialty specialty,
  int? rate,
  String? note,
}) async {
  tester.view.physicalSize = const Size(390 * 3, 900 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  SpecialtyAnswers? answers;
  await tester.pumpWidget(ScreenUtilInit(
    designSize: const Size(428, 926),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (_, __) => TranslationProvider(
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async => answers = await SpecialtyQuestionPage.show(
                context,
                specialty: specialty,
                rate: rate,
                note: note,
              ),
              child: const Text('ochish'),
            ),
          ),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('ochish'));
  await tester.pumpAndSettle();
  return answers;
}

void main() {
  testWidgets('ROM — foyda foizi SO\'RALMAYDI', (tester) async {
    await _open(tester, specialty: _rom);

    expect(find.text('Rom ustasi'), findsWidgets);
    expect(find.text('Foyda foizi'), findsNothing);
    expect(find.byType(TextFormField), findsNothing);
  });

  testWidgets('STAVKALI yo\'nalish — savol va birlik o\'z sahifasida',
      (tester) async {
    await _open(tester, specialty: _gisht);

    expect(find.text('Bitta g\'ishtni qanchadan terasiz?'), findsOneWidget);
    expect(find.text('/ dona'), findsOneWidget);
  });

  testWidgets('narxsiz javob QABUL QILINMAYDI', (tester) async {
    await _open(tester, specialty: _gisht);

    await tester.tap(find.text('Tayyor'));
    await tester.pumpAndSettle();

    expect(find.text('Bitta g\'ishtni qanchadan terasiz?'), findsOneWidget);
  });

  testWidgets(
      'IZOHLI yo\'nalish — narx o\'rniga erkin matn so\'raladi va qaytariladi',
      (tester) async {
    SpecialtyAnswers? answers;
    tester.view.physicalSize = const Size(390 * 3, 900 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(ScreenUtilInit(
      designSize: const Size(428, 926),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) => TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async =>
                    answers = await SpecialtyQuestionPage.show(
                  context,
                  specialty: _tom,
                ),
                child: const Text('ochish'),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('ochish'));
    await tester.pumpAndSettle();

    expect(find.text('Qanday tomni necha pulga yopasiz?'), findsOneWidget);

    expect(find.text('Foyda foizi'), findsNothing);

    await tester.enterText(
      find.byType(TextFormField).first,
      '1 m² — 30 000 so\'m',
    );
    await tester.tap(find.text('Tayyor'));
    await tester.pumpAndSettle();

    expect(answers, isNotNull);
    expect(answers!.note, '1 m² — 30 000 so\'m');
    expect(answers!.rate, isNull);
  });

  testWidgets('IZOHLI yo\'nalish — bo\'sh matn ham qabul qilinadi',
      (tester) async {

    SpecialtyAnswers? answers;
    tester.view.physicalSize = const Size(390 * 3, 900 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(ScreenUtilInit(
      designSize: const Size(428, 926),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) => TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async =>
                    answers = await SpecialtyQuestionPage.show(
                  context,
                  specialty: _tom,
                ),
                child: const Text('ochish'),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('ochish'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tayyor'));
    await tester.pumpAndSettle();

    expect(answers, isNotNull);
    expect(answers!.note, '');
    expect(answers!.rate, isNull);
  });

  testWidgets('IZOHLI yo\'nalish — avvalgi matn ko\'rinadi', (tester) async {
    await _open(tester, specialty: _tom, note: 'Sasna + shifer — 30 000');

    expect(find.text('Sasna + shifer — 30 000'), findsOneWidget);
  });
}
