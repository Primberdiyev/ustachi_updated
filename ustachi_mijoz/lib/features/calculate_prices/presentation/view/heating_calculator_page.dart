import 'package:ustachi/features/calculate_prices/presentation/widgets/calculator_ui.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/price_estimate_notice.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:flutter/services.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/features/calculate_prices/domain/services/heating_calculator.dart';
import 'package:ustachi/features/calculate_prices/domain/services/radiator_catalog.dart';
import 'package:ustachi/features/calculate_prices/presentation/view/proposal_back_navigation.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/proposal/proposal_option_card.dart'
    show formatSom;
import 'package:ustachi/features/marketplace/domain/entities/order_entity.dart';
import 'package:ustachi/features/marketplace/domain/entities/specialty_entity.dart';
import 'package:ustachi/features/marketplace/presentation/view/order_detail_page.dart';
import 'package:ustachi/features/marketplace/presentation/view/trade_order_page.dart';

class HeatingCalculatorPage extends StatefulWidget {
  const HeatingCalculatorPage({super.key, required this.specialty});

  final SpecialtyEntity specialty;

  @override
  State<HeatingCalculatorPage> createState() => _HeatingCalculatorPageState();
}

enum _Step {
  job('Qanday ish kerak?'),
  system('Qaysi tizim bilan?'),
  radiator('Radiator turi'),
  rooms('Xonalar'),
  boiler('Kotyol'),
  warmFloor('Issiq pol'),
  result('Hisob');

  const _Step(this.title);
  final String title;
}

class _HeatingCalculatorPageState extends State<HeatingCalculatorPage> {
  int _step = 0;

  HeatingJob? _job;

  HeatingSystem _system = HeatingSystem.twoPipe;

  RadiatorKind _radiatorKind = RadiatorKind.panel;

  HeatingWall _wall = HeatingWall.solid;

  final WarmFloorUnderlay _underlay = WarmFloorUnderlay.barrier;

  WarmFloorPipeKind _warmFloorPipeKind = WarmFloorPipeKind.plastic;

  double _buildingLengthM = 0;
  final _buildingCtrl = TextEditingController();

  double _boilerDistanceM = 0;
  final _boilerDistanceCtrl = TextEditingController();

  List<HeatingRoom> _rooms = const [HeatingRoom(lengthM: 0, widthM: 0)];

  HeatingBoiler? _boiler;

  static const _maxRooms = 12;

  List<_Step> get _steps => [
        _Step.job,

        if (_job != HeatingJob.warmFloorOnly) ...[
          _Step.system,
          _Step.radiator,
        ],
        _Step.rooms,
        if (_job != HeatingJob.warmFloorOnly) _Step.boiler,

        _Step.warmFloor,
        _Step.result,
      ];

  _Step get _current => _steps[_step];

  double _price(String name) {
    final needle = name.trim().toLowerCase();
    for (final v in widget.specialty.variants) {
      if (v.name.trim().toLowerCase() == needle) return v.pricePerM2;
    }
    return 0;
  }

  double get _pipePrice => _price(_system.pipeVariantName);

  double get _pipe32Price => _price('Truba (1 metr)');

  double get _pipe25Price => _price('Truba 25 mm (1 metr)');

  double get _sectionPrice => _price('Radiator seksiyasi');

  double get _penopleksPrice => _price('Issiq pol: penopleks (1 dona)');
  double get _warmFloorPipePrice => _price(_warmFloorPipeKind.variantName);
  double get _underlayPrice => _price(_underlay.variantName);
  double get _dowelPrice => _price('Issiq pol: qo\'ziqorin (1 dona)');
  double get _clipPrice => _price('Issiq pol: skoba (1 dona)');

  bool get _hasWarmFloorPrice => _penopleksPrice > 0 && _warmFloorPipePrice > 0;

  bool get _hasPrice {
    if (_job == HeatingJob.warmFloorOnly) return _hasWarmFloorPrice;
    final radiator =
        _radiatorKind.isSectional ? _sectionPrice > 0 : _radiatorPrice > 0;
    return radiator && _pipePrice > 0;
  }

  double _collectorPrice(int outlets) =>
      _price(HeatingCalculator.collectorVariantName(outlets));

  double get _amerikankaPrice => _price('Amerikanka');
  double get _collectorBoxPrice => _price('Kollektor shiti');

  double get _usdRate {
    final rate = _price('Dollar kursi');
    return rate > 0 ? rate : RadiatorCatalog.defaultUsdRate;
  }

  RadiatorPanel get _panel => RadiatorCatalog.anchor;

  double get _radiatorPrice {
    final manual = _price('Radiator (AKFA 50×140)');
    return manual > 0 ? manual : _panel.priceSom(_usdRate).toDouble();
  }

  double get _mountPrice => _price('Radiator o\'rnatish to\'plami');
  double get _branchPipePrice => _price('Radiator trubasi (20 mm, 1 metr)');
  double get _teePrice => _price('Troynik');

  double get _valvePrice => _price(_system.valveVariantName);

  double get _legPrice => _price('Radiator oyoqchasi');

  double get _insulationPrice => _price('Truba uteplitel 32 (1 metr)');

  HeatingEstimate? get _estimate => HeatingCalculator.calculate(
        job: _job ?? HeatingJob.system,
        system: _system,
        radiatorKind: _radiatorKind,
        sectionPrice: _sectionPrice,
        rooms: _rooms,
        pipePricePerM: _pipePrice,
        underlay: _underlay,
        warmFloorPipeKind: _warmFloorPipeKind,
        pipe32PricePerM: _pipe32Price,
        penopleksSheetPrice: _penopleksPrice,
        warmFloorPipePricePerM: _warmFloorPipePrice,
        underlayPricePerM2: _underlayPrice,
        dowelPrice: _dowelPrice,
        clipPrice: _clipPrice,
        collectorPriceFor: _collectorPrice,
        amerikankaPrice: _amerikankaPrice,
        collectorBoxPrice: _collectorBoxPrice,
        branchPipePricePerM: _branchPipePrice,
        teePrice: _teePrice,
        valvePrice: _valvePrice,
        radiatorPrice: _radiatorPrice,
        mountPrice: _mountPrice,
        pipe25PricePerM: _pipe25Price,
        buildingLengthM: _buildingLengthM,
        boilerDistanceM: _boilerDistanceM,
        wall: _wall,
        legPrice: _legPrice,
        insulationPricePerM: _insulationPrice,
      );

  bool get _hasRooms => _rooms.any((r) => r.areaM2 > 0);

  static String _num(double value) {
    final rounded = (value * 100).round() / 100;
    return rounded == rounded.roundToDouble()
        ? rounded.round().toString()
        : rounded.toString().replaceAll('.', ',');
  }

  static double? _parse(String raw) {
    final value = double.tryParse(raw.trim().replaceAll(',', '.'));
    return (value == null || value <= 0) ? null : value;
  }

  bool get _canProceed => switch (_current) {
        _Step.job => _job != null,

        _Step.system => true,

        _Step.radiator => true,
        _Step.rooms => _hasRooms,
        _Step.boiler => _boiler != null,
        _Step.warmFloor => true,
        _Step.result => _estimate != null && _hasPrice,
      };

  String? get _missingReason {
    if (_current == _Step.job && _job == null) {
      return 'Qanday ish kerakligini tanlang.';
    }
    if (_current == _Step.system || _current == _Step.radiator) return null;
    if (_current == _Step.rooms && !_hasRooms) {
      return 'Kamida bitta xonaning o\'lchamini yozing.';
    }
    if (_current == _Step.boiler && _boiler == null) {
      return 'Kotyol turini tanlang.';
    }
    if (_current == _Step.result && !_hasPrice) {
      return _job == HeatingJob.warmFloorOnly
          ? 'Narx hali kiritilmagan — tez orada qo\'shiladi. Issiq polning '
              'kvadrati yuqorida turibdi.'
          : 'Narxlar hali kiritilmagan — tez orada qo\'shiladi. Nechta '
              'radiator va necha metr truba kerakligi yuqorida turibdi.';
    }
    return null;
  }

  void _setRoom(int index, HeatingRoom room) => setState(() {
        final next = [..._rooms];
        next[index] = room;
        _rooms = next;
      });

  void _addRoom() => setState(() {
        if (_rooms.length >= _maxRooms) return;
        _rooms = [..._rooms, const HeatingRoom(lengthM: 0, widthM: 0)];
      });

  void _removeRoom(int index) => setState(() {
        if (_rooms.length <= 1) return;
        final next = [..._rooms]..removeAt(index);
        _rooms = next;
      });

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

  Future<void> _goNext() async {
    final e = _estimate;

    if (e == null || !_hasPrice) return;
    if (!e.job.isWarmFloorOnly && _boiler == null) return;

    final navigator = Navigator.of(context);
    final created = await navigator.push<OrderEntity>(
      MaterialPageRoute<OrderEntity>(
        builder: (_) => TradeOrderPage(
          specialty: widget.specialty,
          calculatedPrice: e.total,
          proposal: {
            'calculator': 'variant',
            'engine': 'heating',
            'variant': _boiler?.title ?? e.job.title,
            'variant_note': [
              if (!e.job.isWarmFloorOnly) ...[
                e.system.title,
                '${e.radiators} ta radiator (50×140)',
                '${_num(e.pipeM)} m truba',

                if (e.legs > 0)
                  '${_wall.title.toLowerCase()} devor · '
                      '${e.legs} ta oyoqcha',
              ],
              if (e.warmFloorM2 > 0) '${_num(e.warmFloorM2)} m² issiq pol',
            ].join(' · '),

            'area_m2': e.points.toDouble(),
            'unit': 'nuqta',
            'cost_price': e.total,
            'total_price': e.total,
            'heating_rooms': [
              for (final r in e.rooms)
                {
                  'length_m': r.room.lengthM,
                  'width_m': r.room.widthM,
                  'area_m2': double.parse(r.room.areaM2.toStringAsFixed(2)),
                  'watts': r.watts,
                  'radiators': r.radiators,
                  'warm_floor': r.room.warmFloor,
                },
            ],
            'heating_total_area_m2':
                double.parse(e.totalAreaM2.toStringAsFixed(2)),
            'heating_radiators': e.radiators,
            'heating_watts': e.watts,
            'heating_pipe_m': double.parse(e.pipeM.toStringAsFixed(2)),
            'heating_warm_floor_m2':
                double.parse(e.warmFloorM2.toStringAsFixed(2)),
            'heating_job': e.job.name,
            'heating_system': e.system.name,
            if (e.collectorCost > 0) ...{
              'heating_collector_outlets': e.radiators,
              'heating_collector_cost': e.collectorCost,
            },
            'heating_points': e.points,
            if (_boiler != null) 'heating_boiler': _boiler!.name,
            'heating_boiler_kw': e.boilerKw,
            'heating_radiator_cost': e.radiatorCost,
            'heating_mount_cost': e.mountCost,
            'heating_pipe_cost': e.pipeCost,
            'heating_warm_floor_cost': e.warmFloorCost,
            'heating_boiler_cost': e.boilerCost,
          },
          summary: e.job.isWarmFloorOnly
              ? '${_num(e.warmFloorM2)} m² issiq pol'
              : '${e.radiators} ta radiator · ${_num(e.boilerKw)} kVt kotyol',
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

    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: colors.neutral.black7,
        appBar: AppBar(
          leading: BackButton(onPressed: _back),
          title: const Text('Isitish tizimi'),
        ),
        body: Column(
          children: [
            CalculatorStepHeader(
                step: _step, total: _steps.length, title: _current.title),
            Expanded(
              child: IndexedStack(
                index: _step,
                sizing: StackFit.expand,
                children: [
                  for (final step in _steps)
                    switch (step) {
                      _Step.job => _jobStep(context),
                      _Step.system => _systemStep(context),
                      _Step.radiator => _radiatorStep(context),
                      _Step.rooms => _roomsStep(context),
                      _Step.boiler => _boilerStep(context),
                      _Step.warmFloor => _warmFloorStep(context),
                      _Step.result => _resultStep(context),
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
                            child: Text(_current == _Step.result
                                ? 'Usta chaqirish'
                                : 'Keyingisi'),
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

  Widget _jobStep(BuildContext context) {
    final colors = context.color;

    return _StepBody(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: ChizmaSpace.md),
          child: Text(
            'Bu bo\'limda uyni isitish hisoblanadi. Boshqa santexnika ishi '
            '(suv, kanalizatsiya, kran) kerak bo\'lsa — "Xizmat turlari" dan '
            'usta chaqiring va izohda yozing.\n\n'
            'Issiq pol xonani taxminan '
            '${_num(HeatingCalculator.warmFloorHeightM)} metr balandlikkacha '
            'isitadi, undan yuqorisini radiator isitadi. Shuning uchun issiq '
            'pol odatda radiator bilan birga qo\'yiladi.',
            style: context.text.body5.copyWith(color: colors.neutral.textMuted),
          ),
        ),
        for (final j in HeatingJob.values) ...[
          _ChoiceCard(
            icon: j.isWarmFloorOnly
                ? Icons.waves_rounded
                : Icons.thermostat_outlined,
            title: j.title,
            desc: j.desc,
            note: '',
            selected: _job == j,
            onTap: () => setState(() {
              _job = j;

              if (j.isWarmFloorOnly) _boiler = null;
            }),
          ),
          const SizedBox(height: ChizmaSpace.sm),
        ],
      ],
    );
  }

  Widget _systemStep(BuildContext context) {
    final colors = context.color;

    return _StepBody(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: ChizmaSpace.md),
          child: Text(
            'Truba qanday tortiladi — shunga qarab truba sarfi, nasos va '
            'kollektor o\'zgaradi. Bilmasangiz eng ko\'p ishlatiladigani '
            'qo\'yilgan (ikki trubali) — ustangiz ko\'rib maslahat beradi.',
            style: context.text.body5.copyWith(color: colors.neutral.textMuted),
          ),
        ),
        for (final s in HeatingSystem.values) ...[
          _ChoiceCard(
            icon: switch (s) {
              HeatingSystem.twoPipe => Icons.swap_vert_rounded,
              HeatingSystem.onePipe => Icons.timeline_rounded,
              HeatingSystem.gravity => Icons.water_drop_outlined,
              HeatingSystem.radial => Icons.hub_outlined,
            },
            title: s.title,
            desc: s.desc,
            note: [
              if (!s.needsPump) 'nasos kerak emas',
              if (s.needsCollector) 'kollektor kerak',

              if (s.farRadiatorExtraPct > 0)
                'radiatorlar +${s.farRadiatorExtraPct}% kattaroq olinadi',
            ].join(' · '),
            selected: _system == s,
            onTap: () => setState(() => _system = s),
          ),
          const SizedBox(height: ChizmaSpace.sm),
        ],

        if (_system.needsCollector) ...[
          const SizedBox(height: ChizmaSpace.sm),
          ChizmaSheet(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Binoning uzunligi qancha?',
                  style: context.text.body3
                      .copyWith(color: colors.neutral.textStrong),
                ),
                const SizedBox(height: 4),
                Text(
                  'Har 20 metrga bitta kollektor qo\'yiladi. Bitta '
                  'kollektordan 15 metrgacha radiator ulanadi, chiqishi '
                  '2 tadan 10 tagacha bo\'ladi. Har radiatorga ketadigan '
                  'truba ham shu masofadan chiqariladi.',
                  style: context.text.body5
                      .copyWith(color: colors.neutral.textMuted),
                ),
                const SizedBox(height: ChizmaSpace.md),
                SizedBox(
                  width: 180,
                  child: _NumberField(
                    controller: _buildingCtrl,
                    label: 'Bino uzunligi',
                    onChanged: (v) =>
                        setState(() => _buildingLengthM = _parse(v) ?? 0),
                  ),
                ),
                if (_buildingLengthM > 0) ...[
                  const SizedBox(height: ChizmaSpace.sm),
                  Text(
                    'Kerak bo\'ladi: '
                    '${HeatingCalculator.collectorsFor(_buildingLengthM)} ta '
                    'kollektor',
                    style: context.text.label
                        .copyWith(color: colors.categorizedColor.primary),
                  ),
                ],
                const SizedBox(height: ChizmaSpace.lg),

                Text(
                  'Kotyolxona binodan necha metr uzoqda?',
                  style: context.text.body3
                      .copyWith(color: colors.neutral.textStrong),
                ),
                const SizedBox(height: 4),
                Text(
                  'Har bir kollektorga kotyoldan 2 ta truba tortib boriladi. '
                  'Kotyolxona uyning ichida bo\'lsa 0 yozing.',
                  style: context.text.body5
                      .copyWith(color: colors.neutral.textMuted),
                ),
                const SizedBox(height: ChizmaSpace.md),
                SizedBox(
                  width: 180,
                  child: _NumberField(
                    controller: _boilerDistanceCtrl,
                    label: 'Kotyolxona masofasi',
                    onChanged: (v) =>
                        setState(() => _boilerDistanceM = _parse(v) ?? 0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _radiatorStep(BuildContext context) {
    final colors = context.color;

    return _StepBody(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: ChizmaSpace.md),
          child: Text(
            'Qanday radiator qo\'yamiz? Panel butun dona bilan, qovurg\'ali '
            'esa seksiya bilan hisoblanadi.',
            style: context.text.body5.copyWith(color: colors.neutral.textMuted),
          ),
        ),
        for (final kind in RadiatorKind.values) ...[
          _ChoiceCard(
            icon: kind.isSectional
                ? Icons.view_week_rounded
                : Icons.crop_16_9_rounded,
            title: kind.title,
            desc: kind.desc,
            note: switch (kind) {
              RadiatorKind.panel => _radiatorPrice > 0
                  ? '${_panel.size} — ${formatSom(_radiatorPrice)} so\'m'
                  : 'Narxi hali kiritilmagan',
              RadiatorKind.sectional => _sectionPrice > 0
                  ? '1 seksiya — ${formatSom(_sectionPrice)} so\'m'
                  : 'Narxi hali kiritilmagan',
            },
            selected: _radiatorKind == kind,
            onTap: () => setState(() => _radiatorKind = kind),
          ),
          const SizedBox(height: ChizmaSpace.sm),
        ],
        const SizedBox(height: ChizmaSpace.md),
        Padding(
          padding: const EdgeInsets.only(bottom: ChizmaSpace.md),
          child: Text(
            'Devor nimadan qurilgan? Yumshoq devor radiatorni ko\'tarmaydi — '
            'har radiator tagiga 2 ta oyoqcha qo\'yiladi.',
            style: context.text.body5.copyWith(color: colors.neutral.textMuted),
          ),
        ),
        for (final wall in HeatingWall.values) ...[
          _ChoiceCard(
            icon: wall.needsLegs
                ? Icons.vertical_align_bottom_rounded
                : Icons.grid_view_rounded,
            title: wall.title,
            desc: wall.desc,
            note: !wall.needsLegs
                ? null
                : _legPrice > 0
                    ? '1 oyoqcha — ${formatSom(_legPrice)} so\'m'
                    : 'Narxi hali kiritilmagan',
            selected: _wall == wall,
            onTap: () => setState(() => _wall = wall),
          ),
          const SizedBox(height: ChizmaSpace.sm),
        ],
      ],
    );
  }

  Widget _roomsStep(BuildContext context) {
    final colors = context.color;
    final total = _rooms.fold<double>(0, (s, r) => s + r.areaM2);

    return _StepBody(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: ChizmaSpace.md),
          child: Text(
            _job == HeatingJob.warmFloorOnly
                ? 'Issiq pol qilinadigan xonalarni yozing — kvadrati '
                    'shulardan hisoblanadi.'
                : 'Isitiladigan xonalarni yozing. Radiator har xonaning '
                    'kattaligiga qarab tavsiya qilinadi.',
            style: context.text.body5.copyWith(color: colors.neutral.textMuted),
          ),
        ),
        for (final (index, room) in _rooms.indexed) ...[
          _RoomRow(
            index: index,
            room: room,

            showSections: _job != HeatingJob.warmFloorOnly,
            canRemove: _rooms.length > 1,
            onChanged: (r) => _setRoom(index, r),
            onRemove: () => _removeRoom(index),
            parse: _parse,
          ),
          const SizedBox(height: ChizmaSpace.sm),
        ],
        if (_rooms.length < _maxRooms)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _addRoom,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Yana xona'),
            ),
          ),
        if (total > 0) ...[
          const SizedBox(height: ChizmaSpace.sm),
          Text(
            'Isitiladigan maydon: ${_num(total)} m²',
            style: context.text.body4.copyWith(
              color: colors.categorizedColor.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }

  Widget _boilerStep(BuildContext context) {
    final colors = context.color;
    final kw = HeatingCalculator.boilerKwFor(
        _rooms.fold<double>(0, (s, r) => s + r.areaM2));

    return _StepBody(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: ChizmaSpace.md),
          child: Text(

            '${kw > 0 ? 'Uyingizga taxminan ${_num(kw)} kVt kotyol kerak. '
                'Turini o\'zingiz tanlaysiz.' : 'Kotyol turini tanlang.'}\n\n'
            'Kotyollar har hududning sharoitiga qarab ishlab chiqariladi va '
            'narxi juda xilma-xil — joyingizga qaysi kotyol to\'g\'ri '
            'kelishini va nechaga tushishini ustangiz aytadi.',
            style: context.text.body5.copyWith(color: colors.neutral.textMuted),
          ),
        ),
        for (final b in HeatingBoiler.values) ...[
          _ChoiceCard(
            icon: switch (b) {
              HeatingBoiler.gas => Icons.local_fire_department_outlined,
              HeatingBoiler.electric => Icons.bolt_outlined,
              HeatingBoiler.solid => Icons.forest_outlined,
            },
            title: b.title,
            desc: b.desc,

            note: null,
            selected: _boiler == b,
            onTap: () => setState(() => _boiler = b),
          ),
          const SizedBox(height: ChizmaSpace.sm),
        ],
      ],
    );
  }

  Widget _warmFloorStep(BuildContext context) {
    final colors = context.color;
    final rooms = [
      for (final (index, room) in _rooms.indexed)
        if (room.areaM2 > 0) (index, room),
    ];

    final pickRooms = _job != HeatingJob.warmFloorOnly;

    return _StepBody(
      children: [
        if (pickRooms)
          Padding(
            padding: const EdgeInsets.only(bottom: ChizmaSpace.md),
            child: Text(
              'Qaysi xonaga issiq pol qilamiz? Kerak bo\'lmasa hech birini '
              'belgilamang — keyingi qadamga o\'tavering.\n\n'
              'Issiq pol belgilangan xonada radiator qo\'yish yoki '
              'qo\'ymaslikni o\'zingiz hal qilasiz: pol '
              '${_num(HeatingCalculator.warmFloorHeightM)} metrgacha '
              'isitadi, undan yuqorisini radiator isitadi.',
              style:
                  context.text.body5.copyWith(color: colors.neutral.textMuted),
            ),
          ),
        if (pickRooms)
          for (final (index, room) in rooms) ...[
            ChizmaSheet(
              onTap: () =>
                  _setRoom(index, room.copyWith(warmFloor: !room.warmFloor)),
              borderColor:
                  room.warmFloor ? colors.categorizedColor.primary : null,
              child: Row(
                children: [
                  Icon(
                    Icons.waves_rounded,
                    size: 20,
                    color: room.warmFloor
                        ? colors.categorizedColor.primary
                        : colors.neutral.textMuted,
                  ),
                  const SizedBox(width: ChizmaSpace.md),
                  Expanded(
                    child: Text(
                      '${index + 1}-xona · ${_num(room.lengthM)} × '
                      '${_num(room.widthM)} m (${_num(room.areaM2)} m²)',
                      style: context.text.body4
                          .copyWith(color: colors.neutral.textStrong),
                    ),
                  ),
                  Icon(
                    room.warmFloor
                        ? Icons.check_box_rounded
                        : Icons.check_box_outline_blank_rounded,
                    size: 22,
                    color: room.warmFloor
                        ? colors.categorizedColor.primary
                        : colors.neutral.border,
                  ),
                ],
              ),
            ),

            if (room.warmFloor) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: ChizmaSpace.lg),
                child: ChizmaSheet(
                  onTap: () =>
                      _setRoom(index, room.copyWith(radiator: !room.radiator)),
                  borderColor:
                      room.radiator ? colors.categorizedColor.primary : null,
                  child: Row(
                    children: [
                      Icon(
                        Icons.thermostat_outlined,
                        size: 18,
                        color: room.radiator
                            ? colors.categorizedColor.primary
                            : colors.neutral.textMuted,
                      ),
                      const SizedBox(width: ChizmaSpace.sm),
                      Expanded(
                        child: Text(
                          room.radiator
                              ? 'Bu xonaga radiator ham qo\'yiladi'
                              : 'Bu xonada faqat issiq pol — radiator yo\'q',
                          style: context.text.body5
                              .copyWith(color: colors.neutral.textBody),
                        ),
                      ),
                      Icon(
                        room.radiator
                            ? Icons.check_box_rounded
                            : Icons.check_box_outline_blank_rounded,
                        size: 20,
                        color: room.radiator
                            ? colors.categorizedColor.primary
                            : colors.neutral.border,
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: ChizmaSpace.sm),
          ],

        if (_rooms.any((r) => r.areaM2 > 0 && r.warmFloor) ||
            _job == HeatingJob.warmFloorOnly) ...[
          const SizedBox(height: ChizmaSpace.md),
          Padding(
            padding: const EdgeInsets.only(bottom: ChizmaSpace.md),
            child: Text(
              'Har kvadrat metrga penopleks, '
              '${_num(HeatingCalculator.warmFloorPipePerM2)} metr shlang, '
              '${_underlay.title.toLowerCase()}, '
              '${HeatingCalculator.warmFloorDowelsPerM2} ta '
              'qo\'ziqorin va ${HeatingCalculator.warmFloorClipsPerM2} ta '
              'skoba ketadi. Styajka bunga kirmaydi.\n\n'
              'Pol ostiga qaysi shlang tortiladi?',
              style:
                  context.text.body5.copyWith(color: colors.neutral.textMuted),
            ),
          ),
          for (final k in WarmFloorPipeKind.values) ...[
            _ChoiceCard(
              icon: k == WarmFloorPipeKind.aluminium
                  ? Icons.hardware_outlined
                  : Icons.water_drop_outlined,
              title: k.title,
              desc: k.desc,
              note: _price(k.variantName) > 0
                  ? '1 metr — ${formatSom(_price(k.variantName))} so\'m'
                  : 'Narxi hali kiritilmagan',
              selected: _warmFloorPipeKind == k,
              onTap: () => setState(() => _warmFloorPipeKind = k),
            ),
            const SizedBox(height: ChizmaSpace.sm),
          ],
        ],
      ],
    );
  }

  Widget _resultStep(BuildContext context) {
    final colors = context.color;
    final e = _estimate;
    if (e == null) return const SizedBox.shrink();

    Widget row(String name, String value, {bool strong = false}) => Padding(
          padding: const EdgeInsets.only(bottom: ChizmaSpace.sm),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  name,
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

    return _StepBody(
      children: [
        ChizmaSheet(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              row(
                e.job.isWarmFloorOnly
                    ? 'Issiq pol maydoni'
                    : 'Isitiladigan maydon',
                '${_num(e.totalAreaM2)} m²',
              ),
              if (!e.job.isWarmFloorOnly)
                row('Kerakli issiqlik', '${e.watts} Vt'),
              for (final (index, r) in e.rooms.indexed)
                row(
                  '${index + 1}-xona · ${_num(r.room.areaM2)} m² · '
                  '${r.watts} Vt',
                  e.job.isWarmFloorOnly
                      ? 'issiq pol'

                      : r.radiators == 0
                          ? 'faqat issiq pol'
                          : (e.radiatorKind.isSectional
                                  ? '${r.sections} seksiya'
                                  : '${r.radiators} radiator') +
                              (r.room.warmFloor ? ' + issiq pol' : ''),
                ),
              Divider(height: 1, color: colors.neutral.border),
              const SizedBox(height: ChizmaSpace.sm),
              if (!e.job.isWarmFloorOnly) ...[
                row('Tizim', e.system.title),
                if (e.radiatorKind.isSectional) ...[
                  row('Radiator (qovurg\'ali)', '${e.radiators} ta',
                      strong: true),
                  row('Jami seksiya', '${e.sections} ta', strong: true),
                ] else
                  row('Radiator (${_panel.size})', '${e.radiators} ta',
                      strong: true),
                row('Truba (32 mm)', '${_num(e.pipeM)} m'),

                if (e.transitPipeM > 0)
                  row('  shundan o\'tkazma truba', '${_num(e.transitPipeM)} m'),

                if (e.system.needsCollector && e.radiators > 0)
                  row('  har radiatorga', '${_num(e.pipePerRadiatorM)} m'),

                if (e.collectorPipeM > 0)
                  row('  shundan kotyoldan kollektorga',
                      '${_num(e.collectorPipeM)} m'),
                if (e.pipe25M > 0) row('Truba (25 mm)', '${_num(e.pipe25M)} m'),

                if (e.system.needsPump)
                  row('Nasos', '1 ta · kotyolxona hisobida'),
                if (e.system.needsCollector)
                  row(
                    'Kollektor',
                    '${e.collectors} ta · '
                        '${HeatingCalculator.outletsPerCollector(e.radiators, e.collectors)} '
                        'chiqishli',
                  ),

                if (e.amerikanka > 0) ...[
                  row('  amerikanka', '${e.amerikanka} ta'),
                  row('  kollektor shiti', '${e.collectors} ta'),
                ],

                row('Radiator trubasi (20 mm)', '${_num(e.branchPipeM)} m'),
                if (e.tees > 0) row('Troynik', '${e.tees} ta'),
                row('Radiator vintli', '${e.valves} ta'),

                if (e.insulationM > 0)
                  row('Truba uteplitel', '${_num(e.insulationM)} m'),

                if (e.legs > 0)
                  row('Radiator oyoqchasi (${_wall.title.toLowerCase()})',
                      '${e.legs} ta'),
              ],
              if (e.warmFloorM2 > 0) ...[
                row('Issiq pol', '${_num(e.warmFloorM2)} m²',
                    strong: e.job.isWarmFloorOnly),

                row('  penopleks', '${e.penopleksSheets} dona'),
                row('  ${e.warmFloorPipeKind.title.toLowerCase()}',
                    '${_num(e.warmFloorPipeM)} m'),
                row('  ${e.underlay.title.toLowerCase()}',
                    '${_num(e.warmFloorM2)} m²'),
                row('  qo\'ziqorin', '${e.warmFloorDowels} ta'),
                row('  skoba', '${e.warmFloorClips} ta'),
              ],
              if (!e.job.isWarmFloorOnly)
                row('Kotyol',
                    '${_boiler?.title ?? '—'} · ${_num(e.boilerKw)} kVt'),
              if (_hasPrice) ...[
                Divider(height: 1, color: colors.neutral.border),
                const SizedBox(height: ChizmaSpace.sm),
                if (!e.job.isWarmFloorOnly) ...[
                  if (e.radiatorCost > 0)
                    row('Radiatorlar',
                        '${formatSom(e.radiatorCost.toDouble())} so\'m'),
                  if (e.mountCost > 0)
                    row('O\'rnatish to\'plami',
                        '${formatSom(e.mountCost.toDouble())} so\'m'),
                  row('Truba (32 mm)',
                      '${formatSom(e.pipeCost.toDouble())} so\'m'),
                  if (e.pipe25Cost > 0)
                    row('Truba (25 mm)',
                        '${formatSom(e.pipe25Cost.toDouble())} so\'m'),
                ],
                if (e.warmFloorCost > 0) ...[
                  row('Issiq pol',
                      '${formatSom(e.warmFloorCost.toDouble())} so\'m'),
                  if (e.penopleksCost > 0)
                    row('  penopleks',
                        '${formatSom(e.penopleksCost.toDouble())} so\'m'),
                  if (e.warmFloorPipeCost > 0)
                    row('  ${e.warmFloorPipeKind.title.toLowerCase()}',
                        '${formatSom(e.warmFloorPipeCost.toDouble())} so\'m'),
                  if (e.underlayCost > 0)
                    row('  ${e.underlay.title.toLowerCase()}',
                        '${formatSom(e.underlayCost.toDouble())} so\'m'),
                  if (e.dowelCost > 0)
                    row('  qo\'ziqorin',
                        '${formatSom(e.dowelCost.toDouble())} so\'m'),
                  if (e.clipCost > 0)
                    row('  skoba', '${formatSom(e.clipCost.toDouble())} so\'m'),
                ],

                if (!e.job.isWarmFloorOnly) row('Kotyol', 'ustangiz aytadi'),
                if (e.collectorCost > 0)
                  row('Kollektor',
                      '${formatSom(e.collectorCost.toDouble())} so\'m'),
                if (e.amerikankaCost > 0)
                  row('  amerikanka',
                      '${formatSom(e.amerikankaCost.toDouble())} so\'m'),
                if (e.collectorBoxCost > 0)
                  row('  kollektor shiti',
                      '${formatSom(e.collectorBoxCost.toDouble())} so\'m'),
                if (e.branchPipeCost > 0)
                  row('Radiator trubasi',
                      '${formatSom(e.branchPipeCost.toDouble())} so\'m'),
                if (e.teeCost > 0)
                  row('Troynik', '${formatSom(e.teeCost.toDouble())} so\'m'),
                if (e.valveCost > 0)
                  row('Radiator vintli',
                      '${formatSom(e.valveCost.toDouble())} so\'m'),
                if (e.legCost > 0)
                  row('Radiator oyoqchasi',
                      '${formatSom(e.legCost.toDouble())} so\'m'),
                if (e.insulationCost > 0)
                  row('Truba uteplitel',
                      '${formatSom(e.insulationCost.toDouble())} so\'m'),
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
                      '${formatSom(e.total.toDouble())} so\'m',
                      style: context.text.h4.copyWith(
                        color: colors.categorizedColor.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: ChizmaSpace.sm),

        if (!e.job.isWarmFloorOnly)
          Text(
            'Hisob eng kam kerakli issiqlik bo\'yicha. Uyingiz sovuq bo\'lsa '
            '(shamol tomonda, derazasi ko\'p, shifti baland) ustangiz yana '
            'bitta radiator qo\'shishi mumkin.',
            textAlign: TextAlign.center,
            style: context.text.label.copyWith(color: colors.neutral.textMuted),
          ),

        if (e.job.isWarmFloorOnly)
          Text(
            'Issiq pol xonani taxminan '
            '${_num(HeatingCalculator.warmFloorHeightM)} metr balandlikkacha '
            'isitadi. Undan yuqorisi uchun radiator ham kerak bo\'ladi — bu '
            'hisobda radiator yo\'q.',
            textAlign: TextAlign.center,
            style: context.text.label.copyWith(color: colors.neutral.textMuted),
          ),

        if (!e.job.isWarmFloorOnly &&
            e.system.farRadiatorExtraPct > 0 &&
            !e.radiatorKind.isSectional)
          Text(
            '${e.system.title} tizimda suv halqa bo\'ylab soviydi — '
            'uzoqdagi radiatorni ustangiz bir o\'lcham kattaroq olishi '
            'mumkin (taxminan +${e.system.farRadiatorExtraPct}%).',
            textAlign: TextAlign.center,
            style: context.text.label.copyWith(color: colors.neutral.textMuted),
          ),

        if (!e.job.isWarmFloorOnly)
          Text(
            'Bu hisob kotyolxonagacha: kotyol ham, nasos ham ichida yo\'q. '
            'Kotyolxonada elektr jihozlari, akkumulyator va boshqa mayda '
            'detallar ko\'p, gaz-elektr ta\'minoti esa har joyda boshqacha — '
            'shuning uchun u yerning xarajatini ustangiz joyiga qarab '
            'aytadi.',
            textAlign: TextAlign.center,
            style: context.text.body4.copyWith(color: colors.neutral.textMuted),
          ),
        const SizedBox(height: ChizmaSpace.sm),
        Text(
          'Bu — faqat materialning tannarxi. O\'rnatish haqini har usta '
          'o\'zi belgilaydi (${e.job.isWarmFloorOnly ? 'har xona konturi' : 'har radiator'} '
          'bitta nuqta): javob berganda har bir ustaning jami summasini '
          'ko\'rasiz va solishtirasiz.',
          textAlign: TextAlign.center,
          style: context.text.body4.copyWith(color: colors.neutral.textMuted),
        ),
        const PriceEstimateNotice(),
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

class _RoomRow extends StatefulWidget {
  const _RoomRow({
    required this.index,
    required this.room,
    required this.showSections,
    required this.canRemove,
    required this.onChanged,
    required this.onRemove,
    required this.parse,
  });

  final int index;
  final HeatingRoom room;

  final bool showSections;
  final bool canRemove;
  final ValueChanged<HeatingRoom> onChanged;
  final VoidCallback onRemove;
  final double? Function(String) parse;

  @override
  State<_RoomRow> createState() => _RoomRowState();
}

class _RoomRowState extends State<_RoomRow> {
  late final _lengthCtrl = TextEditingController(
      text: widget.room.lengthM > 0 ? '${widget.room.lengthM}' : '');
  late final _widthCtrl = TextEditingController(
      text: widget.room.widthM > 0 ? '${widget.room.widthM}' : '');

  @override
  void dispose() {
    _lengthCtrl.dispose();
    _widthCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final area = widget.room.areaM2;
    final radiators = HeatingCalculator.radiatorsFor(area);
    final watts = HeatingCalculator.wattsFor(area);

    return ChizmaSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${widget.index + 1}-xona',
                  style: context.text.body3
                      .copyWith(color: colors.neutral.textStrong),
                ),
              ),
              if (widget.canRemove)
                IconButton(
                  onPressed: widget.onRemove,
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  color: colors.neutral.textMuted,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _NumberField(
                  controller: _lengthCtrl,
                  label: 'Uzunligi',
                  onChanged: (v) => widget.onChanged(
                    widget.room.copyWith(lengthM: widget.parse(v) ?? 0),
                  ),
                ),
              ),
              const SizedBox(width: ChizmaSpace.md),
              Expanded(
                child: _NumberField(
                  controller: _widthCtrl,
                  label: 'Eni',
                  onChanged: (v) => widget.onChanged(
                    widget.room.copyWith(widthM: widget.parse(v) ?? 0),
                  ),
                ),
              ),
            ],
          ),
          if (area > 0) ...[
            const SizedBox(height: ChizmaSpace.sm),
            Text(
              widget.showSections
                  ? '${_HeatingCalculatorPageState._num(area)} m² · $watts Vt '
                      '— tavsiya: $radiators ta radiator'
                  : '${_HeatingCalculatorPageState._num(area)} m² issiq pol',
              style: context.text.label
                  .copyWith(color: colors.categorizedColor.primary),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.icon,
    required this.title,
    required this.desc,
    required this.note,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String desc;

  final String? note;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CalculatorOption(
        title: title,
        description: desc,
        note: note,
        selected: selected,
        onTap: onTap,
        leading: Icon(icon));
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
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
            LengthLimitingTextInputFormatter(6),
          ],
          onChanged: onChanged,
          style: context.text.h4.copyWith(color: colors.neutral.textStrong),
          decoration: InputDecoration(
            hintText: '0',
            suffixText: uz('m'),
            suffixStyle:
                context.text.body3.copyWith(color: colors.neutral.textMuted),
          ),
        ),
      ],
    );
  }
}
