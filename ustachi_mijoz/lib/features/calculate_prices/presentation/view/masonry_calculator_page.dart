import 'package:ustachi/features/calculate_prices/presentation/widgets/price_estimate_notice.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:flutter/services.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/features/calculate_prices/domain/services/masonry_calculator.dart';
import 'package:ustachi/features/calculate_prices/presentation/view/proposal_back_navigation.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/proposal/proposal_option_card.dart'
    show formatSom;
import 'package:ustachi/features/marketplace/domain/entities/order_entity.dart';
import 'package:ustachi/features/marketplace/domain/entities/specialty_entity.dart';
import 'package:ustachi/features/marketplace/presentation/view/order_detail_page.dart';
import 'package:ustachi/features/marketplace/presentation/view/trade_order_page.dart';

class MasonryCalculatorPage extends StatefulWidget {
  const MasonryCalculatorPage({super.key, required this.specialty});

  final SpecialtyEntity specialty;

  @override
  State<MasonryCalculatorPage> createState() => _MasonryCalculatorPageState();
}

enum _Step {
  purpose('Nima quramiz?'),
  material('Qaysi materialda?'),
  price('Hududingizdagi narx'),
  frame('Seysmik karkas'),
  rooms('Uy o\'lchami va xonalar'),
  size('Eshik-deraza va narx');

  const _Step(this.title);
  final String title;
}

class _MasonryCalculatorPageState extends State<MasonryCalculatorPage> {
  final _lengthCtrl = TextEditingController();
  final _widthCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();

  int _step = 0;
  MasonryPurpose? _purpose;
  MasonryMaterial? _material;
  SpecialtyBrick? _brick;
  MasonryThickness _thickness = MasonryThickness.one;

  double? _localPrice;
  final _priceCtrl = TextEditingController();

  SpecialtyBrick? get _pricedBrick {
    final b = _brick;
    if (b == null || _localPrice == null) return b;
    return SpecialtyBrick(
      name: b.name,
      kind: b.kind,
      lengthMm: b.lengthMm,
      widthMm: b.widthMm,
      heightMm: b.heightMm,
      jointMm: b.jointMm,
      bricksPerM2Half: b.bricksPerM2Half,
      price: _localPrice!,
      mortarPerBrick: b.mortarPerBrick,
      wastePct: b.wastePct,
    );
  }

  bool? _frame;

  List<List<MasonryRoomSpec>> _floors = [_standardFloor()];

  var _doors = const [MasonryOpening.door()];
  var _windows = const [MasonryOpening.window()];
  var _innerDoors = const [MasonryOpening.innerDoor()];

  static double _openingsArea(List<MasonryOpening> list) =>
      list.fold(0, (sum, o) => sum + o.areaM2);

  static List<Map<String, Object>> _openingList(List<MasonryOpening> list) => [
        for (final o in list)
          if (o.count > 0)
            {'count': o.count, 'width_m': o.widthM, 'height_m': o.heightM},
      ];

  static const _maxFloors = 3;

  static List<MasonryRoomSpec> _standardFloor() => [
        for (final room in MasonryRoom.values)
          MasonryRoomSpec.standard(room, 0),
      ];

  List<_Step> get _steps => [
        _Step.purpose,
        _Step.material,
        _Step.price,
        if (_purpose != MasonryPurpose.fence) ...[_Step.frame, _Step.rooms],
        _Step.size,
      ];

  void _setFloors(int count) => setState(() {
        _floors = [
          for (var i = 0; i < count; i++)

            i < _floors.length ? _floors[i] : [..._floors.last],
        ];
      });

  void _editRoom(
    int floor,
    int index, {
    int? count,
    double? widthM,
    double? lengthM,
  }) =>
      setState(() {
        _floors = [
          for (var i = 0; i < _floors.length; i++)
            [
              for (var j = 0; j < _floors[i].length; j++)
                (i == floor && j == index)
                    ? _floors[i][j].copyWith(
                        count: count?.clamp(0, 20),
                        widthM: widthM,
                        lengthM: lengthM,
                      )
                    : _floors[i][j],
            ],
        ];
      });

  void _addRoomSize(int floor, MasonryRoom room) => setState(() {
        final next = [
          for (final f in _floors) [...f]
        ];

        final at = next[floor].lastIndexWhere((s) => s.room == room);
        next[floor].insert(at < 0 ? next[floor].length : at + 1,
            MasonryRoomSpec.standard(room, 1));
        _floors = next;
      });

  void _removeRoomSize(int floor, int index) => setState(() {
        final next = [
          for (final f in _floors) [...f]
        ];
        next[floor].removeAt(index);
        _floors = next;
      });

  _Step get _current => _steps[_step.clamp(0, _steps.length - 1)];

  bool get _hasFrame =>
      _purpose == MasonryPurpose.building && (_frame ?? false);

  double? _length;

  double? _width;
  double? _height;

  @override
  void dispose() {
    _lengthCtrl.dispose();
    _widthCtrl.dispose();
    _heightCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  List<SpecialtyBrick> _bricksOf(MasonryMaterial material) => [
        for (final b in widget.specialty.bricks)
          if (b.kind == material.code) b,
      ];

  void _selectPurpose(MasonryPurpose purpose) {
    setState(() {
      _purpose = purpose;

      if (_material != null && !_material!.allowedFor(purpose)) {
        _material = null;
        _brick = null;
      }
    });
  }

  void _selectMaterial(MasonryMaterial material) {
    final bricks = _bricksOf(material);
    if (bricks.isEmpty) return;
    setState(() {
      _material = material;
      if (_brick == null || !bricks.contains(_brick)) {
        _brick = bricks.first;

        _localPrice = null;
        _priceCtrl.text = _priceText(_brick!.price);
      }
      if (!material.thicknesses.contains(_thickness)) {
        _thickness = material.thicknesses.first;
      } else if (!material.isBlock &&
          _thickness == MasonryThickness.half &&
          material.thicknesses.length > 1) {

        _thickness = MasonryThickness.one;
      }
    });
  }

  static double? _parse(String raw) {
    final parsed = double.tryParse(raw.trim().replaceAll(',', '.'));
    return (parsed != null && parsed > 0) ? parsed : null;
  }

  static String _priceText(double v) => v.round().toString();

  void _setLocalPrice(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    final value = double.tryParse(digits);
    setState(() {
      _localPrice = (value == null || value <= 0 || value == _brick?.price)
          ? null
          : value;
    });
  }

  bool get _priceFromClient => _localPrice != null;

  bool get _priceValid {
    final value =
        double.tryParse(_priceCtrl.text.replaceAll(RegExp(r'[^0-9]'), ''));
    return value != null && value > 0;
  }

  MasonryEstimate? get _estimate =>
      (_brick == null || _wallLength == null || _height == null)
          ? null
          : _isBuilding
              ? MasonryCalculator.calculateBuilding(
                  brick: _pricedBrick!,
                  thickness: _thickness,
                  lengthM: _length!,
                  widthM: _width!,
                  floorHeightM: _height!,
                  floors: _floors,
                  openingsM2: _openingsArea(_doors) + _openingsArea(_windows),
                  innerOpeningsM2: _openingsArea(_innerDoors),
                  frame: _hasFrame,
                )
              : MasonryCalculator.calculate(
                  brick: _pricedBrick!,
                  thickness: _thickness,
                  lengthM: _wallLength!,
                  heightM: _height!,
                );

  bool get _isBuilding => _purpose == MasonryPurpose.building;

  double get _roomsAreaM2 =>
      _floors.isEmpty ? 0 : MasonryRooms.areaM2(_floors.first);

  MasonryFit get _fit => (_length == null || _width == null || _floors.isEmpty)
      ? MasonryFit.unknown
      : MasonryRooms.fit(floorAreaM2: _length! * _width!, rooms: _floors.first);

  String? get _missingReason {
    if (_current == _Step.rooms) {
      if (_length == null) return 'Uy uzunligini yozing.';
      if (_width == null) return 'Uy enini yozing.';
      if (_height == null) {
        return _floors.length > 1
            ? 'Bir qavat balandligini yozing.'
            : 'Devor balandligini yozing.';
      }

      return _fit == MasonryFit.tooMany ? _fitMessage : null;
    }
    if (_current != _Step.size || _estimate != null) return null;
    if (_isBuilding) {
      if (_length == null) return 'Uy uzunligini yozing.';
      if (_width == null) return 'Uy enini yozing.';
      if (_height == null) {
        return _floors.length > 1
            ? 'Bir qavat balandligini yozing.'
            : 'Devor balandligini yozing.';
      }
      return 'Eshik-deraza (yoki karkas) devordan katta chiqdi — '
          'o\'lchamlarini tekshiring.';
    }
    if (_length == null) return 'Zabor uzunligini yozing.';
    if (_height == null) return 'Zabor balandligini yozing.';
    return 'O\'lchamlarni tekshiring.';
  }

  String? get _fitMessage {
    final floorArea = (_length ?? 0) * (_width ?? 0);
    final spare = floorArea * MasonryRooms.usableShare - _roomsAreaM2;
    return switch (_fit) {
      MasonryFit.tooMany =>
        'Xonalar uy maydoniga sig\'maydi — xona sonini yoki o\'lchamini '
            'kamaytiring.',
      MasonryFit.tooFew => 'Yana ${_num(spare)} m² joy ortyapti — xona '
          'qo\'shishingiz yoki xonalarni kengaytirishingiz mumkin.',
      _ => null,
    };
  }

  double? get _wallLength {
    if (_length == null) return null;
    if (!_isBuilding) return _length;
    if (_width == null) return null;
    return MasonryFrame.housePerimeterM(_length!, _width!);
  }

  bool get _canProceed => switch (_current) {
        _Step.purpose => _purpose != null,
        _Step.material => _material != null && _brick != null,
        _Step.price => _priceValid,
        _Step.frame => _frame != null,

        _Step.rooms => _length != null &&
            _width != null &&
            _height != null &&
            _fit != MasonryFit.tooMany,
        _Step.size => _estimate != null,
      };

  void _next() {
    FocusScope.of(context).unfocus();
    if (!_canProceed) return;
    if (_step < _steps.length - 1) {
      setState(() => _step++);
    } else {
      _goNext();
    }
  }

  void _back() {
    FocusScope.of(context).unfocus();
    if (_step == 0) {
      Navigator.of(context).maybePop();
      return;
    }
    setState(() => _step--);
  }

  static String _num(double value) {
    final rounded = (value * 100).round() / 100;
    return rounded == rounded.roundToDouble()
        ? rounded.round().toString()
        : rounded.toString().replaceAll('.', ',');
  }

  static String _count(int value) => formatSom(value.toDouble());

  String _thicknessLabel(MasonryThickness t) {

    final cm = _num(t.thicknessMm(_brick!) / 10);
    return _material!.isBlock ? 'Blok eni · $cm sm' : '${t.label} · $cm sm';
  }

  Future<void> _goNext() async {
    final estimate = _estimate;
    if (estimate == null) return;

    final navigator = Navigator.of(context);
    final total = estimate.total;
    final purpose = _purpose == MasonryPurpose.fence ? 'Zabor' : 'Bino';
    final created = await navigator.push<OrderEntity>(
      MaterialPageRoute<OrderEntity>(
        builder: (_) => TradeOrderPage(
          specialty: widget.specialty,
          calculatedPrice: total,
          proposal: {
            'calculator': 'variant',
            'engine': 'masonry',
            'variant': _brick!.name,

            'variant_note': [
              if (_isBuilding)
                '$purpose ${_num(_length!)}×${_num(_width!)}'
              else
                purpose,
              if (_isBuilding && _floors.length > 1) '${_floors.length} qavat',
              '${_num(_thickness.thicknessMm(_brick!) / 10)} sm',
              if (_hasFrame) 'karkasli',
              '${_count(estimate.totalBricks)} dona',
            ].join(' · '),
            'area_m2': double.parse(estimate.netAreaM2.toStringAsFixed(2)),
            'unit': 'm²',
            'cost_price': total,
            'total_price': total,
            'masonry_purpose': _purpose!.name,
            'masonry_material': _material!.code,
            if (_isBuilding) ...{
              'masonry_house_length_m': _length,
              'masonry_house_width_m': _width,
            },
            'masonry_length_m': _wallLength,
            'masonry_height_m': _height,
            'masonry_openings_m2': estimate.openingsM2,
            if (_isBuilding) ...{
              'masonry_floors': _floors.length,
              'masonry_rooms': [
                for (final floor in _floors)
                  [
                    for (final spec in floor)
                      if (spec.count > 0)
                        {
                          'room': spec.room.name,
                          'count': spec.count,
                          'width_m': spec.widthM,
                          'length_m': spec.lengthM,
                        },
                  ],
              ],
              'masonry_inner_doors': _openingList(_innerDoors),
              'masonry_inner_openings_m2': _openingsArea(_innerDoors),
            },
            if (_isBuilding) ...{
              'masonry_doors': _openingList(_doors),
              'masonry_windows': _openingList(_windows),
              'masonry_parts': [
                for (final p in estimate.parts)
                  {
                    'kind': p.kind.name,
                    'length_m': double.parse(p.lengthM.toStringAsFixed(2)),
                    'area_m2': double.parse(p.areaM2.toStringAsFixed(2)),
                    'thickness_halves': p.thickness.halves,
                  },
              ],
            },
            'masonry_frame': _hasFrame,
            'masonry_frame_m2':
                double.parse(estimate.frameM2.toStringAsFixed(2)),
            'masonry_thickness_halves': _thickness.halves,

            'masonry_brick': _pricedBrick!.toJson(),
            'masonry_price_source': _priceFromClient ? 'client' : 'default',
            'masonry_default_price': _brick!.price,
            'masonry_bricks_laid': estimate.laidBricks,
            'masonry_bricks_total': estimate.totalBricks,
            'masonry_brick_cost': estimate.brickCost,
            'masonry_mortar_cost': estimate.mortarCost,
          },

          summary: '${_material!.title} · ${_num(estimate.netAreaM2)} m² · '
              '${_count(estimate.totalBricks)} dona',
        ),
      ),
    );
    if (created == null) return;

    clearProposalFlow(navigator);
    await navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => OrderDetailPage(orderId: created.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final steps = _steps;
    final stepCount = steps.length;

    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: colors.neutral.black7,
        appBar: AppBar(
          leading: BackButton(onPressed: _back),

          title: Text(_current == _Step.size && !_isBuilding
              ? 'O\'lchamini kiriting'
              : _current.title),
        ),
        body: Column(
          children: [

            Padding(
              padding: const EdgeInsets.fromLTRB(ChizmaSpace.lg, ChizmaSpace.sm,
                  ChizmaSpace.lg, ChizmaSpace.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(ChizmaRadius.pill),
                    child: LinearProgressIndicator(
                      value: (_step + 1) / stepCount,
                      minHeight: 6,
                      backgroundColor: colors.neutral.surface2,
                      color: colors.categorizedColor.primary,
                    ),
                  ),
                  const SizedBox(height: ChizmaSpace.sm),
                  Text(
                    'Qadam ${_step + 1} / $stepCount',
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
                  for (final step in steps)
                    switch (step) {
                      _Step.purpose => _PurposeStep(
                          value: _purpose, onChanged: _selectPurpose),
                      _Step.material => _MaterialStep(
                          purpose: _purpose,
                          value: _material,
                          hasPrice: (m) => _bricksOf(m).isNotEmpty,
                          onChanged: _selectMaterial,
                        ),
                      _Step.price => _brick == null
                          ? const SizedBox.shrink()
                          : _PriceStep(
                              material: _material!,
                              brick: _brick!,
                              controller: _priceCtrl,
                              changed: _priceFromClient,
                              onChanged: _setLocalPrice,
                              onReset: () => setState(() {
                                _localPrice = null;
                                _priceCtrl.text = _priceText(_brick!.price);
                              }),
                            ),
                      _Step.frame => _FrameStep(
                          value: _frame,
                          onChanged: (v) => setState(() => _frame = v),
                        ),
                      _Step.rooms => _RoomsStep(
                          header: _houseSizeCard(context),
                          floors: _floors,
                          maxFloors: _maxFloors,
                          onFloors: _setFloors,
                          onRoom: _editRoom,
                          onAddSize: _addRoomSize,
                          onRemoveSize: _removeRoomSize,
                        ),
                      _Step.size => _brick == null
                          ? const SizedBox.shrink()
                          : _sizeStep(context),
                    },
                ],
              ),
            ),

            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(ChizmaSpace.lg,
                    ChizmaSpace.sm, ChizmaSpace.lg, ChizmaSpace.md),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    if (_missingReason != null) ...[
                      Row(
                        children: [
                          Icon(Icons.info_outline_rounded,
                              size: 14, color: colors.neutral.textMuted),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _missingReason!,
                              style: context.text.label
                                  .copyWith(color: colors.neutral.textMuted),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: ChizmaSpace.sm),
                    ],
                    Row(
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
                            child: const Text('Keyingisi'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _houseSizeCard(BuildContext context) {
    final colors = context.color;
    return ChizmaSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Uyingizning umumiy o\'lchamini yozing — masalan, uyim 6 ga 4, '
            'balandligi 2,8 metr.',
            style: context.text.body5.copyWith(color: colors.neutral.textMuted),
          ),
          const SizedBox(height: ChizmaSpace.lg),
          Row(
            children: [
              Expanded(
                child: _NumberField(
                  controller: _lengthCtrl,
                  label: 'Uy uzunligi',
                  suffix: 'm',
                  onChanged: (v) => setState(() => _length = _parse(v)),
                ),
              ),
              const SizedBox(width: ChizmaSpace.md),
              Expanded(
                child: _NumberField(
                  controller: _widthCtrl,
                  label: 'Uy eni',
                  suffix: 'm',
                  onChanged: (v) => setState(() => _width = _parse(v)),
                ),
              ),
            ],
          ),
          const SizedBox(height: ChizmaSpace.md),
          _NumberField(
            controller: _heightCtrl,
            label: _floors.length > 1
                ? 'Bir qavat balandligi'
                : 'Devor balandligi',
            suffix: 'm',
            onChanged: (v) => setState(() => _height = _parse(v)),
          ),
          if (_length != null && _width != null) ...[
            const SizedBox(height: ChizmaSpace.sm),
            Text(
              'Bir qavat maydoni: ${_num(_length! * _width!)} m² · '
              'devorlar uzunligi: ${_num(MasonryFrame.housePerimeterM(_length!, _width!))} m',
              style:
                  context.text.label.copyWith(color: colors.neutral.textMuted),
            ),

            if (_roomsAreaM2 > 0) ...[
              const SizedBox(height: 2),
              Text(
                'Xonalar maydoni: ${_num(_roomsAreaM2)} m²',
                style: context.text.label
                    .copyWith(color: colors.neutral.textMuted),
              ),
              if (_fitMessage != null) ...[
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _fit == MasonryFit.tooMany
                          ? Icons.warning_amber_rounded
                          : Icons.info_outline_rounded,
                      size: 14,
                      color: _fit == MasonryFit.tooMany
                          ? colors.categorizedColor.warning
                          : colors.categorizedColor.primary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _fitMessage!,
                        style: context.text.label.copyWith(
                          color: _fit == MasonryFit.tooMany
                              ? colors.categorizedColor.warning
                              : colors.neutral.textBody,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ],
      ),
    );
  }

  Widget _sizeStep(BuildContext context) {
    final colors = context.color;
    final estimate = _estimate;
    final material = _material!;
    final bricks = _bricksOf(material);

    return _StepBody(
      children: [
        if (!_isBuilding)
          ChizmaSheet(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Zabor uzunligi va balandligini yozing.',
                  style: context.text.body5
                      .copyWith(color: colors.neutral.textMuted),
                ),
                const SizedBox(height: ChizmaSpace.lg),
                Row(
                  children: [
                    Expanded(
                      child: _NumberField(
                        controller: _lengthCtrl,
                        label: 'Uzunligi',
                        suffix: 'm',
                        onChanged: (v) => setState(() => _length = _parse(v)),
                      ),
                    ),
                    const SizedBox(width: ChizmaSpace.md),
                    Expanded(
                      child: _NumberField(
                        controller: _heightCtrl,
                        label: 'Balandligi',
                        suffix: 'm',
                        onChanged: (v) => setState(() => _height = _parse(v)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        if (_isBuilding) ...[
          const SizedBox(height: ChizmaSpace.lg),
          const ChizmaEyebrow('Eshik va derazalar'),
          const SizedBox(height: ChizmaSpace.sm),
          ChizmaSheet(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sonini yozing — o\'lchami odatdagicha qo\'yilgan, '
                  'boshqacha bo\'lsa to\'g\'rilang. O\'lchamlari har xil '
                  'bo\'lsa «Yana o\'lcham» bilan qator qo\'shing.',
                  style: context.text.body5
                      .copyWith(color: colors.neutral.textMuted),
                ),
                const SizedBox(height: ChizmaSpace.sm),
                _OpeningGroup(
                  title: 'Tashqi eshik',
                  items: _doors,
                  standard: const MasonryOpening.door(),
                  onChanged: (v) => setState(() => _doors = v),
                ),
                _OpeningGroup(
                  title: 'Deraza',
                  items: _windows,
                  standard: const MasonryOpening.window(),
                  onChanged: (v) => setState(() => _windows = v),
                ),
                _OpeningGroup(
                  title: 'Ichki eshik',
                  items: _innerDoors,
                  standard: const MasonryOpening.innerDoor(),
                  note: 'ichki devordan ayriladi',
                  onChanged: (v) => setState(() => _innerDoors = v),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: ChizmaSpace.lg),
        if (material.thicknesses.length > 1) ...[
          const ChizmaEyebrow('Devor qalinligi'),
          const SizedBox(height: ChizmaSpace.sm),
          Wrap(
            spacing: ChizmaSpace.sm,
            runSpacing: ChizmaSpace.sm,
            children: [
              for (final t in material.thicknesses)
                ChoiceChip(
                  label: Text(_thicknessLabel(t)),
                  selected: t == _thickness,
                  onSelected: (_) => setState(() => _thickness = t),
                ),
            ],
          ),
          const SizedBox(height: ChizmaSpace.lg),
        ],

        if (bricks.length > 1) ...[
          const ChizmaEyebrow('O\'lchami'),
          const SizedBox(height: ChizmaSpace.sm),
          Wrap(
            spacing: ChizmaSpace.sm,
            runSpacing: ChizmaSpace.sm,
            children: [
              for (final b in bricks)
                ChoiceChip(
                  label: Text('${b.name} · ${b.sizeLabel}'),
                  selected: b == _brick,
                  onSelected: (_) => setState(() => _brick = b),
                ),
            ],
          ),
          const SizedBox(height: ChizmaSpace.lg),
        ],
        if (estimate != null)
          _ResultSheet(
            estimate: estimate,

            brick: _pricedBrick!,
            unitWord: material.isBlock ? 'blok' : 'g\'isht',
            areaLabel: _num,
            countLabel: _count,
          ),
        const SizedBox(height: ChizmaSpace.sm),
        Text(

          'Bu — faqat materialning tannarxi. Terish haqini har usta o\'zi '
          'belgilaydi: javob berganda har bir ustaning jami summasini '
          'ko\'rasiz va solishtirasiz.',
          textAlign: TextAlign.center,
          style: context.text.body4.copyWith(color: colors.neutral.textMuted),
        ),
        if (estimate != null) const PriceEstimateNotice(),
      ],
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

class _PurposeStep extends StatelessWidget {
  const _PurposeStep({required this.value, required this.onChanged});

  final MasonryPurpose? value;
  final ValueChanged<MasonryPurpose> onChanged;

  @override
  Widget build(BuildContext context) {
    return _StepBody(
      children: [
        for (final p in MasonryPurpose.values) ...[
          _PictureCard(
            picture: _PurposePicture(purpose: p),
            title: p.title,
            desc: p.desc,
            selected: value == p,
            onTap: () => onChanged(p),
          ),
          const SizedBox(height: ChizmaSpace.md),
        ],
      ],
    );
  }
}

class _MaterialStep extends StatelessWidget {
  const _MaterialStep({
    required this.purpose,
    required this.value,
    required this.hasPrice,
    required this.onChanged,
  });

  final MasonryPurpose? purpose;
  final MasonryMaterial? value;
  final bool Function(MasonryMaterial) hasPrice;
  final ValueChanged<MasonryMaterial> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = purpose;
    if (p == null) return const SizedBox.shrink();
    return _StepBody(
      children: [
        for (final m in MasonryMaterial.values)
          if (m.allowedFor(p)) ...[
            _PictureCard(
              picture: _MaterialPicture(material: m),
              title: m.title,
              desc: m.desc,
              note: hasPrice(m) ? null : 'Narxi hali kiritilmagan',
              selected: value == m,
              onTap: hasPrice(m) ? () => onChanged(m) : null,
            ),
            const SizedBox(height: ChizmaSpace.md),
          ],
      ],
    );
  }
}

class _PriceStep extends StatelessWidget {
  const _PriceStep({
    required this.material,
    required this.brick,
    required this.controller,
    required this.changed,
    required this.onChanged,
    required this.onReset,
  });

  final MasonryMaterial material;
  final SpecialtyBrick brick;
  final TextEditingController controller;

  final bool changed;
  final ValueChanged<String> onChanged;
  final VoidCallback onReset;

  bool get _unusual {
    final value =
        double.tryParse(controller.text.replaceAll(RegExp(r'[^0-9]'), ''));
    if (value == null || value <= 0 || brick.price <= 0) return false;
    final ratio = value / brick.price;
    return ratio > 3 || ratio < 1 / 3;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final unit = material.isBlock ? 'blok' : 'g\'isht';
    return _StepBody(
      children: [
        _PictureCard(
          picture: _MaterialPicture(material: material),
          title: brick.name,
          desc: brick.sizeLabel,
          selected: true,
          onTap: null,
          dim: false,
        ),
        const SizedBox(height: ChizmaSpace.lg),
        ChizmaSheet(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Hududingizdagi 1 dona $unit narxini yozing',
                style:
                    context.text.h4.copyWith(color: colors.neutral.textStrong),
              ),
              const SizedBox(height: 4),
              Text(
                'Narx har viloyatda har xil. Bilmasangiz — o\'zgartirmang, '
                'bizdagi o\'rtacha narx bo\'yicha hisoblaymiz.',
                style: context.text.body5
                    .copyWith(color: colors.neutral.textMuted),
              ),
              const SizedBox(height: ChizmaSpace.lg),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(7),
                ],
                onChanged: onChanged,
                style:
                    context.text.h2.copyWith(color: colors.neutral.textStrong),
                decoration: InputDecoration(
                  hintText: '0',
                  suffixText: uz('so\'m / dona'),
                  suffixStyle: context.text.body3
                      .copyWith(color: colors.neutral.textMuted),
                ),
              ),

              if (_unusual) ...[
                const SizedBox(height: ChizmaSpace.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        size: 14, color: colors.categorizedColor.warning),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Narx odatdagidan ancha farq qilyapti — '
                        'to\'g\'ri yozilganini tekshiring.',
                        style: context.text.label
                            .copyWith(color: colors.categorizedColor.warning),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: ChizmaSpace.sm),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      changed
                          ? 'Sizning narxingiz bo\'yicha hisoblaymiz '
                              '(bizda: ${formatSom(brick.price)} so\'m).'
                          : 'Bizdagi o\'rtacha narx: '
                              '${formatSom(brick.price)} so\'m.',
                      style: context.text.label
                          .copyWith(color: colors.neutral.textMuted),
                    ),
                  ),
                  if (changed)
                    TextButton(
                      onPressed: onReset,
                      child: const Text('Qaytarish'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FrameStep extends StatelessWidget {
  const _FrameStep({required this.value, required this.onChanged});

  final bool? value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return _StepBody(
      children: [
        Text(
          'Binoga seysmik karkas (beton ustunlar) va regel (devor tepasidagi '
          'beton belbog\') qo\'yiladimi? Beton g\'isht o\'rnini egallaydi — '
          'g\'isht kamroq ketadi.',
          style: context.text.body5.copyWith(color: colors.neutral.textMuted),
        ),
        const SizedBox(height: ChizmaSpace.md),
        _PictureCard(
          picture: const _FramePicture(frame: true),
          title: 'Ha, karkas va regel bor',
          desc: 'Beton ustunlar va regel orasiga g\'isht teriladi.',
          selected: value == true,
          onTap: () => onChanged(true),
        ),
        const SizedBox(height: ChizmaSpace.md),
        _PictureCard(
          picture: const _FramePicture(frame: false),
          title: 'Yo\'q, faqat g\'isht',
          desc: 'Devor to\'liq g\'ishtdan teriladi.',
          selected: value == false,
          onTap: () => onChanged(false),
        ),
      ],
    );
  }
}

class _RoomsStep extends StatelessWidget {
  const _RoomsStep({
    required this.header,
    required this.floors,
    required this.maxFloors,
    required this.onFloors,
    required this.onRoom,
    required this.onAddSize,
    required this.onRemoveSize,
  });

  final Widget header;
  final List<List<MasonryRoomSpec>> floors;
  final int maxFloors;
  final ValueChanged<int> onFloors;
  final void Function(
    int floor,
    int index, {
    int? count,
    double? widthM,
    double? lengthM,
  }) onRoom;
  final void Function(int floor, MasonryRoom room) onAddSize;
  final void Function(int floor, int index) onRemoveSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return _StepBody(
      children: [
        header,
        const SizedBox(height: ChizmaSpace.lg),
        Text(
          'Xonalar orasidagi ichki devorlar ham g\'ishtdan teriladi. Har '
          'qavatda qanday xonalar borligini belgilang — o\'lchami odatdagicha '
          'yozilgan, boshqacha bo\'lsa to\'g\'rilang. Bino bo\'linmagan '
          'bo\'lsa (bitta xona, ombor, garaj) — xona qo\'shmang, faqat '
          'tashqi devor hisoblanadi.',
          style: context.text.body5.copyWith(color: colors.neutral.textMuted),
        ),
        const SizedBox(height: ChizmaSpace.lg),
        const ChizmaEyebrow('Necha qavat?'),
        const SizedBox(height: ChizmaSpace.sm),
        Wrap(
          spacing: ChizmaSpace.sm,
          children: [
            for (var n = 1; n <= maxFloors; n++)
              ChoiceChip(
                label: Text('$n qavat'),
                selected: floors.length == n,
                onSelected: (_) => onFloors(n),
              ),
          ],
        ),
        for (var i = 0; i < floors.length; i++) ...[
          const SizedBox(height: ChizmaSpace.lg),
          ChizmaEyebrow(floors.length == 1 ? 'Xonalar' : '${i + 1}-qavat'),
          const SizedBox(height: ChizmaSpace.sm),
          ChizmaSheet(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final room in MasonryRoom.values)
                  ..._roomGroup(context, floor: i, room: room),
              ],
            ),
          ),
        ],
      ],
    );
  }

  List<Widget> _roomGroup(
    BuildContext context, {
    required int floor,
    required MasonryRoom room,
  }) {
    final colors = context.color;
    final indexes = [
      for (var j = 0; j < floors[floor].length; j++)
        if (floors[floor][j].room == room) j,
    ];
    return [
      for (var n = 0; n < indexes.length; n++)
        _RoomRow(
          key: ValueKey('$floor-${room.name}-$n-${indexes.length}'),
          title: indexes.length == 1 ? room.title : '${room.title} ${n + 1}',
          spec: floors[floor][indexes[n]],
          onCount: (v) => onRoom(floor, indexes[n], count: v),
          onWidth: (v) => onRoom(floor, indexes[n], widthM: v),
          onLength: (v) => onRoom(floor, indexes[n], lengthM: v),
          onRemove:
              indexes.length > 1 ? () => onRemoveSize(floor, indexes[n]) : null,
        ),

      if (indexes.any((j) => floors[floor][j].count > 0))
        Padding(
          padding: const EdgeInsets.only(
              left: ChizmaSpace.md, bottom: ChizmaSpace.sm),
          child: InkWell(
            onTap: () => onAddSize(floor, room),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded,
                      size: 16, color: colors.categorizedColor.primary),
                  const SizedBox(width: 4),
                  Text(
                    'Yana o\'lcham',
                    style: context.text.label
                        .copyWith(color: colors.categorizedColor.primary),
                  ),
                ],
              ),
            ),
          ),
        ),
    ];
  }
}

class _RoomRow extends StatefulWidget {
  const _RoomRow({
    super.key,
    required this.title,
    required this.spec,
    required this.onCount,
    required this.onWidth,
    required this.onLength,
    this.onRemove,
  });

  final String title;
  final MasonryRoomSpec spec;
  final ValueChanged<int> onCount;
  final ValueChanged<double> onWidth;
  final ValueChanged<double> onLength;

  final VoidCallback? onRemove;

  @override
  State<_RoomRow> createState() => _RoomRowState();
}

class _RoomRowState extends State<_RoomRow> {
  late final _widthCtrl =
      TextEditingController(text: _text(widget.spec.widthM));
  late final _lengthCtrl =
      TextEditingController(text: _text(widget.spec.lengthM));

  static String _text(double v) =>
      (v == v.roundToDouble() ? v.round().toString() : '$v')
          .replaceAll('.', ',');

  @override
  void dispose() {
    _widthCtrl.dispose();
    _lengthCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final primary = colors.categorizedColor.primary;
    final spec = widget.spec;
    final chosen = spec.count > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: context.text.body4.copyWith(
                    color: chosen
                        ? colors.neutral.textStrong
                        : colors.neutral.textBody,
                    fontWeight: chosen ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              IconButton(
                onPressed: chosen ? () => widget.onCount(spec.count - 1) : null,
                icon: const Icon(Icons.remove_circle_outline_rounded),
                color: primary,
                visualDensity: VisualDensity.compact,
              ),
              SizedBox(
                width: 28,
                child: Text(
                  '${spec.count}',
                  textAlign: TextAlign.center,
                  style: context.text.h4
                      .copyWith(color: colors.neutral.textStrong),
                ),
              ),
              if (widget.onRemove != null)
                IconButton(
                  onPressed: widget.onRemove,
                  icon: const Icon(Icons.close_rounded, size: 18),
                  color: colors.neutral.textMuted,
                  tooltip: uz('O\'lchamni olib tashlash'),
                  visualDensity: VisualDensity.compact,
                ),
              IconButton(
                onPressed: () => widget.onCount(spec.count + 1),
                icon: const Icon(Icons.add_circle_outline_rounded),
                color: primary,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),

          if (chosen)
            Padding(
              padding: const EdgeInsets.only(
                  left: ChizmaSpace.md, bottom: ChizmaSpace.sm),
              child: Row(
                children: [
                  Text(
                    'Bitta xona:',
                    style: context.text.label
                        .copyWith(color: colors.neutral.textMuted),
                  ),
                  const SizedBox(width: ChizmaSpace.sm),
                  _SmallNumberField(
                    controller: _widthCtrl,
                    onChanged: widget.onWidth,
                  ),
                  Text('  ×  ',
                      style: context.text.body5
                          .copyWith(color: colors.neutral.textMuted)),
                  _SmallNumberField(
                    controller: _lengthCtrl,
                    onChanged: widget.onLength,
                  ),
                  Text(' m',
                      style: context.text.label
                          .copyWith(color: colors.neutral.textMuted)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _OpeningGroup extends StatelessWidget {
  const _OpeningGroup({
    required this.title,
    required this.items,
    required this.standard,
    required this.onChanged,
    this.note,
  });

  final String title;
  final List<MasonryOpening> items;

  final MasonryOpening standard;
  final String? note;
  final ValueChanged<List<MasonryOpening>> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < items.length; i++)
          _OpeningRow(

            key: ValueKey('$title-$i-${items.length}'),
            title: items.length == 1 ? title : '$title ${i + 1}',
            note: i == 0 ? note : null,
            opening: items[i],
            onRemove: items.length > 1
                ? () => onChanged([
                      for (var j = 0; j < items.length; j++)
                        if (j != i) items[j],
                    ])
                : null,
            onChanged: (v) => onChanged([
              for (var j = 0; j < items.length; j++)
                if (j == i) v else items[j],
            ]),
          ),
        Padding(
          padding: const EdgeInsets.only(bottom: ChizmaSpace.sm),
          child: InkWell(
            onTap: () => onChanged([...items, standard]),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded,
                      size: 16, color: colors.categorizedColor.primary),
                  const SizedBox(width: 4),
                  Text(
                    'Yana o\'lcham',
                    style: context.text.label
                        .copyWith(color: colors.categorizedColor.primary),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OpeningRow extends StatefulWidget {
  const _OpeningRow({
    super.key,
    required this.title,
    required this.opening,
    required this.onChanged,
    this.onRemove,
    this.note,
  });

  final String title;
  final MasonryOpening opening;
  final String? note;

  final VoidCallback? onRemove;
  final ValueChanged<MasonryOpening> onChanged;

  @override
  State<_OpeningRow> createState() => _OpeningRowState();
}

class _OpeningRowState extends State<_OpeningRow> {
  late final _widthCtrl =
      TextEditingController(text: _RoomRowState._text(widget.opening.widthM));
  late final _heightCtrl =
      TextEditingController(text: _RoomRowState._text(widget.opening.heightM));

  @override
  void dispose() {
    _widthCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final primary = colors.categorizedColor.primary;
    final opening = widget.opening;
    final chosen = opening.count > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.title,
                      style: context.text.body4.copyWith(
                        color: chosen
                            ? colors.neutral.textStrong
                            : colors.neutral.textBody,
                        fontWeight: chosen ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    if (widget.note != null)
                      Text(
                        widget.note!,
                        style: context.text.label
                            .copyWith(color: colors.neutral.textMuted),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: chosen
                    ? () => widget
                        .onChanged(opening.copyWith(count: opening.count - 1))
                    : null,
                icon: const Icon(Icons.remove_circle_outline_rounded),
                color: primary,
                visualDensity: VisualDensity.compact,
              ),
              SizedBox(
                width: 28,
                child: Text(
                  '${opening.count}',
                  textAlign: TextAlign.center,
                  style: context.text.h4
                      .copyWith(color: colors.neutral.textStrong),
                ),
              ),
              if (widget.onRemove != null)
                IconButton(
                  onPressed: widget.onRemove,
                  icon: const Icon(Icons.close_rounded, size: 18),
                  color: colors.neutral.textMuted,
                  tooltip: uz('O\'lchamni olib tashlash'),
                  visualDensity: VisualDensity.compact,
                ),
              IconButton(
                onPressed: () => widget
                    .onChanged(opening.copyWith(count: opening.count + 1)),
                icon: const Icon(Icons.add_circle_outline_rounded),
                color: primary,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          if (chosen)
            Padding(
              padding: const EdgeInsets.only(
                  left: ChizmaSpace.md, bottom: ChizmaSpace.sm),
              child: Row(
                children: [
                  Text(
                    'Bittasi:',
                    style: context.text.label
                        .copyWith(color: colors.neutral.textMuted),
                  ),
                  const SizedBox(width: ChizmaSpace.sm),
                  _SmallNumberField(
                    controller: _widthCtrl,
                    onChanged: (v) =>
                        widget.onChanged(opening.copyWith(widthM: v)),
                  ),
                  Text('  ×  ',
                      style: context.text.body5
                          .copyWith(color: colors.neutral.textMuted)),
                  _SmallNumberField(
                    controller: _heightCtrl,
                    onChanged: (v) =>
                        widget.onChanged(opening.copyWith(heightM: v)),
                  ),
                  Text(' m',
                      style: context.text.label
                          .copyWith(color: colors.neutral.textMuted)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SmallNumberField extends StatelessWidget {
  const _SmallNumberField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return SizedBox(
      width: 56,
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.center,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          LengthLimitingTextInputFormatter(5),
        ],
        onChanged: (raw) {
          final value = double.tryParse(raw.trim().replaceAll(',', '.'));
          if (value != null && value > 0) onChanged(value);
        },
        style: context.text.body4.copyWith(color: colors.neutral.textStrong),
        decoration: const InputDecoration(isDense: true, hintText: '0'),
      ),
    );
  }
}

class _FramePicture extends StatelessWidget {
  const _FramePicture({required this.frame});
  final bool frame;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _FramePainter(frame),
        child: const SizedBox.expand(),
      );
}

class _FramePainter extends CustomPainter {
  _FramePainter(this.frame);
  final bool frame;

  static const _concrete = Color(0xFFA7ADB3);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    _paintCourses(canvas, rect, _brickRed, rows: 8, perRow: 3);
    if (!frame) return;
    final paint = Paint()..color = _concrete;
    final edge = Paint()
      ..color = const Color(0xFF7D848B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final column = size.width * 0.14;
    final beam = size.height * 0.16;
    for (final x in [0.0, size.width / 2 - column / 2, size.width - column]) {
      final r = Rect.fromLTWH(x, beam, column, size.height - beam);
      canvas.drawRect(r, paint);
      canvas.drawRect(r, edge);
    }
    final top = Rect.fromLTWH(0, 0, size.width, beam);
    canvas.drawRect(top, paint);
    canvas.drawRect(top, edge);
  }

  @override
  bool shouldRepaint(_FramePainter old) => old.frame != frame;
}

class _PictureCard extends StatelessWidget {
  const _PictureCard({
    required this.picture,
    required this.title,
    required this.desc,
    required this.selected,
    required this.onTap,
    this.note,
    this.dim = true,
  });

  final Widget picture;
  final String title;
  final String desc;
  final String? note;
  final bool selected;
  final VoidCallback? onTap;

  final bool dim;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final primary = colors.categorizedColor.primary;
    return Opacity(
      opacity: (onTap == null && dim) ? 0.5 : 1,
      child: ChizmaSheet(
        onTap: onTap,
        borderColor: selected ? primary : null,
        color: selected ? primary.withValues(alpha: 0.06) : null,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(ChizmaRadius.md),
              child: SizedBox(width: 96, height: 96, child: picture),
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
                          title,
                          style: context.text.h4
                              .copyWith(color: colors.neutral.textStrong),
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
                  if (note != null) ...[
                    const SizedBox(height: ChizmaSpace.xs),
                    Text(
                      note!,
                      style: context.text.label
                          .copyWith(color: colors.neutral.textMuted),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PurposePicture extends StatelessWidget {
  const _PurposePicture({required this.purpose});
  final MasonryPurpose purpose;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _PurposePainter(purpose),
        child: const SizedBox.expand(),
      );
}

class _PurposePainter extends CustomPainter {
  _PurposePainter(this.purpose);
  final MasonryPurpose purpose;

  static const _sky = Color(0xFFE8F1FA);
  static const _ground = Color(0xFFB9C7A4);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    canvas.drawRect(Offset.zero & size, Paint()..color = _sky);
    canvas.drawRect(
        Rect.fromLTWH(0, h * 0.84, w, h * 0.16), Paint()..color = _ground);

    if (purpose == MasonryPurpose.building) {
      final wall = Rect.fromLTWH(w * 0.2, h * 0.42, w * 0.6, h * 0.42);
      _paintCourses(canvas, wall, _brickRed, rows: 7, perRow: 4);

      final roof = Path()
        ..moveTo(w * 0.12, h * 0.44)
        ..lineTo(w * 0.5, h * 0.14)
        ..lineTo(w * 0.88, h * 0.44)
        ..close();
      canvas.drawPath(roof, Paint()..color = const Color(0xFF5B6B7C));

      canvas.drawRect(Rect.fromLTWH(w * 0.44, h * 0.6, w * 0.14, h * 0.24),
          Paint()..color = const Color(0xFF7A4B2A));
      canvas.drawRect(Rect.fromLTWH(w * 0.26, h * 0.52, w * 0.12, h * 0.12),
          Paint()..color = const Color(0xFFBFD9EE));
      canvas.drawRect(Rect.fromLTWH(w * 0.62, h * 0.52, w * 0.12, h * 0.12),
          Paint()..color = const Color(0xFFBFD9EE));
    } else {
      final wall = Rect.fromLTWH(w * 0.06, h * 0.5, w * 0.88, h * 0.34);
      _paintCourses(canvas, wall, _brickRed, rows: 6, perRow: 6);

      final post = Paint()..color = const Color(0xFF8E3F22);
      for (final x in [0.06, 0.47, 0.88]) {
        canvas.drawRect(
            Rect.fromLTWH(w * x - 1, h * 0.44, w * 0.08, h * 0.4), post);
      }
    }
  }

  @override
  bool shouldRepaint(_PurposePainter old) => old.purpose != purpose;
}

class _MaterialPicture extends StatelessWidget {
  const _MaterialPicture({required this.material});
  final MasonryMaterial material;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _MaterialPainter(material),
        child: const SizedBox.expand(),
      );
}

class _MaterialPainter extends CustomPainter {
  _MaterialPainter(this.material);
  final MasonryMaterial material;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    switch (material) {
      case MasonryMaterial.pishgan:
        _paintCourses(canvas, rect, _brickRed, rows: 8, perRow: 3);
      case MasonryMaterial.xom:
        _paintCourses(canvas, rect, const Color(0xFFC4A57A),
            rows: 7, perRow: 3, mortar: const Color(0xFFA88B62), rough: true);
      case MasonryMaterial.penoblok:
        _paintCourses(canvas, rect, const Color(0xFFEDEBE6),
            rows: 3, perRow: 2, mortar: const Color(0xFFC9C6BE));
      case MasonryMaterial.shlakoblok:
        _paintCourses(canvas, rect, const Color(0xFF8C9093),
            rows: 4, perRow: 2, mortar: const Color(0xFF5F6366), hollow: true);
    }
  }

  @override
  bool shouldRepaint(_MaterialPainter old) => old.material != material;
}

const _brickRed = Color(0xFFB5532F);

void _paintCourses(
  Canvas canvas,
  Rect area,
  Color color, {
  required int rows,
  required int perRow,
  Color mortar = const Color(0xFFD9CFC4),
  bool rough = false,
  bool hollow = false,
}) {
  canvas.save();
  canvas.clipRect(area);
  canvas.drawRect(area, Paint()..color = mortar);
  final joint = math.max(1.5, area.height / rows * 0.12);
  final rowH = area.height / rows;
  final unitW = area.width / perRow;
  final random = math.Random(color.toARGB32() ^ rows);
  for (var r = 0; r < rows; r++) {
    final shift = r.isOdd ? -unitW / 2 : 0.0;
    for (var c = -1; c <= perRow; c++) {
      final x = area.left + shift + c * unitW;
      final brick = Rect.fromLTWH(x + joint / 2,
          area.top + r * rowH + joint / 2, unitW - joint, rowH - joint);
      final shade = rough
          ? (random.nextDouble() - 0.5) * 0.18
          : (random.nextDouble() - 0.5) * 0.08;
      final fill = shade >= 0
          ? Color.lerp(color, Colors.white, shade)!
          : Color.lerp(color, Colors.black, -shade)!;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            brick, Radius.circular(rough ? joint : joint * 0.3)),
        Paint()..color = fill,
      );
      if (hollow) {
        final holeW = brick.width * 0.26, holeH = brick.height * 0.5;
        final hole = Paint()..color = Color.lerp(color, Colors.black, 0.45)!;
        for (final fx in [0.3, 0.7]) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset(brick.left + brick.width * fx, brick.center.dy),
                width: holeW,
                height: holeH,
              ),
              Radius.circular(joint * 0.5),
            ),
            hole,
          );
        }
      }
    }
  }
  canvas.restore();
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    required this.suffix,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String suffix;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: context.text.label.copyWith(color: colors.neutral.textBody),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            LengthLimitingTextInputFormatter(7),
          ],
          onChanged: onChanged,
          style: context.text.h4.copyWith(color: colors.neutral.textStrong),
          decoration: InputDecoration(
            hintText: '0',
            suffixText: uz(suffix),
            suffixStyle:
                context.text.body3.copyWith(color: colors.neutral.textMuted),
          ),
        ),
      ],
    );
  }
}

class _ResultSheet extends StatelessWidget {
  const _ResultSheet({
    required this.estimate,
    required this.brick,
    required this.unitWord,
    required this.areaLabel,
    required this.countLabel,
  });

  final MasonryEstimate estimate;
  final SpecialtyBrick brick;

  final String unitWord;
  final String Function(double) areaLabel;
  final String Function(int) countLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;

    Widget row(String label, String value, {bool strong = false}) => Padding(
          padding: const EdgeInsets.only(bottom: ChizmaSpace.sm),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: context.text.body5
                      .copyWith(color: colors.neutral.textMuted),
                ),
              ),
              Text(
                value,
                style: context.text.body5.copyWith(
                  color: strong
                      ? colors.neutral.textStrong
                      : colors.neutral.textBody,
                  fontWeight: strong ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ),
        );

    final waste = estimate.totalBricks - estimate.laidBricks;

    return ChizmaSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          row(
            estimate.parts.isEmpty ? 'Devor yuzasi' : 'Tashqi devor yuzasi',
            '${areaLabel(estimate.wallAreaM2)} m²',
          ),
          if (estimate.openingsM2 > 0)
            row('Eshik-deraza o\'rni',
                '− ${areaLabel(estimate.openingsM2)} m²'),
          if (estimate.frameM2 > 0)
            row('Karkas va regel o\'rni',
                '− ${areaLabel(estimate.frameM2)} m²'),
          if (estimate.parts.isEmpty) ...[
            if (estimate.openingsM2 > 0 || estimate.frameM2 > 0)
              row('Teriladigan yuza', '${areaLabel(estimate.netAreaM2)} m²'),
            row('1 m² ga', '${areaLabel(estimate.bricksPerM2)} dona'),
          ] else ...[

            Divider(height: 1, color: colors.neutral.border),
            const SizedBox(height: ChizmaSpace.sm),
            for (final part in estimate.parts)
              row(
                '${part.kind.title}'
                    '${part.kind == MasonryPartKind.exterior ? '' : ' ${areaLabel(part.lengthM)} m'}'
                    ' · ${part.thickness.label.toLowerCase()}',
                '${countLabel((part.bricks - 1e-9).ceil())} dona',
              ),
          ],
          row('Teriladi', '${countLabel(estimate.laidBricks)} dona'),
          if (waste > 0)
            row(
              'Singanlar uchun zaxira (${areaLabel(brick.wastePct)}%)',
              '+ ${countLabel(waste)} dona',
            ),
          row(
            'Jami $unitWord',
            '${countLabel(estimate.totalBricks)} dona',
            strong: true,
          ),
          Divider(height: 1, color: colors.neutral.border),
          const SizedBox(height: ChizmaSpace.sm),
          row(
            '1 dona narxi',
            '${formatSom(brick.price)} so\'m',
          ),
          row(
            unitWord == 'blok' ? 'Blok narxi' : 'G\'isht narxi',
            '${formatSom(estimate.brickCost.toDouble())} so\'m',
          ),
          if (estimate.mortarCost > 0)
            row('Qorishma (qum, ohak, sement)',
                '${formatSom(estimate.mortarCost.toDouble())} so\'m'),
          Divider(height: 1, color: colors.neutral.border),
          const SizedBox(height: ChizmaSpace.sm),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Material tannarxi',
                  style: context.text.body4.copyWith(
                    color: colors.neutral.textStrong,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${formatSom(estimate.total.toDouble())} so\'m',
                style: context.text.h4.copyWith(
                  color: colors.categorizedColor.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
