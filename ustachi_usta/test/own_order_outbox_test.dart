
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/core/singletons/storage/storage.dart';
import 'package:ustachi/core/utils/either.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/calculate_ui_models.dart';
import 'package:ustachi/features/orders/domain/entities/own_order_entity.dart';
import 'package:ustachi/features/orders/domain/entities/own_order_payload.dart';
import 'package:ustachi/features/orders/domain/repositories/own_orders_repository.dart';
import 'package:ustachi/features/orders/domain/services/master_drawing_codec.dart';
import 'package:ustachi/features/orders/domain/services/own_order_outbox.dart';

OwnOrderPayload _payload({String syncId = 'ord-1', String name = 'Aziz aka'}) =>
    OwnOrderPayload(
      syncClientId: syncId,
      customerName: name,
      customerPhone: '+998901234567',
      items: const [
        OwnOrderItemEntity(
          title: '1500 × 1600 mm',
          qty: 2,
          materialLabel: 'Plastik',
          drawing: {'ar': 0.94, 'lines': []},
        ),
      ],
    );

class OutboxFakeRepository implements OwnOrdersRepository {
  final sent = <OwnOrderPayload>[];
  Failure? failure;

  @override
  Future<Either<Failure, OwnOrderEntity>> create(OwnOrderPayload payload) async {
    sent.add(payload);
    if (failure != null) return Left(failure!);
    return Right(OwnOrderEntity(
      id: sent.length,
      customerName: payload.customerName,
      status: OwnOrderStatus.newOrder,
      createdAt: DateTime(2026, 7, 28),
    ));
  }

  @override
  Future<Either<Failure, OwnOrderEntity>> detail(int id) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, List<OwnOrderEntity>>> list({
    OwnOrderStatus? status,
  }) async =>
      Right(const []);

  @override
  Future<Either<Failure, void>> remove(int id) async => Right(null);

  @override
  Future<Either<Failure, OwnOrderEntity>> setStatus(
          int id, OwnOrderStatus status) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, OwnOrderEntity>> update(
          int id, OwnOrderPayload payload) async =>
      throw UnimplementedError();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late OutboxFakeRepository repository;
  late OwnOrderOutbox outbox;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});

    PackageInfo.setMockInitialValues(
      appName: 'ustachi',
      packageName: 'uz.ustachi.usta',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
    await StorageRepository.getInstance();
    repository = OutboxFakeRepository();
    outbox = OwnOrderOutbox(repository);
    await outbox.clear();
  });

  group('Qaysi xatoda navbatga qo\'yiladi', () {
    test('tarmoq uzilishi (status yo\'q) — QO\'YILADI', () {
      expect(OwnOrderOutbox.shouldQueue(const ServerFailure('yo\'q', null)),
          isTrue);
    });

    test('server nosozligi (5xx) — QO\'YILADI', () {
      expect(
          OwnOrderOutbox.shouldQueue(const ServerFailure('500', 500)), isTrue);
    });

    test('server RAD etdi (400) — qo\'yilmaydi', () {
      expect(OwnOrderOutbox.shouldQueue(const ServerFailure('xato', 400)),
          isFalse);
      expect(OwnOrderOutbox.shouldQueue(const ServerFailure('auth', 401)),
          isFalse);
    });
  });

  group('Navbat', () {
    test('qo\'shiladi va DISKDA saqlanadi', () async {
      await outbox.add(_payload());

      final restored = OwnOrderOutbox(repository).pending;
      expect(restored, hasLength(1));
      expect(restored.single.customerName, 'Aziz aka');
      expect(restored.single.items.single.qty, 2);
      expect(restored.single.items.single.drawing, isNotEmpty);
    });

    test('AYNI qoralama ikki marta qo\'shilmaydi', () async {
      await outbox.add(_payload(syncId: 'ord-1', name: 'Birinchi'));
      await outbox.add(_payload(syncId: 'ord-1', name: 'Ikkinchi'));

      expect(outbox.pendingCount, 1);
      expect(outbox.pending.single.customerName, 'Ikkinchi',
          reason: 'oxirgi tahrir qoladi');
    });

    test('turli qoralamalar yonma-yon turadi', () async {
      await outbox.add(_payload(syncId: 'ord-1'));
      await outbox.add(_payload(syncId: 'ord-2'));

      expect(outbox.pendingCount, 2);
    });

    test('yuborilgach navbat BO\'SHAYDI', () async {
      await outbox.add(_payload(syncId: 'ord-1'));
      await outbox.add(_payload(syncId: 'ord-2'));

      final sent = await outbox.flush();

      expect(sent, 2);
      expect(repository.sent, hasLength(2));
      expect(outbox.pendingCount, 0);
    });

    test('tarmoq hamon yo\'q — navbatda QOLADI', () async {
      await outbox.add(_payload());
      repository.failure = const ServerFailure('yo\'q', null);

      final sent = await outbox.flush();

      expect(sent, 0);
      expect(outbox.pendingCount, 1, reason: 'keyingi urinishda yana sinaladi');
    });

    test('server RAD etsa navbatdan CHIQADI', () async {
      await outbox.add(_payload());
      repository.failure = const ServerFailure('ism bo\'sh', 400);

      await outbox.flush();

      expect(outbox.pendingCount, 0,
          reason: 'aks holda navbat hech qachon bo\'shamaydi');
    });

    test('bo\'sh navbatda so\'rov ketmaydi', () async {
      final sent = await outbox.flush();

      expect(sent, 0);
      expect(repository.sent, isEmpty);
    });

    test('buzuq yozuv butun navbatni bloklamaydi', () async {
      await StorageRepository.putString('own_orders_outbox_v1', 'axlat{{');

      expect(outbox.pending, isEmpty);
    });

    test('sync ID saqlanadi — server DUBLIKAT yaratmaydi', () async {
      await outbox.add(_payload(syncId: 'ord-42'));
      await outbox.flush();

      expect(repository.sent.single.syncClientId, 'ord-42');
    });
  });

  group('Chizma kodeki v2', () {
    const spec = FramePreviewSpec(
      aspectRatio: 0.71,
      lines: [FrameLine(0, 0.5, 1, 0.5)],
      widthMm: 2000,
      heightMm: 2800,
      regions: [
        FrameRegion(0, 0, 1, 0.7, sharedBottom: true),
        FrameRegion(0.6, 0.7, 1, 1, sharedTop: true, hideOuterStrokeLeft: true),
      ],
      hardwareTweaks: [
        ZoneHardwareTweak(
          zoneCenter: Offset(0.5, 0.3),
          edge: HardwareEdge.right,
          hingeShift: 0.12,
          minZoneWidth: 0.2,
        ),
      ],
      frameBandScale: 0.8,
    );

    test('L-SHAKL kesigi saqlanadi va qaytadi', () {
      final decoded = MasterDrawingCodec.decode(MasterDrawingCodec.encode(spec));

      expect(decoded, isNotNull);
      expect(decoded!.regions, hasLength(2));
      expect(decoded.regions[0].sharedBottom, isTrue);
      expect(decoded.regions[1].sharedTop, isTrue);
      expect(decoded.regions[1].hideOuterStrokeLeft, isTrue);
      expect(decoded.regions[1].left, 0.6);
    });

    test('furnitura tuzatishlari saqlanadi', () {
      final decoded = MasterDrawingCodec.decode(MasterDrawingCodec.encode(spec));

      final tweak = decoded!.hardwareTweaks.single;
      expect(tweak.edge, HardwareEdge.right);
      expect(tweak.hingeShift, 0.12);
      expect(tweak.minZoneWidth, 0.2);
      expect(tweak.maxZoneWidth, 1.01, reason: 'default o\'zgarmaydi');
    });

    test('ko\'rinish koeffitsiyentlari saqlanadi', () {
      final decoded = MasterDrawingCodec.decode(MasterDrawingCodec.encode(spec));

      expect(decoded!.frameBandScale, 0.8);
      expect(decoded.displayScale, 1.0);
    });

    test('o\'lcham va chiziqlar HAMON ProposalSpecCodec formatida', () {
      final json = MasterDrawingCodec.encode(spec);

      expect(json['w'], 2000);
      expect(json['h'], 2800);
      expect(json['ar'], isNotNull);
      expect(json['v'], MasterDrawingCodec.version);
    });

    test('to\'rtburchak chizmada qo\'shimcha kalitlar YO\'Q', () {
      const plain = FramePreviewSpec(
        aspectRatio: 1,
        lines: [],
        widthMm: 1500,
        heightMm: 1500,
      );

      final json = MasterDrawingCodec.encode(plain);

      expect(json.containsKey('regions'), isFalse);
      expect(json.containsKey('tweaks'), isFalse);
      expect(json.containsKey('bandScale'), isFalse);
    });

    test('eski (v1) yozuv ham o\'qiladi', () {
      final decoded = MasterDrawingCodec.decode({
        'ar': 0.94,
        'w': 1500,
        'h': 1600,
        'lines': [
          [0.0, 0.5, 1.0, 0.5],
        ],
      });

      expect(decoded, isNotNull);
      expect(decoded!.widthMm, 1500);
      expect(decoded.regions, isEmpty);
    });

    test('buzuq yozuv null qaytaradi — ekran yiqilmaydi', () {
      expect(MasterDrawingCodec.decode(null), isNull);
      expect(MasterDrawingCodec.decode('axlat'), isNull);
      expect(MasterDrawingCodec.decode(const <String, dynamic>{}), isNull);
    });
  });
}
