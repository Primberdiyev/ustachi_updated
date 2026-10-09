import 'package:ustachi/features/calculate_prices/presentation/widgets/calculator_ui.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/price_estimate_notice.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:flutter/services.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/features/calculate_prices/domain/services/roof_calculator.dart';
import 'package:ustachi/features/calculate_prices/presentation/view/proposal_back_navigation.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/proposal/proposal_option_card.dart'
    show formatSom;
import 'package:ustachi/features/marketplace/domain/entities/order_entity.dart';
import 'package:ustachi/features/marketplace/domain/entities/specialty_entity.dart';
import 'package:ustachi/features/marketplace/presentation/view/order_detail_page.dart';
import 'package:ustachi/features/marketplace/presentation/view/trade_order_page.dart';

class RoofCalculatorPage extends StatefulWidget {
  const RoofCalculatorPage({super.key, required this.specialty});

  final SpecialtyEntity specialty;

  @override
  State<RoofCalculatorPage> createState() => _RoofCalculatorPageState();
}

enum _Step {
  shape('Tom shakli'),
  material('Tom materiali'),
  size('Uy o\'lchami va hisob');

  const _Step(this.title);
  final String title;
}

class _RoofCalculatorPageState extends State<RoofCalculatorPage> {
  final _lengthCtrl = TextEditingController();
  final _widthCtrl = TextEditingController();

  int _step = 0;
  RoofShape? _shape;
  RoofMaterial? _material;

  double? _length;
  double? _width;

  static const _steps = _Step.values;

  _Step get _current => _steps[_step];

  @override
  void dispose() {
    _lengthCtrl.dispose();
    _widthCtrl.dispose();
    super.dispose();
  }

  double _variantPrice(String name) {
    final needle = name.trim().toLowerCase();
    for (final v in widget.specialty.variants) {
      if (v.name.trim().toLowerCase() == needle) return v.pricePerM2;
    }
    return 0;
  }

  double _priceOf(RoofMaterial material, RoofShape shape) {
    final own = _variantPrice(shape.variantNameFor(material));
    if (own > 0) return own;
    return shape.fallsBackToBase ? _variantPrice(material.title) : 0;
  }

  double get _price =>
      (_material == null || _shape == null) ? 0 : _priceOf(_material!, _shape!);

  bool get _hasPrice => _price > 0;

  RoofEstimate? get _estimate =>
      (_shape == null || _length == null || _width == null)
          ? null
          : RoofCalculator.calculate(
              lengthM: _length!,
              widthM: _width!,
              shape: _shape!,
              material: _material,
              pricePerM2: _price,
            );

  static double? _parse(String raw) {
    final value = double.tryParse(raw.trim().replaceAll(',', '.'));
    return (value == null || value <= 0) ? null : value;
  }

  static String _num(double value) {
    final rounded = (value * 100).round() / 100;
    return rounded == rounded.roundToDouble()
        ? rounded.round().toString()
        : rounded.toString().replaceAll('.', ',');
  }

  bool get _canProceed => switch (_current) {
        _Step.shape => _shape != null,
        _Step.material => _material != null,

        _Step.size => _estimate != null && _hasPrice,
      };

  String? get _missingReason {
    if (_current != _Step.size) return null;
    if (_length == null) return 'Uy uzunligini yozing.';
    if (_width == null) return 'Uy enini yozing.';
    if (!_hasPrice) {

      return '${_material!.title} · ${_shape!.title.toLowerCase()} narxi hali '
          'kiritilmagan — tez orada qo\'shiladi. Boshqa material yoki tom '
          'shaklini tanlab ko\'ring.';
    }
    return null;
  }

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
    final estimate = _estimate;
    if (estimate == null || !_hasPrice) return;

    final navigator = Navigator.of(context);
    final created = await navigator.push<OrderEntity>(
      MaterialPageRoute<OrderEntity>(
        builder: (_) => TradeOrderPage(
          specialty: widget.specialty,
          calculatedPrice: estimate.materialCost,
          proposal: {
            'calculator': 'variant',
            'engine': 'roof',
            'variant': _material!.title,

            'variant_note': [
              '${_num(estimate.areaM2)} m² tom',
              'xom ashyo: ${_material!.rawMaterials}',
              _shape!.title.toLowerCase(),
              'uy ${_num(_length!)}×${_num(_width!)}',
            ].join(' · '),

            'area_m2': double.parse(estimate.areaM2.toStringAsFixed(2)),
            'unit': 'm²',
            'cost_price': estimate.materialCost,
            'total_price': estimate.materialCost,
            'roof_shape': _shape!.name,
            'roof_material': _material!.name,
            'roof_rafter': _material!.rafter.name,
            'roof_cover': _material!.cover.name,
            'roof_house_length_m': _length,
            'roof_house_width_m': _width,
            'roof_overhang_m': RoofCalculator.overhangM,
            'roof_slope_factor': RoofCalculator.slopeFactor(_shape!, _material),

            'roof_price_variant': _shape!.variantNameFor(_material!),
            'roof_house_area_m2':
                double.parse(estimate.houseAreaM2.toStringAsFixed(2)),
            'roof_footprint_m2':
                double.parse(estimate.footprintM2.toStringAsFixed(2)),

            'roof_area_m2': double.parse(estimate.areaM2.toStringAsFixed(2)),
            'roof_price_per_m2': _price,

            if (_material!.priceNote.isNotEmpty)
              'roof_price_note': _material!.priceNote,
          },

          summary: '${_num(estimate.areaM2)} m² tom · '
              '${_material!.rawMaterials}',
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
    final stepCount = _steps.length;

    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: colors.neutral.black7,
        appBar: AppBar(
          leading: BackButton(onPressed: _back),
          title: const Text('Tom yopish'),
        ),
        body: Column(
          children: [

            CalculatorStepHeader(
                step: _step, total: stepCount, title: _current.title),
            Expanded(
              child: IndexedStack(
                index: _step,
                sizing: StackFit.expand,
                children: [
                  for (final step in _steps)
                    switch (step) {
                      _Step.shape => _ShapeStep(
                          value: _shape,
                          onChanged: (v) => setState(() => _shape = v),
                        ),
                      _Step.material => _MaterialStep(
                          value: _material,

                          priceOf: (m) =>
                              _priceOf(m, _shape ?? RoofShape.gable),
                          onChanged: (v) => setState(() => _material = v),
                        ),
                      _Step.size => _sizeStep(context),
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

  Widget _sizeStep(BuildContext context) {
    final colors = context.color;
    final estimate = _estimate;
    final shape = _shape;
    final material = _material;

    return _StepBody(
      children: [
        ChizmaSheet(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Uyingizning o\'lchamini yozing',
                style:
                    context.text.h4.copyWith(color: colors.neutral.textStrong),
              ),
              const SizedBox(height: 4),
              Text(
                'Narx uy maydoniga hisoblanadi: tomning qiyaligi, devordan '
                'chiqishi va tarnovi 1 m² narxining ichida.',
                style: context.text.body5
                    .copyWith(color: colors.neutral.textMuted),
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
            ],
          ),
        ),
        const SizedBox(height: ChizmaSpace.lg),
        if (estimate != null && shape != null && material != null) ...[
          _ResultSheet(
            estimate: estimate,
            shape: shape,
            material: material,
            lengthM: _length!,
            widthM: _width!,
            label: _num,
          ),
          const SizedBox(height: ChizmaSpace.sm),
          Text(

            [
              if (material.priceNote.isNotEmpty) material.priceNote,
              'Bu — faqat materialning tannarxi. Yopish haqini har usta o\'zi '
                  'belgilaydi: javob berganda har bir ustaning jami '
                  'summasini ko\'rasiz va solishtirasiz.',
            ].join('\n'),
            textAlign: TextAlign.center,
            style: context.text.body4.copyWith(color: colors.neutral.textMuted),
          ),
        ],
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

class _ShapeStep extends StatelessWidget {
  const _ShapeStep({required this.value, required this.onChanged});

  final RoofShape? value;
  final ValueChanged<RoofShape> onChanged;

  @override
  Widget build(BuildContext context) {
    return _StepBody(
      children: [
        for (final s in RoofShape.values) ...[
          _PictureCard(
            picture: _ShapePicture(shape: s),
            title: s.title,
            desc: s.desc,
            selected: value == s,
            onTap: () => onChanged(s),
          ),
          const SizedBox(height: ChizmaSpace.md),
        ],
      ],
    );
  }
}

class _MaterialStep extends StatelessWidget {
  const _MaterialStep({
    required this.value,
    required this.priceOf,
    required this.onChanged,
  });

  final RoofMaterial? value;
  final double Function(RoofMaterial) priceOf;
  final ValueChanged<RoofMaterial> onChanged;

  @override
  Widget build(BuildContext context) {
    return _StepBody(
      children: [
        for (final m in RoofMaterial.values) ...[
          _PictureCard(
            picture: _MaterialPicture(material: m),
            title: m.title,

            desc: m.priceNote.isEmpty ? m.desc : '${m.desc} ${m.priceNote}',

            note: priceOf(m) > 0
                ? '${formatSom(priceOf(m))} so\'m / m² (uy maydoniga)'
                : 'Narxi hali kiritilmagan',
            selected: value == m,
            onTap: () => onChanged(m),
          ),
          const SizedBox(height: ChizmaSpace.md),
        ],
      ],
    );
  }
}

class _ShapePicture extends StatelessWidget {
  const _ShapePicture({required this.shape});
  final RoofShape shape;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _ShapePainter(shape),
        child: const SizedBox.expand(),
      );
}

class _ShapePainter extends CustomPainter {
  _ShapePainter(this.shape);
  final RoofShape shape;

  static const _sky = Color(0xFFE8F1FA);
  static const _wall = Color(0xFFD8CBB8);
  static const _wallDark = Color(0xFFBFB09A);
  static const _roof = Color(0xFF5B6B7C);
  static const _roofDark = Color(0xFF41505E);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    canvas.drawRect(Offset.zero & size, Paint()..color = _sky);

    final wall = Paint()..color = _wall;
    final wallSide = Paint()..color = _wallDark;
    final roof = Paint()..color = _roof;
    final roofSide = Paint()..color = _roofDark;

    Path poly(List<Offset> points) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (final p in points.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      return path..close();
    }

    switch (shape) {

      case RoofShape.single:
        canvas.drawRect(
            Rect.fromLTWH(w * 0.18, h * 0.46, w * 0.58, h * 0.4), wall);
        canvas.drawPath(
          poly([
            Offset(w * 0.76, h * 0.46),
            Offset(w * 0.9, h * 0.54),
            Offset(w * 0.9, h * 0.86),
            Offset(w * 0.76, h * 0.86),
          ]),
          wallSide,
        );
        canvas.drawPath(
          poly([
            Offset(w * 0.12, h * 0.46),
            Offset(w * 0.82, h * 0.2),
            Offset(w * 0.96, h * 0.28),
            Offset(w * 0.26, h * 0.54),
          ]),
          roof,
        );

      case RoofShape.gable:
        canvas.drawRect(
            Rect.fromLTWH(w * 0.2, h * 0.52, w * 0.56, h * 0.34), wall);
        canvas.drawPath(
          poly([
            Offset(w * 0.76, h * 0.52),
            Offset(w * 0.9, h * 0.44),
            Offset(w * 0.9, h * 0.78),
            Offset(w * 0.76, h * 0.86),
          ]),
          wallSide,
        );

        canvas.drawPath(
          poly([
            Offset(w * 0.2, h * 0.52),
            Offset(w * 0.48, h * 0.28),
            Offset(w * 0.76, h * 0.52),
          ]),
          wall,
        );

        canvas.drawPath(
          poly([
            Offset(w * 0.14, h * 0.56),
            Offset(w * 0.48, h * 0.26),
            Offset(w * 0.48, h * 0.34),
            Offset(w * 0.22, h * 0.56),
          ]),
          roof,
        );
        canvas.drawPath(
          poly([
            Offset(w * 0.48, h * 0.26),
            Offset(w * 0.82, h * 0.56),
            Offset(w * 0.74, h * 0.56),
            Offset(w * 0.48, h * 0.34),
          ]),
          roof,
        );

        canvas.drawPath(
          poly([
            Offset(w * 0.48, h * 0.26),
            Offset(w * 0.62, h * 0.18),
            Offset(w * 0.96, h * 0.48),
            Offset(w * 0.82, h * 0.56),
          ]),
          roofSide,
        );

      case RoofShape.hip:
        canvas.drawRect(
            Rect.fromLTWH(w * 0.2, h * 0.54, w * 0.56, h * 0.32), wall);
        canvas.drawPath(
          poly([
            Offset(w * 0.76, h * 0.54),
            Offset(w * 0.9, h * 0.46),
            Offset(w * 0.9, h * 0.78),
            Offset(w * 0.76, h * 0.86),
          ]),
          wallSide,
        );

        canvas.drawPath(
          poly([
            Offset(w * 0.14, h * 0.58),
            Offset(w * 0.5, h * 0.3),
            Offset(w * 0.82, h * 0.58),
          ]),
          roof,
        );

        canvas.drawPath(
          poly([
            Offset(w * 0.5, h * 0.3),
            Offset(w * 0.72, h * 0.22),
            Offset(w * 0.96, h * 0.5),
            Offset(w * 0.82, h * 0.58),
          ]),
          roofSide,
        );
    }
  }

  @override
  bool shouldRepaint(_ShapePainter old) => old.shape != shape;
}

class _MaterialPicture extends StatelessWidget {
  const _MaterialPicture({required this.material});
  final RoofMaterial material;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _MaterialPainter(material),
        child: const SizedBox.expand(),
      );
}

class _MaterialPainter extends CustomPainter {
  _MaterialPainter(this.material);
  final RoofMaterial material;

  static const _shifer = Color(0xFF9BA6A8);
  static const _tunuka = Color(0xFF8FA3B5);
  static const _cherepitsa = Color(0xFFB4543A);
  static const _profnastil = Color(0xFF5E7F63);
  static const _beton = Color(0xFFAFAFA8);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    switch (material.cover) {
      case RoofCover.shifer:
        _wavy(canvas, rect, _shifer);
      case RoofCover.tunuka:
        _sheets(canvas, rect, _tunuka);
      case RoofCover.cherepitsa:
        _tiles(canvas, rect, _cherepitsa);
      case RoofCover.profnastil:
        _ribs(canvas, rect, _profnastil);
      case RoofCover.ruberoid:
        _slab(canvas, rect, _beton);
    }

    _rafterStrip(canvas, rect);
  }

  void _wavy(Canvas canvas, Rect r, Color color) {
    canvas.drawRect(r, Paint()..color = color);
    const waves = 5;
    final step = r.width / waves;
    for (var i = 0; i < waves; i++) {
      final x = r.left + i * step;

      canvas.drawRect(
        Rect.fromLTWH(x, r.top, step * 0.5, r.height),
        Paint()..color = Color.lerp(color, Colors.white, 0.3)!,
      );
      canvas.drawRect(
        Rect.fromLTWH(x + step * 0.5, r.top, step * 0.5, r.height),
        Paint()..color = Color.lerp(color, Colors.black, 0.22)!,
      );
    }

    final edge = Path()..moveTo(r.left, r.bottom);
    for (var i = 0; i < waves; i++) {
      final x = r.left + i * step;
      edge.quadraticBezierTo(
          x + step * 0.5, r.bottom - r.height * 0.09, x + step, r.bottom);
    }
    edge
      ..lineTo(r.right, r.bottom)
      ..lineTo(r.left, r.bottom)
      ..close();
    canvas.drawPath(
        edge, Paint()..color = Color.lerp(color, Colors.black, 0.3)!);
  }

  void _sheets(Canvas canvas, Rect r, Color color) {
    canvas.drawRect(r, Paint()..color = color);
    final seam = Paint()
      ..color = Color.lerp(color, Colors.black, 0.32)!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawLine(
        Offset(r.center.dx, r.top), Offset(r.center.dx, r.bottom), seam);
    for (final f in [0.38, 0.76]) {
      canvas.drawLine(
        Offset(r.left, r.top + r.height * f),
        Offset(r.right, r.top + r.height * f),
        Paint()
          ..color = Color.lerp(color, Colors.black, 0.18)!
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }

    canvas.save();
    canvas.clipRect(r);
    final gloss = Path()
      ..moveTo(r.left, r.top + r.height * 0.55)
      ..lineTo(r.left + r.width * 0.55, r.top)
      ..lineTo(r.left + r.width * 0.75, r.top)
      ..lineTo(r.left, r.top + r.height * 0.85)
      ..close();
    canvas.drawPath(
        gloss, Paint()..color = Colors.white.withValues(alpha: 0.28));
    canvas.restore();
  }

  void _tiles(Canvas canvas, Rect r, Color color) {
    canvas.drawRect(r, Paint()..color = Color.lerp(color, Colors.black, 0.25)!);
    const rows = 5, perRow = 4;
    final rowH = r.height / rows;
    final tileW = r.width / perRow;
    for (var row = 0; row < rows; row++) {
      final shift = row.isOdd ? -tileW / 2 : 0.0;
      for (var c = -1; c <= perRow; c++) {
        final x = r.left + shift + c * tileW;
        final tile =
            Rect.fromLTWH(x + 1, r.top + row * rowH, tileW - 2, rowH * 1.25);
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            tile,
            bottomLeft: Radius.circular(tileW * 0.45),
            bottomRight: Radius.circular(tileW * 0.45),
          ),
          Paint()
            ..color =
                row.isOdd ? color : Color.lerp(color, Colors.white, 0.12)!,
        );
      }
    }
  }

  void _ribs(Canvas canvas, Rect r, Color color) {
    canvas.drawRect(r, Paint()..color = color);
    final rib = Paint()..color = Color.lerp(color, Colors.white, 0.28)!;
    final shadow = Paint()..color = Color.lerp(color, Colors.black, 0.28)!;
    final step = r.width / 7;
    for (var i = 0; i < 7; i++) {
      final x = r.left + i * step;
      canvas.drawRect(Rect.fromLTWH(x, r.top, step * 0.45, r.height), rib);
      canvas.drawRect(
          Rect.fromLTWH(x + step * 0.45, r.top, step * 0.2, r.height), shadow);
    }
  }

  void _slab(Canvas canvas, Rect r, Color color) {
    canvas.drawRect(r, Paint()..color = color);
    final seam = Paint()
      ..color = Color.lerp(color, Colors.black, 0.35)!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (final f in [0.34, 0.67]) {
      canvas.drawLine(Offset(r.left, r.top + r.height * f),
          Offset(r.right, r.top + r.height * f), seam);
    }

    canvas.drawRect(
      Rect.fromLTWH(r.left, r.top + r.height * 0.12, r.width, r.height * 0.14),
      Paint()..color = const Color(0xFF3B3B3B),
    );
  }

  void _rafterStrip(Canvas canvas, Rect r) {
    final color = switch (material.rafter) {
      RoofRafter.terak => const Color(0xFFD8C08E),
      RoofRafter.sasna => const Color(0xFFA9793F),
      RoofRafter.plita => const Color(0xFF8E8E88),
      RoofRafter.metall => const Color(0xFF6E757A),
    };
    final strip = Rect.fromLTWH(
        r.left, r.bottom - r.height * 0.22, r.width, r.height * 0.22);
    canvas.drawRect(strip, Paint()..color = color);

    final end = Paint()..color = Color.lerp(color, Colors.black, 0.22)!;
    final step = r.width / 5;
    for (var i = 0; i < 5; i++) {
      canvas.drawRect(
        Rect.fromLTWH(r.left + i * step + step * 0.2, strip.top + 2,
            step * 0.35, strip.height - 4),
        end,
      );
    }
  }

  @override
  bool shouldRepaint(_MaterialPainter old) => old.material != material;
}

class _PictureCard extends StatelessWidget {
  const _PictureCard({
    required this.picture,
    required this.title,
    required this.desc,
    required this.selected,
    required this.onTap,
    this.note,
  });

  final Widget picture;
  final String title;
  final String desc;
  final String? note;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return CalculatorOption(
        title: title,
        description: desc,
        note: note,
        selected: selected,
        onTap: onTap,
        leading: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: ColorFiltered(
                colorFilter: const ColorFilter.matrix([
                  0.2126,
                  0.7152,
                  0.0722,
                  0,
                  0,
                  0.2126,
                  0.7152,
                  0.0722,
                  0,
                  0,
                  0.2126,
                  0.7152,
                  0.0722,
                  0,
                  0,
                  0,
                  0,
                  0,
                  1,
                  0
                ]),
                child: SizedBox(width: 52, height: 44, child: picture))));
  }
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
    required this.shape,
    required this.material,
    required this.lengthM,
    required this.widthM,
    required this.label,
  });

  final RoofEstimate estimate;
  final RoofShape shape;
  final RoofMaterial material;
  final double lengthM;
  final double widthM;
  final String Function(double) label;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;

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

    return ChizmaSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          row('Uy o\'lchami', '${label(lengthM)} × ${label(widthM)} m'),
          row('Uy maydoni', '${label(estimate.houseAreaM2)} m²', strong: true),

          row(
            '${shape.title} tom yuzasi (taxminan)',
            '${label(estimate.areaM2)} m²',
          ),
          Divider(height: 1, color: colors.neutral.border),
          const SizedBox(height: ChizmaSpace.sm),
          row('${material.title} · ${shape.title.toLowerCase()}', ''),
          if (estimate.pricePerM2 > 0) ...[
            row('1 m² uy maydoniga', '${formatSom(estimate.pricePerM2)} so\'m'),
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
                  '${formatSom(estimate.materialCost.toDouble())} so\'m',
                  style: context.text.h4.copyWith(
                    color: colors.categorizedColor.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ] else
            Text(
              'Bu materialning 1 m² narxi hali kiritilmagan — tez orada '
              'qo\'shamiz. Tom maydoni esa yuqorida turibdi.',
              style:
                  context.text.body5.copyWith(color: colors.neutral.textMuted),
            ),
        ],
      ),
    );
  }
}
