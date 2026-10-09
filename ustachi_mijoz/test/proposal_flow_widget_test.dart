import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_generator.dart';
import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_models.dart';
import 'package:ustachi/features/calculate_prices/presentation/view/proposal_results_page.dart';
import 'package:ustachi/features/calculate_prices/presentation/view/proposal_wizard_page.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/frame_drawing.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/proposal/proposal_option_card.dart';
import 'package:ustachi/features/marketplace/domain/order_draft.dart';
import 'package:ustachi/features/marketplace/presentation/view/proposal_detail_page.dart';

const _request = ProposalRequest(
  type: ProposalType.window,
  widthMm: 1500,
  heightMm: 1400,
);

Future<void> _pump(WidgetTester tester, Widget home) async {
  tester.view.physicalSize = const Size(428, 926);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(TranslationProvider(
    child: ScreenUtilInit(
      designSize: const Size(428, 926),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) => MaterialApp(home: home),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => sl.registerSingleton<OrderDraftStore>(OrderDraftStore()));
  tearDown(sl.reset);

  testWidgets(
      'sehrgar: shakl → material → o\'lcham → tokcha → rang, narx tanlovi yo\'q',
      (tester) async {
    await _pump(tester, const ProposalWizardPage());

    final titles = <String>[];
    String title() => tester
        .widget<Text>(find.descendant(
            of: find.byType(AppBar), matching: find.byType(Text)))
        .data!;
    Future<void> next() async {
      await tester.tap(find.widgetWithText(ElevatedButton, 'Keyingisi'));
      await tester.pumpAndSettle();
    }

    titles.add(title());
    await next();

    titles.add(title());
    expect(find.text('Qadam 2 / 5'), findsOneWidget);
    expect(find.text('Plastik (PVX)'), findsOneWidget);
    expect(find.text('Alyuminiy'), findsOneWidget);
    expect(find.text('Termo (issiq alyuminiy)'), findsOneWidget);
    expect(find.text('Tez kunda'), findsOneWidget);
    expect(find.textContaining('narx'), findsNothing);

    IconData radioOf(String name) => tester
        .widget<Icon>(find
            .descendant(
              of: find.ancestor(
                  of: find.text(name), matching: find.byType(Row)),
              matching: find.byWidgetPredicate((w) =>
                  w is Icon &&
                  (w.icon == Icons.radio_button_checked_rounded ||
                      w.icon == Icons.radio_button_unchecked_rounded)),
            )
            .first)
        .icon!;
    expect(radioOf('Alyuminiy'), Icons.radio_button_checked_rounded);
    await tester.tap(find.text('Plastik (PVX)'));
    await tester.pumpAndSettle();
    expect(radioOf('Plastik (PVX)'), Icons.radio_button_checked_rounded);
    expect(radioOf('Alyuminiy'), Icons.radio_button_unchecked_rounded);

    await tester.tap(find.text('Termo (issiq alyuminiy)'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(radioOf('Plastik (PVX)'), Icons.radio_button_checked_rounded);

    for (var i = 0; i < 3; i++) {
      await next();
      titles.add(title());
    }

    expect(titles, [
      'Rom shakli',
      'Qaysi materialdan?',
      'O\'lchamini kiriting',
      'Tokcha kerakmi?',
      'Rang tanlang',
    ]);
    expect(find.widgetWithText(ElevatedButton, 'Variantlarni ko\'rish'),
        findsOneWidget);
    expect(find.textContaining('narx'), findsNothing);
    expect(find.textContaining('Brend'), findsNothing);
  });

  testWidgets('variantlar: chizmalar ro\'yxati, narx yo\'q', (tester) async {
    final options = const ProposalGenerator().generate(_request);
    await _pump(tester, const ProposalResultsPage(request: _request));

    expect(find.text('${options.length} ta variant topildi'), findsOneWidget);
    expect(find.byType(ProposalOptionCard), findsWidgets);
    expect(find.byType(FrameDrawing), findsWidgets);
    expect(find.textContaining('so\'m'), findsNothing);
    expect(find.textContaining('narxni usta aytadi'), findsOneWidget);
  });

  testWidgets('rom tafsiloti: narxsiz savatga tushadi', (tester) async {
    final option = const ProposalGenerator().generate(_request).first;
    var checkout = 0;
    await _pump(
      tester,
      ProposalDetailPage(
        option: option,
        request: _request,
        onCheckout: () => checkout++,
      ),
    );

    expect(find.byType(FrameDrawing), findsOneWidget);
    expect(find.text('Narxni usta aytadi'), findsOneWidget);
    expect(find.text('Material'), findsOneWidget);
    expect(find.text('Plastik'), findsOneWidget);
    expect(find.textContaining('so\'m'), findsNothing);

    await tester.tap(find.text('Davom etish'));
    await tester.pump();

    final draft = sl<OrderDraftStore>().value;
    expect(checkout, 1);
    expect(draft.productCount, 1);
    expect(draft.toProposalJson()['material'], 0);
    expect(draft.toProposalJson().containsKey('total_price'), isFalse);
  });
}
