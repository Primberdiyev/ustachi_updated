import 'package:ustachi/features/calculate_prices/presentation/widgets/calculator_ui.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/price_estimate_notice.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:flutter/services.dart';
import 'package:ustachi/features/calculate_prices/domain/services/electrical_calculator.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/proposal/proposal_option_card.dart'
    show formatSom;
import 'package:ustachi/features/marketplace/domain/entities/order_entity.dart';
import 'package:ustachi/features/marketplace/domain/entities/specialty_entity.dart';
import 'package:ustachi/features/marketplace/presentation/view/order_detail_page.dart';
import 'package:ustachi/features/marketplace/presentation/view/trade_order_page.dart';

class ElectricalCalculatorPage extends StatefulWidget {
  const ElectricalCalculatorPage({super.key, required this.specialty});
  final SpecialtyEntity specialty;
  @override
  State<ElectricalCalculatorPage> createState() =>
      _ElectricalCalculatorPageState();
}

class _ElectricalCalculatorPageState extends State<ElectricalCalculatorPage> {
  final _form = GlobalKey<FormState>();
  final _length = TextEditingController(text: '10');
  final _width = TextEditingController(text: '10');
  final _count = TextEditingController(text: '4');
  final _pole = TextEditingController();
  final _panel = TextEditingController();
  final _rooms = List.generate(4, (i) => ElectricalRoom(name: '${i + 1}-xona'));
  int _step = 0;
  bool _showInputError = false;
  bool _copper = true,
      _separate = false,
      _premium = false,
      _premiumConduit = false;
  static const _titles = [
    'Uy va kirish qismi',
    'Montaj va material',
    'Yoritish',
    'Materiallar hisobi'
  ];
  static const _lightNames = {
    ElectricalLight.bulb: 'Oddiy lampochka',
    ElectricalLight.spot: 'Nuqtali svetilnik',
    ElectricalLight.duralight: 'Duralayt',
    ElectricalLight.rail: 'Relsli svetilnik',
  };
  double _value(TextEditingController c) =>
      double.parse(c.text.trim().replaceAll(',', '.'));
  ElectricalEstimate get _estimate => ElectricalCalculator.calculate(
        length: _value(_length),
        width: _value(_width),
        poleDistance: _value(_pole),
        panelDistance: _value(_panel),
        rooms: _rooms,
        copper: _copper,
        separate: _separate,
        premium: _premium,
        premiumConduit: _premiumConduit,
      );
  @override
  void dispose() {
    for (final c in [_length, _width, _count, _pole, _panel]) {
      c.dispose();
    }
    super.dispose();
  }

  void _next() {
    FocusScope.of(context).unfocus();
    if (_step == 0) {
      if (!_form.currentState!.validate()) {
        setState(() => _showInputError = true);
        return;
      }
      _showInputError = false;
      final count = _value(_count).toInt();
      while (_rooms.length < count) {
        _rooms.add(ElectricalRoom(name: '${_rooms.length + 1}-xona'));
      }
      if (_rooms.length > count) _rooms.removeRange(count, _rooms.length);
    }
    setState(() => _step++);
  }

  Future<void> _order() async {
    if (!_form.currentState!.validate()) return;
    final e = _estimate;
    final description = [
      'Elektr montaj: ${_length.text} × ${_width.text} m, ${_rooms.length} xona.',
      _separate ? 'Har xonaga alohida montaj.' : 'Oddiy montaj.',
      'Taxminiy materiallar: ${formatSom(e.total.toDouble())} so‘m.',
      for (final room in _rooms)
        '${room.name}: ${room.lights.map((l) => _lightNames[l]).join(', ')}.',
      for (final item in e.items)
        '${item.name}: ${_num(item.quantity)} ${item.unit} × ${formatSom(item.price.toDouble())} = ${formatSom(item.total.toDouble())} so‘m.',
    ].join('\n');
    final navigator = Navigator.of(context);
    final order = await navigator.push<OrderEntity>(MaterialPageRoute(
      builder: (_) => TradeOrderPage(
        specialty: widget.specialty,
        initialDescription: description,
        summary: '${_rooms.length} xona · elektr montaj',
        proposal: {
          'calculator': 'electrical',
          'engine': 'electrical',
          'materials_only': true,
          'materials_total': e.total,
          'length_m': _value(_length),
          'width_m': _value(_width),
          'pole_distance_m': _value(_pole),
          'panel_distance_m': _value(_panel),
          'copper': _copper,
          'separate': _separate,
          'premium': _premium,
          'premium_conduit': _premiumConduit,
          'rooms': [
            for (final r in _rooms)
              {'name': r.name, 'lights': r.lights.map((l) => l.name).toList()}
          ],
          'items': e.items.map((i) => i.toJson()).toList(),
        },
      ),
    ));
    if (!mounted || order == null) return;
    await navigator.push(MaterialPageRoute<void>(
        builder: (_) => OrderDetailPage(orderId: order.id)));
  }

  static String _num(double n) =>
      n == n.roundToDouble() ? n.toInt().toString() : n.toStringAsFixed(1);
  Widget _labeledField(String label, Widget field) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ExcludeSemantics(
            child: Text(label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.color.neutral.textStrong)),
          ),
          const SizedBox(height: 8),
          Semantics(label: label, child: field),
        ],
      );

  InputDecoration get _fieldDecoration => InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.never,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      );

  Widget _number(String label, TextEditingController c,
          {bool zero = false, bool integer = false, double max = 100}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _labeledField(
            label,
            TextFormField(
              controller: c,
              keyboardType: TextInputType.numberWithOptions(decimal: !integer),
              decoration: _fieldDecoration,
              validator: (s) {
                if ((s ?? '').trim().isEmpty) {
                  return 'Bu maydonni to‘ldiring';
                }
                final v =
                    double.tryParse((s ?? '').trim().replaceAll(',', '.'));
                if (v == null ||
                    !v.isFinite ||
                    v < (zero ? 0 : 1) ||
                    v > max ||
                    (integer && v != v.roundToDouble())) {
                  return '${zero ? 0 : 1}–${max.toInt()} oralig‘ida ${integer ? 'butun ' : ''}son kiriting';
                }
                return null;
              },
            )),
      );
  Widget _choice(String title, String first, String second, bool value,
          ValueChanged<bool> onChanged) =>
      CalculatorSection(
          title: title,
          child: Column(children: [
            CalculatorOption(
                title: first, selected: !value, onTap: () => onChanged(false)),
            const SizedBox(height: 8),
            CalculatorOption(
                title: second, selected: value, onTap: () => onChanged(true)),
          ]));
  Widget _house() =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text(
            'Uy o‘lchamini kiriting. Oshxona, hammom va yo‘lakni ham xonalar soniga qo‘shing. Sim yo‘llarini o‘lchash shart emas.'),
        const SizedBox(height: 20),
        CalculatorSection(
            title: 'Uy o‘lchamlari',
            child: Column(children: [
              _number('Uy uzunligi (m)', _length),
              _number('Uy eni (m)', _width),
              _number('Jami xonalar soni', _count, integer: true, max: 50),
            ])),
        CalculatorSection(
            title: 'Elektr tarmog‘iga ulanish',
            child: Column(children: [
              _number('Ustundan uy kirishigacha (m)', _pole,
                  zero: true, max: 1000),
              _number('Hisoblagichdan shitgacha (m)', _panel,
                  zero: true, max: 1000),
            ])),
        const Text(
            'Hisob 3 m balandlik va teng maydonli xonalar asosida taxmin qilinadi.'),
      ]);
  Widget _materials() => Column(children: [
        _choice('Montaj turi', 'Oddiy montaj', 'Har xonaga alohida', _separate,
            (v) => setState(() => _separate = v)),
        _choice('Ichki kabel', 'Mis', 'Alyuminiy', !_copper,
            (v) => setState(() => _copper = !v)),
        _choice('Materiallar narx toifasi', 'Standart', 'Yuqori toifa',
            _premium, (v) => setState(() => _premium = v)),
        _choice('Yoritish uchun gofra', '800 so‘m/m', '5 500 so‘m/m',
            _premiumConduit, (v) => setState(() => _premiumConduit = v)),
        const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
                'Har xona: 2 rozetka, 1 viklyuchatel, 3 podrozetnik, 1 raspayka qutisi va 4 WAGO. Hisoblagich yonidagi 2 avtomat butun uy uchun bir marta hisoblanadi.')),
      ]);
  Widget _lighting() =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Har xonaga bir yoki bir nechta yoritish turini tanlang.'),
        const SizedBox(height: 12),
        for (int i = 0; i < _rooms.length; i++)
          Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ChizmaSheet(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _labeledField(
                          'Xona nomi',
                          TextFormField(
                              initialValue: _rooms[i].name,
                              decoration: _fieldDecoration,
                              onChanged: (name) => _rooms[i] = ElectricalRoom(
                                  name: name, lights: _rooms[i].lights))),
                      const SizedBox(height: 12),
                      Wrap(spacing: 8, runSpacing: 8, children: [
                        for (final l in ElectricalLight.values)
                          FilterChip(
                              label: Text(_lightNames[l]!),
                              selected: _rooms[i].lights.contains(l),
                              onSelected: (selected) {
                                final lights = {..._rooms[i].lights};
                                if (selected) {
                                  lights.add(l);
                                } else {
                                  if (lights.length == 1) return;
                                  lights.remove(l);
                                }
                                setState(() => _rooms[i] = ElectricalRoom(
                                    name: _rooms[i].name, lights: lights));
                              }),
                      ]),
                    ]),
              )),
        const SizedBox(height: 12),
        const Text(
            'Nuqtali: 25 m² ga 4 dona, yuqoriga yaxlitlanadi. Duralayt: xona perimetri va 1 blok. Relsli: 2 m rels va 1 svetilnik. Qo‘shimcha kabel va gofra hisobga olinadi.'),
      ]);
  Widget _result() {
    final e = _estimate;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ExpansionTile(title: const Text('Hisoblash asoslari'), children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
              'Xonalar taxminan ${_num(e.roomLength)} × ${_num(e.roomWidth)} m, balandlik 3 m. Rozetka kabeli: 5×5 m xonaga 15 m, oddiy chiroqqa 5 m; boshqa o‘lchamlarda xona tomonlariga mutanosib. Shit kirishda deb olinadi. Umumiy liniya: (uy uzunligi + eni) ÷ 2${_separate ? ' × xonalar soni' : ''}. Kabel butun metrga yaxlitlanadi. Izolenta har 2 xonaga 1 dona. Bu taxminiy smeta; kabel kesimi va himoya jihozlarini montajdan oldin elektrik tekshiradi.'),
        )
      ]),
      for (final item in e.items)
        Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ChizmaSheet(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(item.name,
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 6),
                  Text(
                      '${_num(item.quantity)} ${item.unit} × ${formatSom(item.price.toDouble())} so‘m',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: context.color.neutral.textMuted)),
                  const SizedBox(height: 10),
                  Text('${formatSom(item.total.toDouble())} so‘m',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ]))),
      const SizedBox(height: 16),
      OutlinedButton.icon(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(
                text:
                    '${e.items.map((i) => '${i.name}: ${_num(i.quantity)} ${i.unit} × ${i.price} = ${i.total} so‘m').join('\n')}\nMateriallar jami: ${e.total} so‘m. Xizmat haqi kiritilmagan.'));
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Hisob nusxalandi')));
            }
          },
          icon: const Icon(Icons.copy),
          label: const Text('Hisobni nusxalash')),
      const Divider(),
      Text('Taxminiy materiallar jami',
          style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      Text('${formatSom(e.total.toDouble())} so‘m',
          style: Theme.of(context).textTheme.headlineMedium),
      const Text('Xizmat haqi bu summaga kirmaydi.'),
      const Text('Xizmat haqini usta o‘z ilovasida belgilaydi.'),
      const PriceEstimateNotice(),
    ]);
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: _step == 0,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop && _step > 0) setState(() => _step--);
        },
        child: Scaffold(
          backgroundColor: context.color.neutral.black7,
          appBar: AppBar(
              title: const Text('Elektr montaj'),
              leading: BackButton(onPressed: () {
                if (_step > 0) {
                  setState(() => _step--);
                } else {
                  Navigator.of(context).maybePop();
                }
              })),
          body: Center(
              child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Column(children: [
                    const SizedBox(height: 8),
                    CalculatorStepHeader(
                        padding: EdgeInsets.zero,
                        textPadding: const EdgeInsets.symmetric(horizontal: 20),
                        step: _step,
                        total: 4,
                        title: _titles[_step],
                        label: '${_step + 1}/4 · ${_titles[_step]}'),
                    if (_step == 0 && _showInputError)
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                            'Barcha maydonlarni, shu jumladan ikkala kirish masofasini ham to‘ldiring.',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error)),
                      ),
                    Expanded(
                        child: SingleChildScrollView(
                            key: ValueKey(_step),
                            padding: EdgeInsets.fromLTRB(
                                20, _step == 3 ? 4 : 20, 20, 20),
                            child: Form(
                                key: _form,
                                child: switch (_step) {
                                  0 => _house(),
                                  1 => _materials(),
                                  2 => _lighting(),
                                  _ => _result()
                                }))),
                    SafeArea(
                        top: false,
                        child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                    style: FilledButton.styleFrom(
                                        minimumSize: const Size(0, 52),
                                        backgroundColor: context
                                            .color.categorizedColor.primary,
                                        foregroundColor:
                                            context.color.neutral.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10))),
                                    onPressed: _step == 3 ? _order : _next,
                                    child: Text(_step == 3
                                        ? 'Davom etish'
                                        : _step == 2
                                            ? 'Materiallarni hisoblash'
                                            : 'Davom etish'))))),
                  ]))),
        ),
      );
}
