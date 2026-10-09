
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/core/design_sytem/dark_colors.dart';
import 'package:ustachi/core/design_sytem/light_colors.dart';
import 'package:ustachi/core/design_sytem/open_colors.dart';
import 'package:ustachi/core/design_sytem/open_typographies.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'support/l10n_harness.dart';

Widget _harness({required bool dark, required Widget child}) {
  final colors = dark ? OpenColors.dark : OpenColors.light;
  return ScreenUtilInit(
    designSize: const Size(428, 926),
    minTextAdapt: true,
    splitScreenMode: true,

    builder: (_, __) => TranslationProvider(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: dark ? Brightness.dark : Brightness.light,
          extensions: [
            colors,
            OpenTypographies.fromColors(
              dark ? DarkNeutralColor() : LightNeutralColor(),
              dark ? DarkUncategorizedColor() : LightUncategorizedColor(),
            ),
          ],
        ),
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(ChizmaSpace.lg),
            child: child,
          ),
        ),
      ),
    ),
  );
}

Widget get _gallery => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ChizmaEyebrow('Tezkor amallar'),
        const SizedBox(height: ChizmaSpace.md),
        const IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ChizmaActionCard(
                  icon: Icons.calculate_outlined,
                  title: 'Narx hisoblash',
                  subtitle: 'Rom, oyna va profil narxi',
                ),
              ),
              SizedBox(width: ChizmaSpace.md),
              Expanded(
                child: ChizmaActionCard(
                  icon: Icons.handyman_outlined,
                  title: 'Usta topish',
                  subtitle: 'Tekshirilgan ustalar',
                  brass: true,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: ChizmaSpace.md),
        ChizmaRowGroup(rows: [
          ChizmaListRow(
            leading: const ChizmaIconTile(icon: Icons.inventory_2_outlined),
            title: 'Mahsulot narxlari',
            subtitle: const Text('Profil, shisha, aksesuar'),
            trailing: const ChizmaBadge('Yangilandi'),
            showChevron: true,
            onTap: () {},
          ),
          ChizmaListRow(
            leading: const ChizmaIconTile(icon: Icons.window_outlined),

            title: 'Balkon romi, 3 tavaqa, termo profil, ikki qavat oyna',
            subtitle: const Text('#UT-2418 · 18-iyul'),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: const [
                ChizmaPrice('4 250 000'),
                SizedBox(height: ChizmaSpace.xs),
                ChizmaStatusPill('Bajarildi', status: ChizmaStatus.done),
              ],
            ),
            onTap: () {},
          ),
        ]),
        const SizedBox(height: ChizmaSpace.lg),
        const ChizmaSectionHeader(
            title: 'Oxirgi buyurtmalar', actionLabel: 'Barchasi'),
        const SizedBox(height: ChizmaSpace.md),
        Wrap(
          spacing: ChizmaSpace.sm,
          runSpacing: ChizmaSpace.sm,
          children: const [
            ChizmaChip(
                label: 'Rom', icon: Icons.window_outlined, selected: true),
            ChizmaChip(label: 'Mebel', icon: Icons.chair_outlined),
            ChizmaChip(label: 'Elektrika', icon: Icons.bolt_outlined),
            ChizmaChip(label: 'Santexnika', icon: Icons.plumbing_outlined),
          ],
        ),
        const SizedBox(height: ChizmaSpace.lg),
        const Row(
          children: [
            Expanded(child: ChizmaStatTile(label: 'Bajarilgan', value: '124')),
            SizedBox(width: ChizmaSpace.sm),
            Expanded(child: ChizmaStatTile(label: 'Tajriba', value: '8 yil')),
            SizedBox(width: ChizmaSpace.sm),
            Expanded(child: ChizmaStatTile(label: 'Qayta aloqa', value: '92%')),
          ],
        ),
        const SizedBox(height: ChizmaSpace.lg),
        const ChizmaSheet(child: ChizmaPrice('12 480 000', large: true)),
      ],
    );

void main() {
  for (final dark in [false, true]) {
    final name = dark ? "qorong'u" : "yorug'";

    testWidgets('Chizma komponentlari layout xatosiz — $name', (tester) async {
      await tester.binding.setSurfaceSize(const Size(428, 1400));
      await tester.pumpWidget(_harness(dark: dark, child: _gallery));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('Chizma TOR ekranda ham xatosiz — $name', (tester) async {

      await tester.binding.setSurfaceSize(const Size(320, 1400));
      await tester.pumpWidget(_harness(dark: dark, child: _gallery));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
