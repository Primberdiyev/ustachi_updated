import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:flutter/services.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/router/app_router.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/features/calculate_prices/domain/proposals/door_width_advice.dart';
import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_dimension_edit.dart';
import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_layouts.dart';
import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_models.dart'
    hide proposalMinSideMm, proposalMaxWidthMm, proposalMaxHeightMm;
import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_palette.dart';
import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_templates.dart';
import 'package:ustachi/features/calculate_prices/presentation/view/proposal_back_navigation.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/calculate_ui_models.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/frame_drawing.dart';
import 'package:ustachi/features/marketplace/domain/entities/specialty_entity.dart';
import 'package:ustachi/features/marketplace/domain/specialty_catalog.dart';
import 'package:ustachi/features/repair/presentation/view/repair_order_page.dart';

class ProposalWizardPage extends StatefulWidget {
  const ProposalWizardPage({super.key});

  @override
  State<ProposalWizardPage> createState() => _ProposalWizardPageState();
}

enum _RomShape {
  deraza(ProposalShape.deraza, 'Oyna — ochiladigan yoki qo\'zg\'almas'),
  eshik(ProposalShape.eshik, 'Balkon yoki kirish eshigi'),
  arka(ProposalShape.arka, 'Tepasi yoy (kamarli) rom'),
  fEshik(ProposalShape.fEshik, 'Eshik chetda, yonida deraza'),
  tEshik(ProposalShape.tEshik, 'Eshik o\'rtada, ikki yonida deraza'),
  vitraj(ProposalShape.vitraj,
      'Katta fasad romi (ayvon, do\'kon) — 6 m dan uzunida o\'rtada eshik');

  const _RomShape(this.shape, this.subtitle);

  final ProposalShape shape;
  final String subtitle;

  FramePreviewSpec get sample => _shapeSamples[this]!;

  String get title => shape.title;

  bool get isBalkon => shape.isBalcony;

  bool get hasDoorSide => shape == ProposalShape.fEshik;
}

ProposalTemplate _template(List<ProposalTemplate> list, String title) =>
    list.firstWhere((t) => t.title == title, orElse: () => list.first);

final _shapeSamples = <_RomShape, FramePreviewSpec>{
  _RomShape.deraza:
      _template(proposalWindowTemplates, '2 bo\'lmali, ikkisi ochiladi')
          .buildSpec(1500, 1400),
  _RomShape.eshik: _template(proposalDoorTemplates, 'Pastki panelli eshik')
      .buildSpec(900, 2100),
  _RomShape.arka: _template(proposalArchTemplates, 'Arka, juft ochiluvchi')
      .buildSpec(1500, 1900),
  _RomShape.fEshik:
      proposalTemplatesFor(ProposalType.door, 2500, 2300, floorGapMm: 800)
          .first
          .buildSpec(2500, 2300),
  _RomShape.tEshik: proposalTemplatesFor(ProposalType.door, 3600, 2500,
          floorGapMm: 800, tShape: true)
      .first
      .buildSpec(3600, 2500),
  _RomShape.vitraj: proposalTemplatesFor(ProposalType.window, 4000, 3000)
      .first
      .buildSpec(4000, 3000),
};

class _ProposalWizardPageState extends State<ProposalWizardPage> {
  _RomShape _shape = _RomShape.deraza;

  bool get _hasSillStep =>
      _req.type == ProposalType.window || _req.floorGapMm > 0;

  int get _stepCount => _hasSillStep ? 5 : 4;

  List<String> get _titles => [
        'Rom shakli',
        'Qaysi materialdan?',
        'O\'lchamini kiriting',
        if (_hasSillStep) 'Tokcha kerakmi?',
        'Rang tanlang',
      ];

  static const _windowDefault = (w: 1500, h: 1400);
  static const _doorDefault = (w: 900, h: 2100);
  static const _archDefault = (w: 1500, h: 2200);

  int _step = 0;

  ProposalRequest _req = const ProposalRequest(
    type: ProposalType.window,
    widthMm: 1500,
    heightMm: 1400,
    material: 1,
    hasSill: true,
    sillWidthCm: 35,
  );

  ProposalColor _color = ProposalColor.white;

  late final _widthCtrl = TextEditingController(text: _req.widthMm.toString());
  late final _heightCtrl =
      TextEditingController(text: _req.heightMm.toString());
  late final _gapCtrl = TextEditingController();

  @override
  void dispose() {
    _widthCtrl.dispose();
    _heightCtrl.dispose();
    _gapCtrl.dispose();
    super.dispose();
  }

  void _setShape(_RomShape shape) {
    if (shape == _shape) return;
    final (type, d, gap, doorRight) = switch (shape) {
      _RomShape.deraza => (ProposalType.window, _windowDefault, 0, true),
      _RomShape.eshik => (ProposalType.door, _doorDefault, 0, true),
      _RomShape.arka => (ProposalType.arch, _archDefault, 0, true),

      _RomShape.fEshik => (ProposalType.door, (w: 2500, h: 2300), 800, true),
      _RomShape.tEshik => (ProposalType.door, (w: 3600, h: 2500), 800, true),
      _RomShape.vitraj => (ProposalType.window, (w: 4000, h: 3000), 0, true),
    };
    setState(() {
      _shape = shape;

      _req = _req.copyWith(
        type: type,
        shape: shape.shape,
        widthMm: d.w,
        heightMm: d.h,
        floorGapMm: gap,
        doorOnRight: doorRight,
        hasSill: type == ProposalType.window || gap > 0,
      );
      _widthCtrl.text = d.w.toString();
      _heightCtrl.text = d.h.toString();
      _gapCtrl.text = gap > 0 ? gap.toString() : '';
    });
  }

  void _openRepair() {
    final specialty = sl<SpecialtyCatalog>().value.firstWhere(
          (s) => s.isRom,
          orElse: () => const SpecialtyEntity(
            id: 0,
            code: SpecialtyEntity.romCode,
            name: 'Alyumin va PVX eshik va rom ustasi',
          ),
        );
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: repairOrderRouteName),
        builder: (_) => RepairOrderPage(specialty: specialty),
      ),
    );
  }

  bool get _canProceed {
    if (_titles[_step] == 'O\'lchamini kiriting') {
      final sizesOk = _req.widthMm >= proposalMinSideMm &&
          _req.widthMm <= proposalMaxWidthMm &&
          _req.heightMm >= proposalMinSideMm &&
          _req.heightMm <= proposalMaxHeightMm;
      if (!sizesOk) return false;
      if (_shape.isBalkon) {

        return _req.floorGapMm >= 300 &&
            _req.floorGapMm <= _req.heightMm - 1000;
      }
      return true;
    }
    return true;
  }

  void _next() {
    FocusScope.of(context).unfocus();
    if (!_canProceed) return;
    if (_step < _stepCount - 1) {
      setState(() => _step++);
    } else {
      _finish();
    }
  }

  void _back() {
    FocusScope.of(context).unfocus();
    if (_step == 0) {
      context.maybePopSafe();
      return;
    }
    setState(() => _step--);
  }

  void _finish() {

    final request = _req.copyWith(
      shape: normalizedProposalShape(_req.shape, _req.widthMm, _req.heightMm),
    );
    context.pushRouteSafe(ProposalResultsPageRoute(request: request));
  }

  void _selectColor(ProposalColor c) {
    setState(() {
      _color = c;
      _req = _req.copyWith(
          colorKey: c.colorKey, colorArgb: c.argb, colorLabel: c.label);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.color;

    return Scaffold(
      backgroundColor: colors.neutral.black7,
      appBar: AppBar(
        leading: BackButton(onPressed: _back),
        title: Text(_titles[_step]),
      ),
      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.fromLTRB(
                ChizmaSpace.lg, ChizmaSpace.sm, ChizmaSpace.lg, ChizmaSpace.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(ChizmaRadius.pill),
                  child: LinearProgressIndicator(
                    value: (_step + 1) / _stepCount,
                    minHeight: 6,
                    backgroundColor: colors.neutral.surface2,
                    color: colors.categorizedColor.primary,
                  ),
                ),
                const SizedBox(height: ChizmaSpace.sm),
                Text(
                  'Qadam ${_step + 1} / $_stepCount',
                  style: context.text.label
                      .copyWith(color: colors.neutral.textMuted),
                ),
              ],
            ),
          ),

          Expanded(
            child: IndexedStack(
              index: _step,
              sizing: StackFit.expand,
              children: [
                _ShapeStep(
                  value: _shape,
                  onChanged: _setShape,
                  onRepair: _openRepair,
                ),
                _MaterialStep(
                  value: _req.material,
                  onChanged: (m) =>
                      setState(() => _req = _req.copyWith(material: m)),
                ),
                _SizeStep(
                  type: _req.type,
                  isVitraj: _shape == _RomShape.vitraj,

                  wideDoorWarning: proposalIsWideSingleDoor(
                    shape: _shape.shape,
                    widthMm: _req.widthMm,
                  )
                      ? proposalWideSingleDoorText
                      : null,

                  fixedSideDoor: _req.fixedSideDoor,
                  onFixedSideDoor: (v) =>
                      setState(() => _req = _req.copyWith(fixedSideDoor: v)),
                  widthCtrl: _widthCtrl,
                  heightCtrl: _heightCtrl,
                  gapCtrl: _shape.isBalkon ? _gapCtrl : null,
                  doorOnRight: _shape.hasDoorSide ? _req.doorOnRight : null,
                  onDoorSide: (right) =>
                      setState(() => _req = _req.copyWith(doorOnRight: right)),
                  onWidth: (v) =>
                      setState(() => _req = _req.copyWith(widthMm: v)),
                  onHeight: (v) =>
                      setState(() => _req = _req.copyWith(heightMm: v)),
                  onGap: (v) =>
                      setState(() => _req = _req.copyWith(floorGapMm: v)),
                ),
                if (_hasSillStep)
                  _SillStep(
                    hasSill: _req.hasSill,
                    widthCm: _req.sillWidthCm,
                    widths: proposalSillWidthsCm,
                    onChanged: (v) =>
                        setState(() => _req = _req.copyWith(hasSill: v)),
                    onWidth: (cm) =>
                        setState(() => _req = _req.copyWith(sillWidthCm: cm)),
                  ),
                _ColorStep(
                  palette: proposalColors,
                  selected: _color,
                  onSelect: _selectColor,
                ),
              ],
            ),
          ),

          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(ChizmaSpace.lg, ChizmaSpace.sm,
                  ChizmaSpace.lg, ChizmaSpace.md),
              child: Row(
                children: [
                  if (_step > 0) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _back,
                        child: const Text('Orqaga'),
                      ),
                    ),
                    const SizedBox(width: ChizmaSpace.md),
                  ],
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _canProceed ? _next : null,
                      child: Text(_step < _stepCount - 1
                          ? 'Keyingisi'
                          : 'Variantlarni ko\'rish'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectCard extends StatelessWidget {
  const _SelectCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final primary = colors.categorizedColor.primary;
    return ChizmaSheet(
      onTap: onTap,
      borderColor: selected ? primary : null,
      color: selected ? primary.withValues(alpha: 0.06) : null,
      child: Row(
        children: [
          ChizmaIconTile(icon: icon, filled: selected, size: 48),
          const SizedBox(width: ChizmaSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: context.text.h4
                      .copyWith(color: colors.neutral.textStrong),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: context.text.body5
                      .copyWith(color: colors.neutral.textMuted),
                ),
              ],
            ),
          ),
          Icon(
            selected
                ? Icons.radio_button_checked_rounded
                : Icons.radio_button_unchecked_rounded,
            color: selected ? primary : colors.neutral.border,
          ),
        ],
      ),
    );
  }
}

class _StepBody extends StatelessWidget {
  const _StepBody({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          ChizmaSpace.lg, 0, ChizmaSpace.lg, ChizmaSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _ShapeStep extends StatelessWidget {
  const _ShapeStep({
    required this.value,
    required this.onChanged,
    required this.onRepair,
  });

  final _RomShape value;
  final ValueChanged<_RomShape> onChanged;

  final VoidCallback onRepair;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          ChizmaSpace.lg, 0, ChizmaSpace.lg, ChizmaSpace.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Romning asosiy shaklini tanlang',
            style: context.text.h4.copyWith(color: colors.neutral.textStrong),
          ),
          const SizedBox(height: 2),
          Text(
            'Rasmga qarab uyingizdagi romga eng yaqin shaklni belgilang — '
            'aniq bo\'linishlarni keyin o\'zimiz taklif qilamiz.',
            style: context.text.body5.copyWith(color: colors.neutral.textMuted),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: ChizmaSpace.sm),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                const cross = 2;

                final cells = _RomShape.values.length + 1;
                final rows = (cells / cross).ceil();
                final cellW =
                    (constraints.maxWidth - (cross - 1) * ChizmaSpace.sm) /
                        cross;
                final cellH =
                    (constraints.maxHeight - (rows - 1) * ChizmaSpace.sm) /
                        rows;
                if (cellH <= 40) return const SizedBox.shrink();
                return GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: cross,
                  mainAxisSpacing: ChizmaSpace.sm,
                  crossAxisSpacing: ChizmaSpace.sm,
                  childAspectRatio: cellW / cellH,
                  children: [
                    for (final shape in _RomShape.values)
                      _ShapeCard(
                        shape: shape,
                        selected: value == shape,
                        onTap: () => onChanged(shape),
                      ),

                    _RepairCard(onTap: onRepair),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RepairCard extends StatelessWidget {
  const _RepairCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final primary = colors.categorizedColor.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ChizmaRadius.md),
      child: Container(
        padding: ChizmaBorder.safePadding(
          const EdgeInsets.all(ChizmaSpace.sm),
          1,
        ),
        decoration: BoxDecoration(
          color: colors.neutral.surface,
          borderRadius: BorderRadius.circular(ChizmaRadius.md),
          border: Border.all(color: primary.withValues(alpha: 0.6)),
        ),
        child: LayoutBuilder(
          builder: (context, c) {
            final showSubtitle = c.maxHeight >= 150;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(ChizmaRadius.sm),
                    child: Container(
                      width: double.infinity,
                      color: primary.withValues(alpha: 0.08),
                      child: Center(
                        child: Icon(
                          Icons.build_outlined,
                          size: 34,
                          color: primary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: ChizmaSpace.xs),
                Text(
                  'Ta\'mir',
                  style: context.text.label.copyWith(
                    fontWeight: FontWeight.w700,
                    color: primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (showSubtitle)
                  Text(
                    'Eskisini tuzatish',
                    style: context.text.label
                        .copyWith(color: colors.neutral.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ShapeCard extends StatelessWidget {
  const _ShapeCard({
    required this.shape,
    required this.selected,
    required this.onTap,
  });

  final _RomShape shape;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final primary = colors.categorizedColor.primary;
    final borderWidth = selected ? 2.0 : 1.0;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ChizmaRadius.md),
      child: Container(
        padding: ChizmaBorder.safePadding(
          const EdgeInsets.all(ChizmaSpace.sm),
          borderWidth,
        ),
        decoration: BoxDecoration(
          color: colors.neutral.surface,
          borderRadius: BorderRadius.circular(ChizmaRadius.md),
          border: Border.all(
            color: selected ? primary : colors.neutral.border,
            width: borderWidth,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, c) {

            final showSubtitle = c.maxHeight >= 150;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(ChizmaRadius.sm),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: Theme.of(context).brightness ==
                                  Brightness.dark
                              ? const [Color(0xFF1D2733), Color(0xFF151D26)]
                              : const [Color(0xFFF6F9FC), Color(0xFFE6EEF6)],
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Padding(
                              padding: const EdgeInsets.all(ChizmaSpace.sm),
                              child: Center(
                                  child: FrameDrawing(spec: shape.sample)),
                            ),
                          ),
                          if (selected)
                            Positioned(
                              top: ChizmaSpace.xs,
                              right: ChizmaSpace.xs,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check_rounded,
                                    size: 14, color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: ChizmaSpace.xs),
                Text(
                  shape.title,
                  style: context.text.label.copyWith(
                    fontWeight: FontWeight.w700,
                    color: selected ? primary : colors.neutral.textStrong,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (showSubtitle)
                  Text(
                    shape.subtitle,
                    style: context.text.label
                        .copyWith(color: colors.neutral.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MaterialStep extends StatelessWidget {
  const _MaterialStep({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  static const _materials = [

    (
      id: 1,
      name: 'Alyuminiy',
      asset: 'assets/images/alumin.png',
      desc: 'Yengil va mustahkam, dizayn jihatdan har qanday xonaga mos.',

      when: '',
    ),
    (
      id: 0,
      name: 'Plastik (PVX)',
      asset: 'assets/images/plast.png',
      desc: 'Issiq va shovqindan yaxshi himoya qiladi.',
      when: 'Uy-joy deraza va balkonlari uchun — eng ommabop tanlov.',
    ),
    (
      id: 2,
      name: 'Termo (issiq alyuminiy)',
      asset: 'assets/images/termo.png',
      desc: 'Issiqlik ko\'prigi uzilgan alyuminiy — mustahkam va issiq saqlaydi.',
      when: 'Kirish eshiklari va isitiladigan xonalar uchun premium tanlov.',
    ),
  ];

  static const _comingSoon = {2};

  @override
  Widget build(BuildContext context) {
    return _StepBody(
      children: [
        for (final m in _materials) ...[
          _MaterialCard(
            name: m.name,
            asset: m.asset,
            desc: m.desc,
            when: m.when,
            selected: value == m.id,
            comingSoon: _comingSoon.contains(m.id),
            onTap: () => onChanged(m.id),
          ),
          const SizedBox(height: ChizmaSpace.md),
        ],
      ],
    );
  }
}

class _MaterialCard extends StatelessWidget {
  const _MaterialCard({
    required this.name,
    required this.asset,
    required this.desc,
    required this.when,
    required this.selected,
    required this.onTap,
    this.comingSoon = false,
  });

  final String name;
  final String asset;
  final String desc;
  final String when;
  final bool selected;
  final VoidCallback onTap;

  final bool comingSoon;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final primary = colors.categorizedColor.primary;
    if (comingSoon) {
      return Stack(
        children: [
          Opacity(
            opacity: 0.45,
            child: _MaterialCard(name: name, asset: asset, desc: desc, when: when, selected: false, onTap: () {}),
          ),

          Positioned.fill(child: AbsorbPointer(child: Container(color: Colors.transparent))),
          Positioned(
            top: ChizmaSpace.sm,
            right: ChizmaSpace.sm,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colors.neutral.surface2,
                borderRadius: BorderRadius.circular(ChizmaRadius.pill),
                border: Border.all(color: colors.neutral.border),
              ),
              child: Text(
                'Tez kunda',
                style: context.text.label.copyWith(color: colors.neutral.textBody, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      );
    }
    return ChizmaSheet(
      onTap: onTap,
      borderColor: selected ? primary : null,
      color: selected ? primary.withValues(alpha: 0.06) : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          ClipRRect(
            borderRadius: BorderRadius.circular(ChizmaRadius.md),
            child: Container(
              width: 112,
              height: 112,
              color: Colors.white,
              child: Image.asset(
                asset,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(Icons.window_outlined,
                    size: 40, color: colors.neutral.textMuted),
              ),
            ),
          ),
          const SizedBox(width: ChizmaSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: context.text.h4
                            .copyWith(color: colors.neutral.textStrong),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      selected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 20,
                      color: selected ? primary : colors.neutral.border,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: context.text.body5
                      .copyWith(color: colors.neutral.textBody),
                ),

                if (when.isNotEmpty) ...[
                  const SizedBox(height: ChizmaSpace.sm),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.recommend_outlined, size: 16, color: primary),
                      const SizedBox(width: ChizmaSpace.sm),
                      Expanded(
                        child: Text(
                          when,
                          style: context.text.body5
                              .copyWith(color: colors.neutral.textMuted),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SizeStep extends StatelessWidget {
  const _SizeStep({
    required this.type,
    required this.isVitraj,
    required this.widthCtrl,
    required this.heightCtrl,
    required this.onWidth,
    required this.onHeight,
    this.gapCtrl,
    this.onGap,
    this.doorOnRight,
    this.onDoorSide,
    this.wideDoorWarning,
    this.fixedSideDoor = false,
    this.onFixedSideDoor,
  });

  final ProposalType type;

  final String? wideDoorWarning;

  final bool fixedSideDoor;
  final ValueChanged<bool>? onFixedSideDoor;

  final bool isVitraj;

  final TextEditingController widthCtrl;
  final TextEditingController heightCtrl;
  final ValueChanged<int> onWidth;
  final ValueChanged<int> onHeight;

  final TextEditingController? gapCtrl;
  final ValueChanged<int>? onGap;

  final bool? doorOnRight;
  final ValueChanged<bool>? onDoorSide;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return _StepBody(
      children: [
        Text(
          'O\'lchamni millimetrda kiriting',
          style: context.text.body4.copyWith(color: colors.neutral.textBody),
        ),
        const SizedBox(height: ChizmaSpace.lg),
        _DimField(
          label: 'Eni — kenglik',
          icon: Icons.swap_horiz_rounded,
          controller: widthCtrl,
          onChanged: onWidth,
        ),
        const SizedBox(height: ChizmaSpace.md),
        _DimField(
          label: 'Bo\'yi — balandlik',
          icon: Icons.height_rounded,
          controller: heightCtrl,
          onChanged: onHeight,
        ),
        if (wideDoorWarning != null) ...[
          const SizedBox(height: ChizmaSpace.md),
          _WarningBox(
            wideDoorWarning!,
            action: _AgreeToggle(
              label: 'Ha, qo\'zg\'almas qanotli variantlarni ham ko\'rsat',
              selected: fixedSideDoor,
              onChanged: onFixedSideDoor,
            ),
          ),
        ],
        if (gapCtrl != null) ...[
          const SizedBox(height: ChizmaSpace.md),

          _DimField(
            label: 'Derazadan yergacha masofa',
            icon: Icons.vertical_align_bottom_rounded,
            controller: gapCtrl!,
            onChanged: onGap ?? (_) {},
          ),
        ],
        if (doorOnRight != null) ...[
          const SizedBox(height: ChizmaSpace.md),
          Text(
            'Eshik qaysi tomonda?',
            style: context.text.label.copyWith(color: colors.neutral.textMuted),
          ),
          const SizedBox(height: ChizmaSpace.sm),
          Row(
            children: [
              for (final side in const [(false, 'Chapda'), (true, 'O\'ngda')])
                Padding(
                  padding: const EdgeInsets.only(right: ChizmaSpace.sm),
                  child: ChizmaChip(
                    label: side.$2,
                    selected: doorOnRight == side.$1,
                    onTap: () => onDoorSide?.call(side.$1),
                  ),
                ),
            ],
          ),
        ],
        const SizedBox(height: ChizmaSpace.lg),
        Text(
          'Tez tanlash (eni × bo\'yi)',
          style: context.text.label.copyWith(color: colors.neutral.textMuted),
        ),
        const SizedBox(height: ChizmaSpace.sm),

        ListenableBuilder(
          listenable: Listenable.merge([widthCtrl, heightCtrl]),
          builder: (context, _) {
            final width = int.tryParse(widthCtrl.text.trim());
            final height = int.tryParse(heightCtrl.text.trim());

            return Wrap(
              spacing: ChizmaSpace.sm,
              runSpacing: ChizmaSpace.sm,
              children: [
                for (final p in (switch ((type, isVitraj)) {
                  (ProposalType.door, _) => const [
                      (900, 2100),
                      (800, 2000),
                      (1200, 2200)
                    ],

                  (_, true) => const [
                      (4000, 3000),
                      (6000, 3000),
                      (8000, 3000),
                      (10000, 3200)
                    ],
                  _ => const [
                      (1500, 1400),
                      (1800, 1400),
                      (2100, 1500),
                      (1000, 1200)
                    ],
                }))
                  ChizmaChip(
                    label: '${p.$1}×${p.$2}',
                    selected: width == p.$1 && height == p.$2,
                    onTap: () {
                      widthCtrl.text = p.$1.toString();
                      heightCtrl.text = p.$2.toString();
                      onWidth(p.$1);
                      onHeight(p.$2);
                    },
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _WarningBox extends StatelessWidget {
  const _WarningBox(this.text, {this.action});

  final String text;

  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final warning = colors.categorizedColor.warning;
    return Container(
      padding: const EdgeInsets.all(ChizmaSpace.md),
      decoration: BoxDecoration(
        color: warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: warning, size: 22),
          const SizedBox(width: ChizmaSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  style: context.text.body5
                      .copyWith(color: colors.neutral.textStrong),
                ),
                if (action != null) ...[
                  const SizedBox(height: ChizmaSpace.sm),
                  action!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AgreeToggle extends StatelessWidget {
  const _AgreeToggle({
    required this.label,
    required this.selected,
    required this.onChanged,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final primary = colors.categorizedColor.primary;
    return InkWell(
      onTap: onChanged == null ? null : () => onChanged!(!selected),
      borderRadius: BorderRadius.circular(ChizmaRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: ChizmaSpace.md,
          vertical: ChizmaSpace.sm,
        ),
        decoration: BoxDecoration(
          color: selected
              ? primary.withValues(alpha: 0.1)
              : colors.neutral.surface,
          borderRadius: BorderRadius.circular(ChizmaRadius.md),
          border: Border.all(
              color: selected ? primary : colors.neutral.borderStrong),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected
                  ? Icons.check_box_rounded
                  : Icons.check_box_outline_blank_rounded,
              size: 20,
              color: selected ? primary : colors.neutral.textMuted,
            ),
            const SizedBox(width: ChizmaSpace.sm),
            Flexible(
              child: Text(
                label,
                style: context.text.label.copyWith(
                  color: colors.neutral.textStrong,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SillStep extends StatelessWidget {
  const _SillStep({
    required this.hasSill,
    required this.widthCm,
    required this.widths,
    required this.onChanged,
    required this.onWidth,
  });

  final bool hasSill;
  final int widthCm;
  final List<int> widths;
  final ValueChanged<bool> onChanged;
  final ValueChanged<int> onWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return _StepBody(
      children: [

        ClipRRect(
          borderRadius: BorderRadius.circular(ChizmaRadius.md),
          child: Container(
            height: 160,
            width: double.infinity,
            color: Colors.white,
            child: Image.asset(
              'assets/images/tokcha.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(Icons.window_outlined,
                  size: 48, color: context.color.neutral.textMuted),
            ),
          ),
        ),
        const SizedBox(height: ChizmaSpace.md),
        Text(
          'Tokcha — deraza tagiga ichkaridan o\'rnatiladigan keng plastik interyer. '
          'Deraza oldini ozoda tutadi, gul va buyumlar qo\'yish uchun qulay. '
          'Kengligini devoringiz qalinligiga qarab tanlaysiz.',
          style: context.text.body4.copyWith(color: colors.neutral.textBody),
        ),
        const SizedBox(height: ChizmaSpace.lg),
        _SelectCard(
          icon: Icons.done_rounded,
          title: 'Ha, tokcha qo\'shilsin',
          subtitle: 'Kengligi $widthCm sm',
          selected: hasSill,
          onTap: () => onChanged(true),
        ),
        if (hasSill) ...[
          const SizedBox(height: ChizmaSpace.md),
          Text(
            'Tokcha kengligi',
            style: context.text.body4.copyWith(
              color: colors.neutral.textStrong,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: ChizmaSpace.sm),
          Wrap(
            spacing: ChizmaSpace.sm,
            runSpacing: ChizmaSpace.sm,
            children: [
              for (final cm in widths)
                ChizmaChip(
                  label: '$cm sm',
                  selected: widthCm == cm,
                  onTap: () => onWidth(cm),
                ),
            ],
          ),
        ],
        const SizedBox(height: ChizmaSpace.md),
        _SelectCard(
          icon: Icons.close_rounded,
          title: 'Yo\'q, kerak emas',
          subtitle: 'Tokchasiz chiziladi',
          selected: !hasSill,
          onTap: () => onChanged(false),
        ),
      ],
    );
  }
}

class _DimField extends StatelessWidget {
  const _DimField({
    required this.label,
    required this.icon,
    required this.controller,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final TextEditingController controller;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Row(
          children: [
            Icon(icon, size: 18, color: colors.categorizedColor.primary),
            const SizedBox(width: ChizmaSpace.sm),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.body4.copyWith(
                  color: colors.neutral.textStrong,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: ChizmaSpace.sm),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,

            LengthLimitingTextInputFormatter(5),
          ],
          decoration: InputDecoration(
            suffixText: uz('mm'),
          ),
          onChanged: (v) => onChanged(int.tryParse(v) ?? 0),
        ),
      ],
    );
  }
}

class _ColorStep extends StatelessWidget {
  const _ColorStep({
    required this.palette,
    required this.selected,
    required this.onSelect,
  });

  final List<ProposalColor> palette;
  final ProposalColor selected;
  final ValueChanged<ProposalColor> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return _StepBody(
      children: [
        Text(
          'Rang tanlang (default — Oq)',
          style: context.text.body4.copyWith(color: colors.neutral.textBody),
        ),
        const SizedBox(height: ChizmaSpace.lg),
        LayoutBuilder(
          builder: (context, constraints) {
            const gap = ChizmaSpace.md;
            const minTile = 72.0;
            final width = constraints.maxWidth;

            final perRow =
                ((width + gap) / (minTile + gap)).floor().clamp(1, 5);
            final tile = perRow >= palette.length
                ? minTile
                : (width - gap * (perRow - 1)) / perRow;

            return Wrap(
              spacing: gap,
              runSpacing: gap,
              alignment: WrapAlignment.center,
              children: [
                for (final c in palette)
                  SizedBox(
                    width: tile,
                    child: _ColorSwatch(
                      color: c,
                      selected: c == selected,
                      onTap: () => onSelect(c),
                      chip: tile.clamp(
                        _ColorSwatch.minChip,
                        _ColorSwatch.maxChip,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: ChizmaSpace.lg),
        Row(
          children: [
            Icon(Icons.info_outline_rounded,
                size: 16, color: colors.neutral.textMuted),
            const SizedBox(width: ChizmaSpace.sm),
            Expanded(
              child: Text(
                'Tanlangan: ${selected.label}. Aniq rang va tusni usta bilan '
                'kelishasiz.',
                style: context.text.body5
                    .copyWith(color: colors.neutral.textMuted),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.color,
    required this.selected,
    required this.onTap,
    this.chip = defaultChip,
  });

  final ProposalColor color;
  final bool selected;
  final VoidCallback onTap;

  static const double defaultChip = 60;
  static const double minChip = 52;
  static const double maxChip = 76;

  final double chip;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final primary = colors.categorizedColor.primary;
    final swatch = Color(color.argb);
    final radius = BorderRadius.circular(ChizmaRadius.md);

    final isLight = swatch.computeLuminance() > 0.75;

    return InkWell(
      onTap: onTap,
      borderRadius: radius,

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: chip,
            width: chip,
            decoration: BoxDecoration(
              color: swatch,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected
                    ? primary
                    : (isLight
                        ? colors.neutral.borderStrong
                        : Colors.black.withValues(alpha: 0.14)),
                width: selected ? 3 : 1,

                strokeAlign: BorderSide.strokeAlignOutside,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [

                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: const [0.0, 0.55, 1.0],
                        colors: [
                          Colors.white.withValues(alpha: 0.18),
                          Colors.white.withValues(alpha: 0.0),
                          Colors.black.withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                  ),
                ),

                if (selected)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: primary,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: colors.neutral.white, width: 1.5),
                      ),
                      child: Icon(Icons.check_rounded,
                          size: 12, color: colors.neutral.white),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: ChizmaSpace.sm),
          Text(
            color.label,
            style: context.text.label.copyWith(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? primary : colors.neutral.textBody,
            ),
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
