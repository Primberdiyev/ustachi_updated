import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_generator.dart';
import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_layouts.dart';
import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_models.dart';
import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_palette.dart';
import 'package:ustachi/features/marketplace/domain/order_draft.dart';
import 'package:ustachi/features/marketplace/domain/order_proposal_items.dart';

const _gen = ProposalGenerator();

const _twoPane = "2 bo'lmali, 1 tasi ochiladi";

const _window = ProposalRequest(
  type: ProposalType.window,
  widthMm: 1500,
  heightMm: 1400,
);

void main() {
  test('deraza: har shakl uchun bitta variant, ommaboplari oldinda', () {
    final options = _gen.generate(_window);
    final templates = proposalTemplatesFor(ProposalType.window, 1500, 1400);

    expect(options, hasLength(templates.length));
    expect(options.map((o) => o.title).toSet(),
        templates.map((t) => t.title).toSet());
    for (final o in options) {
      expect((o.spec.widthMm, o.spec.heightMm), (1500, 1400));
    }
    final firstPlain = options.indexWhere((o) => !o.isPopular && !o.pinFirst);
    if (firstPlain >= 0) {
      expect(options.skip(firstPlain).any((o) => o.isPopular), isFalse);
    }
  });

  test('har rom shaklida variant chiqadi', () {
    for (final r in const [
      ProposalRequest(type: ProposalType.door, widthMm: 900, heightMm: 2100, shape: ProposalShape.eshik),
      ProposalRequest(type: ProposalType.arch, widthMm: 1500, heightMm: 2200, shape: ProposalShape.arka),
      ProposalRequest(
          type: ProposalType.door, widthMm: 2500, heightMm: 2300, floorGapMm: 800, shape: ProposalShape.fEshik),
      ProposalRequest(
          type: ProposalType.door, widthMm: 3600, heightMm: 2500, floorGapMm: 800, shape: ProposalShape.tEshik),
      ProposalRequest(type: ProposalType.window, widthMm: 8000, heightMm: 3000, shape: ProposalShape.vitraj),
    ]) {
      expect(_gen.generate(r), isNotEmpty, reason: r.shape.name);
    }
  });

  test('juda past yoki tor balkon blok — xato emas, shunchaki variant yo\'q', () {
    for (final (w, h) in [(1200, 1200), (900, 2300), (2500, 1100)]) {
      for (final shape in [ProposalShape.fEshik, ProposalShape.tEshik]) {
        final req = ProposalRequest(type: ProposalType.door, shape: shape, widthMm: w, heightMm: h, floorGapMm: 800);
        expect(() => _gen.generate(req), returnsNormally, reason: '${shape.name} $w×$h');
      }
    }
  });

  test('umumiy o\'lcham o\'zgarsa shakl saqlanadi', () {
    final current = _gen.generate(_window).firstWhere((o) => o.title == _twoPane);
    final wider = proposalResize(current: current, request: _window.copyWith(widthMm: 1600));

    expect(wider, isNotNull);
    expect(wider!.sameShape, isTrue);
    expect(wider.option.title, _twoPane);
    expect(wider.option.spec.widthMm, 1600);

    final same = proposalResize(current: current, request: _window);
    expect(identical(same!.option, current), isTrue);
  });

  test('bo\'lak eni o\'zgaradi, juda tor bo\'lak rad etiladi', () {
    final current = _gen.generate(_window).firstWhere((o) => o.title == _twoPane);

    final ok = proposalEditSegment(
      current: current,
      request: _window,
      horizontal: true,
      breaksMm: const [0, 750, 1500],
      index: 0,
      newMm: 700,
    );
    expect(ok.error, isNull);
    expect(ok.option!.spec.lines.any((l) => (l.startX * 1500 - 700).abs() < 0.5), isTrue);

    final tooNarrow = proposalEditSegment(
      current: current,
      request: _window,
      horizontal: true,
      breaksMm: const [0, 750, 1500],
      index: 0,
      newMm: 100,
    );
    expect(tooNarrow.option, isNull);
    expect(tooNarrow.error, isNotNull);
  });

  test('material kodi: 0 plastik, 1 alyuminiy, 2 termo; sukutda plastik', () {
    expect(_window.material, 0);
    expect([for (final m in proposalMaterialCodes) proposalMaterialLabel(m)],
        ['Plastik', 'Alyuminiy', 'Termo']);
    for (final m in proposalMaterialCodes) {
      final r = _window.copyWith(material: m);
      final o = _gen.generate(r).first;
      final json = const ClientOrderDraft()
          .add(ClientDraftItem(localId: 'a', option: o, request: r))
          .toProposalJson();
      expect(json['material'], m);
      expect((json['items'] as List).single['material'], m);
    }
  });

  test('ranglar: qat\'iy ro\'yxat, birinchisi oq', () {
    expect(proposalColors.first, ProposalColor.white);
    expect(proposalColors.where((c) => c.isWhite), hasLength(1));
    expect(proposalColors.map((c) => c.label).toSet(), hasLength(proposalColors.length));
  });

  test('buyurtma yuklamasi: chizma bor, narx maydonlari yo\'q', () {
    final o = _gen.generate(_window).firstWhere((o) => o.title == _twoPane);
    const color = ProposalColor(label: 'Dub mokko', argb: 0xFF823F0D);
    final request = _window.copyWith(
      material: 1,
      colorKey: color.colorKey,
      colorArgb: color.argb,
      colorLabel: color.label,
      hasSill: true,
      sillWidthCm: 35,
    );
    final draft = const ClientOrderDraft()
        .add(ClientDraftItem(localId: 'a', option: o, request: request, qty: 2));
    final json = draft.toProposalJson();

    expect(json['version'], 2);
    expect(json['material'], 1);
    expect((json['item_kinds'], json['item_count']), (1, 2));
    final item = (json['items'] as List).single as Map<String, dynamic>;
    expect((item['width_mm'], item['height_mm'], item['qty']), (1500, 1400, 2));
    expect((item['color_key'], item['color_argb'], item['color_label']), ('COLOR', 0xFF823F0D, 'Dub mokko'));
    expect((item['has_sill'], item['sill_width_cm']), (true, 35));
    expect(item['shape_title'], _twoPane);
    expect(item['material'], 1);
    expect(item['spec'], isA<Map<String, dynamic>>());

    for (final map in [json, item]) {
      for (final key in const [
        'unit_price',
        'total_price',
        'cost_price',
        'fee_percent',
        'bom_lines',
        'price_engine',
        'brand_id',
        'brand_name',
        'series_id',
        'series_name',
        'layer_type',
        'missing_prices',
      ]) {
        expect(map.containsKey(key), isFalse, reason: key);
      }
    }

    final shown = orderProposalItems(json).single;
    expect(shown.spec, isNotNull);
    expect(shown.sizeLabel, '1500×1400 mm');
    expect(shown.qty, 2);
    expect(shown.materialLabel, 'Alyuminiy');
    expect(shown.specRows.map((r) => r.$1), ['Shakl', 'O\'lcham', 'Material', 'Rang', 'Tokcha']);
  });
}
