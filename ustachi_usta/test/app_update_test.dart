
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ustachi/core/services/app_update/app_update_api.dart';
import 'package:ustachi/core/services/app_update/app_update_info.dart';
import 'package:ustachi/core/services/app_update/app_update_service.dart';
import 'package:ustachi/core/services/app_update/app_update_sheet.dart';
import 'package:ustachi/core/singletons/storage/storage.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';

Map<String, dynamic> payload({
  String status = 'optional',
  String current = '1.0.0',
  String latest = '1.0.1',
  String storeUrl = 'https://play.google.com/store/apps/details?id=com.ustachi.pro',
  List<String> notes = const [],
}) =>
    {
      'status': status,
      'current_version': current,
      'latest_version': latest,
      'store_url': storeUrl,
      'notes': notes,
    };

class _FakeApi implements AppUpdateApi {
  _FakeApi(this.response);

  AppUpdateInfo? response;
  int calls = 0;
  String? askedVersion;

  @override
  Future<AppUpdateInfo?> check({required String version}) async {
    calls++;
    askedVersion = version;
    return response;
  }
}

AppUpdateService service(AppUpdateApi api, {DateTime? now}) => AppUpdateService(
      api: api,
      clock: () => now ?? DateTime(2026, 9, 5, 12),
    );

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    PackageInfo.setMockInitialValues(
      appName: 'Ustachi Pro',
      packageName: 'com.ustachi.pro',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
    SharedPreferences.setMockInitialValues({});
    await StorageRepository.getInstance();
    await StorageRepository.clearStorage();
  });

  group('Serverning javobini O\'QISH', () {
    test('ixtiyoriy — havola va izohlar bilan', () {
      final info = AppUpdateInfo.fromJson(payload(notes: ['Kafel', 'Tezlik']));

      expect(info.status, AppUpdateStatus.optional);
      expect(info.isForced, isFalse);
      expect(info.shouldPrompt, isTrue);
      expect(info.latestVersion, '1.0.1');
      expect(info.notes, ['Kafel', 'Tezlik']);
    });

    test('majburiy — server "required" deydi', () {
      final info = AppUpdateInfo.fromJson(payload(status: 'required'));

      expect(info.status, AppUpdateStatus.forced);
      expect(info.isForced, isTrue);
      expect(info.shouldPrompt, isTrue);
    });

    test('yangilanish yo\'q — oyna chiqmaydi', () {
      final info = AppUpdateInfo.fromJson(
        payload(status: 'up_to_date', storeUrl: ''),
      );

      expect(info.shouldPrompt, isFalse);
    });

    test('HAVOLASIZ yangilanish KO\'RSATILMAYDI', () {

      final info = AppUpdateInfo.fromJson(payload(storeUrl: ''));

      expect(info.status, AppUpdateStatus.optional);
      expect(info.shouldPrompt, isFalse);
    });

    test('NOTANISH holat jim o\'tkaziladi', () {

      final info = AppUpdateInfo.fromJson(payload(status: 'kelajakdagi_tur'));

      expect(info.status, AppUpdateStatus.upToDate);
      expect(info.shouldPrompt, isFalse);
    });

    test('IZOHSIZ javob — bo\'sh ro\'yxat, xato emas', () {
      expect(AppUpdateInfo.fromJson(payload()).notes, isEmpty);
      expect(
        AppUpdateInfo.fromJson({'status': 'optional', 'store_url': 'x'}).notes,
        isEmpty,
      );
    });

    test('bo\'sh izoh qatorlari TASHLANADI', () {
      final info = AppUpdateInfo.fromJson(payload(notes: ['Bor', '  ', '']));
      expect(info.notes, ['Bor']);
    });
  });

  group('Qachon so\'raladi', () {
    test('ilova ochilganda — DOIM so\'raydi', () async {
      final api = _FakeApi(AppUpdateInfo.fromJson(payload()));

      await service(api).pendingUpdate(version: '1.0.0');
      await service(api).pendingUpdate(version: '1.0.0');

      expect(api.calls, 2);
    });

    test('fondan qaytganda — 6 soatda BIR MARTA', () async {
      final api = _FakeApi(AppUpdateInfo.fromJson(payload()));
      final start = DateTime(2026, 9, 5, 12);

      await service(api, now: start).pendingUpdate(version: '1.0.0');
      await service(api, now: start.add(const Duration(hours: 1)))
          .pendingUpdate(version: '1.0.0', throttle: true);

      expect(api.calls, 1, reason: 'ikkinchisi tarmoqqa chiqmadi');

      await service(api, now: start.add(const Duration(hours: 7)))
          .pendingUpdate(version: '1.0.0', throttle: true);

      expect(api.calls, 2, reason: '6 soatdan keyin yana so\'radi');
    });

    test('TARMOQ yiqilsa — null, va oraliq BOSHLANMAYDI', () async {

      final api = _FakeApi(null);
      final start = DateTime(2026, 9, 5, 12);

      expect(
        await service(api, now: start).pendingUpdate(version: '1.0.0'),
        isNull,
      );

      api.response = AppUpdateInfo.fromJson(payload());
      final info = await service(api, now: start.add(const Duration(minutes: 1)))
          .pendingUpdate(version: '1.0.0', throttle: true);

      expect(info, isNotNull, reason: 'darhol qayta urinadi');
    });

    test('qurilma versiyasi serverga YUBORILADI', () async {
      final api = _FakeApi(AppUpdateInfo.fromJson(payload()));

      await service(api).pendingUpdate(version: '1.0.0');

      expect(api.askedVersion, '1.0.0');
    });
  });

  group('«Keyinroq»', () {
    test('24 soat jim, keyin yana chiqadi', () async {
      final api = _FakeApi(AppUpdateInfo.fromJson(payload(latest: '1.0.1')));
      final start = DateTime(2026, 9, 5, 12);

      final info = await service(api, now: start).pendingUpdate(version: '1.0.0');
      await service(api, now: start).snooze(info!);

      expect(
        await service(api, now: start.add(const Duration(hours: 5)))
            .pendingUpdate(version: '1.0.0'),
        isNull,
      );
      expect(
        await service(api, now: start.add(const Duration(hours: 25)))
            .pendingUpdate(version: '1.0.0'),
        isNotNull,
      );
    });

    test('YANGI versiya chiqsa jimlik BEKOR bo\'ladi', () async {

      final api = _FakeApi(AppUpdateInfo.fromJson(payload(latest: '1.0.1')));
      final start = DateTime(2026, 9, 5, 12);

      final first = await service(api, now: start).pendingUpdate(version: '1.0.0');
      await service(api, now: start).snooze(first!);

      api.response = AppUpdateInfo.fromJson(payload(latest: '1.0.2'));
      final second = await service(api, now: start.add(const Duration(hours: 1)))
          .pendingUpdate(version: '1.0.0');

      expect(second, isNotNull);
      expect(second!.latestVersion, '1.0.2');
    });

    test('MAJBURIY yangilanish hech qachon jim qilinmaydi', () async {
      final api = _FakeApi(AppUpdateInfo.fromJson(payload(status: 'required')));
      final start = DateTime(2026, 9, 5, 12);

      final info = await service(api, now: start).pendingUpdate(version: '1.0.0');

      await service(api, now: start).snooze(info!);

      expect(
        await service(api, now: start.add(const Duration(minutes: 1)))
            .pendingUpdate(version: '1.0.0'),
        isNotNull,
      );
    });
  });

  group('Oyna', () {
    Future<void> pump(WidgetTester tester, AppUpdateInfo info) async {
      await tester.pumpWidget(TranslationProvider(
        child: ScreenUtilInit(
          designSize: const Size(428, 926),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, __) => MaterialApp(
            home: Scaffold(
              body: AppUpdateSheet(
                info: info,
                onUpdate: () {},
                onLater: info.isForced ? null : () {},
              ),
            ),
          ),
        ),
      ));
      await tester.pump();
    }

    testWidgets('IXTIYORIY — ikkala tugma ham bor', (tester) async {
      await pump(tester, AppUpdateInfo.fromJson(payload()));

      expect(find.text('Yangi versiya tayyor'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Yangilash'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Keyinroq'), findsOneWidget);
    });

    testWidgets('MAJBURIY — «Keyinroq» YO\'Q', (tester) async {
      await pump(tester, AppUpdateInfo.fromJson(payload(status: 'required')));

      expect(find.text('Yangilash talab qilinadi'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Yangilash'), findsOneWidget);
      expect(find.text('Keyinroq'), findsNothing);
    });

    testWidgets('ikkala versiya ham ko\'rinadi', (tester) async {
      await pump(tester, AppUpdateInfo.fromJson(payload()));

      expect(find.text('1.0.0'), findsOneWidget);
      expect(find.text('1.0.1'), findsOneWidget);
    });

    testWidgets('izohlar bo\'lsa — ro\'yxat chiqadi', (tester) async {
      await pump(tester, AppUpdateInfo.fromJson(
        payload(notes: ['Kafel narxlari', 'Bildirishnomalar tuzatildi']),
      ));

      expect(find.text('NIMA YANGILANDI'), findsOneWidget);
      expect(find.text('Kafel narxlari'), findsOneWidget);
      expect(find.text('Bildirishnomalar tuzatildi'), findsOneWidget);
    });

    testWidgets('IZOHSIZ — bo\'sh bo\'lim EMAS, tushuntirish qoladi',
        (tester) async {

      await pump(tester, AppUpdateInfo.fromJson(payload()));

      expect(find.text('NIMA YANGILANDI'), findsNothing);
      expect(find.textContaining('yangi versiyasi chiqdi'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Yangilash'), findsOneWidget);
    });

    testWidgets('MAJBURIYda izohsiz ham sabab aytiladi', (tester) async {
      await pump(tester, AppUpdateInfo.fromJson(payload(status: 'required')));

      expect(find.textContaining('qo\'llab-quvvatlanmaydi'), findsOneWidget);
    });

    testWidgets('layout xatosi yo\'q — uzun izohlar bilan ham',
        (tester) async {
      await pump(tester, AppUpdateInfo.fromJson(payload(notes: [
        for (var i = 1; i <= 12; i++)
          '$i-yangilik: ancha uzun matn, ekranga bir qatorda sig\'maydi',
      ])));

      expect(tester.takeException(), isNull);
    });
  });

  group('Varaqdan CHIQISH', () {

    late bool snoozed;
    late bool? result;

    Future<void> open(WidgetTester tester, {required bool forced}) async {
      snoozed = false;
      result = null;
      final info = AppUpdateInfo.fromJson(
        payload(status: forced ? 'required' : 'optional'),
      );

      await tester.pumpWidget(TranslationProvider(
        child: ScreenUtilInit(
          designSize: const Size(428, 926),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, __) => MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      result = await AppUpdateSheet.show(
                        context,
                        info: info,
                        onLater: () async => snoozed = true,
                      );
                    },
                    child: const Text('och'),
                  ),
                ),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('och'));
      await tester.pumpAndSettle();
      expect(find.byType(AppUpdateSheet), findsOneWidget);
    }

    testWidgets('MAJBURIY — tashqariga bosish YOPMAYDI', (tester) async {
      await open(tester, forced: true);

      await tester.tapAt(const Offset(8, 8));
      await tester.pumpAndSettle();

      expect(find.byType(AppUpdateSheet), findsOneWidget);
    });

    testWidgets('MAJBURIY — «orqaga» ham YOPMAYDI', (tester) async {
      await open(tester, forced: true);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.byType(AppUpdateSheet), findsOneWidget);
    });

    testWidgets('IXTIYORIY — tashqariga bosish yopadi', (tester) async {
      await open(tester, forced: false);

      await tester.tapAt(const Offset(8, 8));
      await tester.pumpAndSettle();

      expect(find.byType(AppUpdateSheet), findsNothing);
    });

    testWidgets('«Yangilash» — do\'kon ochilishini bildiradi', (tester) async {
      await open(tester, forced: false);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Yangilash'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
      expect(snoozed, isFalse, reason: 'yangilaganda jimlik yozilmaydi');
    });

    testWidgets('«Keyinroq» — jimlik YOZILADI', (tester) async {
      await open(tester, forced: false);

      await tester.tap(find.widgetWithText(TextButton, 'Keyinroq'));
      await tester.pumpAndSettle();

      expect(snoozed, isTrue);
      expect(result, isFalse);
      expect(find.byType(AppUpdateSheet), findsNothing);
    });
  });
}
