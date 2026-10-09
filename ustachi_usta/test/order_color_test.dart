
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/core/utils/either.dart';
import 'package:ustachi/features/marketplace/domain/proposal_spec_codec.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/calculate_ui_models.dart';
import 'package:ustachi/features/marketplace/domain/entities/order_entity.dart' as api;
import 'package:ustachi/features/marketplace/domain/repositories/marketplace_repository.dart';
import 'package:ustachi/features/orders/data/repositories/orders_repository_api.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/frame_drawing.dart';
import 'package:ustachi/features/orders/data/repositories/orders_repository_in_memory.dart';
import 'package:ustachi/features/orders/domain/entities/master_order_entity.dart';
import 'package:ustachi/features/orders/domain/entities/order_spec_codes.dart';
import 'package:ustachi/features/orders/domain/entities/order_stage.dart';
import 'package:ustachi/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:ustachi/features/orders/presentation/view/order_detail_view.dart';

class _FakeApi implements MarketplaceRepository {
  _FakeApi(this.order);

  final api.OrderEntity order;

  @override
  Future<Either<Failure, List<api.OrderEntity>>> feed() async => Right([order]);

  @override
  Future<Either<Failure, List<api.OrderEntity>>> list({String? status, String? scope}) async =>
      Right([order]);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('testda chaqirilmaydi: ${invocation.memberName}');
}

const _zalatoyDub = 0xFFB45300;
const _antratsit = 0xFF48494D;
const _white = 0xFFFFFFFF;

const _spec = FramePreviewSpec(
  aspectRatio: 1.07,
  lines: [FrameLine(0.5, 0, 0.5, 1)],
  widthMm: 1500,
  heightMm: 1400,
);

Map<String, dynamic> _item({required int argb, required String label, String? key}) => {
      'width_mm': 1500,
      'height_mm': 1400,
      'qty': 1,
      'color_key': key ?? 'ZALATOY_DUB',
      'color_argb': argb,
      'color_label': label,
      'spec': ProposalSpecCodec.encode(_spec),
    };

api.OrderEntity _order(Map<String, dynamic> proposal) => api.OrderEntity(
      id: 7,
      title: 'Rom — 2 dona',
      status: api.OrderStatus.published,
      proposal: proposal,
      calculatedPrice: 1500000,
      specialtyCode: 'rom',
      specialtyName: 'Rom ustasi',
      address: 'Chilonzor 12',
      regionName: 'Toshkent',
    );

Map<String, dynamic> _proposal(List<Map<String, dynamic>> items) => {
      'shape_title': 'Deraza',
      'brand_name': 'AKFA',
      'material': 0,
      'layer_type': 1,
      ...items.first,
      'items': items,
      'version': 2,
    };

void main() {
  test('rangli rom: chizma bo\'yaladi, jadvalda rang nomi chiqadi', () async {
    final repo = OrdersRepositoryApi(_FakeApi(_order(
      _proposal([_item(argb: _zalatoyDub, label: 'Zalatoy dub')]),
    )));

    final request = (await repo.requests()).right.single;

    expect(request.frameArgb, _zalatoyDub);
    expect(request.drawings.single.frameArgb, _zalatoyDub);
    expect(request.spec[specColor], 'Zalatoy dub');
  });

  test('savatdagi har rom O\'Z rangida', () async {
    final repo = OrdersRepositoryApi(_FakeApi(_order(_proposal([
      _item(argb: _zalatoyDub, label: 'Zalatoy dub'),
      _item(argb: _antratsit, label: 'Antratsit', key: 'ANTRATSIT'),

      {
        'width_mm': 900,
        'height_mm': 1200,
        'qty': 1,
        'spec': ProposalSpecCodec.encode(_spec),
      },
    ]))));

    final drawings = (await repo.requests()).right.single.drawings;

    expect(drawings.map((d) => d.frameArgb), [_zalatoyDub, _antratsit, _zalatoyDub]);
  });

  test('oq rom: chizma bo\'yalmaydi, jadvalda rang qatori yo\'q', () async {
    final repo = OrdersRepositoryApi(_FakeApi(_order(
      _proposal([_item(argb: _white, label: 'Oq', key: 'WHITE')]),
    )));

    final request = (await repo.requests()).right.single;

    expect(request.frameArgb, isNull);
    expect(request.drawings.single.frameArgb, isNull);
    expect(request.spec.containsKey(specColor), isFalse);
  });

  test('QABUL QILINGAN buyurtmada ham rang saqlanadi', () async {
    final repo = OrdersRepositoryApi(_FakeApi(_order(_proposal([
      _item(argb: _zalatoyDub, label: 'Zalatoy dub'),
      _item(argb: _antratsit, label: 'Antratsit', key: 'ANTRATSIT'),
    ]))));

    final order = (await repo.orders()).right.single;

    expect(order.drawings.map((d) => d.frameArgb), [_zalatoyDub, _antratsit]);
    expect(order.spec[specColor], 'Zalatoy dub');
  });

  testWidgets('QABUL QILINGAN buyurtma sahifasida chizma rangli chiziladi',
      (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 2400 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final order = MasterOrderEntity(
      id: '42',
      number: '#42',
      title: 'Zalatoy dub deraza',
      clientName: 'Aziz',
      address: 'Toshkent',
      totalPrice: 1280000,
      stage: OrderStage.accepted,
      createdAt: DateTime(2026, 8, 10),
      drawings: const [
        (spec: _spec, frameArgb: _zalatoyDub),
        (spec: _spec, frameArgb: _antratsit),
      ],
    );

    await tester.pumpWidget(ScreenUtilInit(
      designSize: const Size(428, 926),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) => TranslationProvider(
        child: MaterialApp(
          home: BlocProvider(
            create: (_) => OrdersBloc(repository: OrdersRepositoryInMemory()),
            child: Scaffold(
              body: SingleChildScrollView(
                child: OrderDetailView(order: order, showStageAction: false),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.pump();

    final tints = tester
        .widgetList<FrameDrawing>(find.byType(FrameDrawing))
        .map((w) => w.frameTint?.toARGB32())
        .toList();
    expect(tints, [_zalatoyDub, _antratsit], reason: 'oq emas, mijoz tanlagan rang');
  });
}
