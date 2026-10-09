import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/core/utils/either.dart';
import 'package:ustachi/features/marketplace/domain/entities/order_entity.dart'
    as api;
import 'package:ustachi/features/marketplace/domain/entities/order_entity.dart'
    show OrderStatus;
import 'package:ustachi/features/marketplace/domain/repositories/marketplace_repository.dart';
import 'package:ustachi/features/orders/domain/entities/master_order_entity.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/calculate_ui_models.dart';
import 'package:ustachi/features/marketplace/domain/proposal_spec_codec.dart';
import 'package:ustachi/features/orders/domain/entities/order_drawing_spec.dart';
import 'package:ustachi/features/orders/domain/entities/order_request_entity.dart';
import 'package:ustachi/features/orders/domain/entities/order_stage.dart';
import 'package:ustachi/features/orders/domain/repositories/orders_repository.dart';
import 'package:ustachi/features/orders/domain/entities/order_spec_codes.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';

class OrdersRepositoryApi implements OrdersRepository {
  OrdersRepositoryApi(this._api);

  final MarketplaceRepository _api;

  OrderStage _stage(api.OrderStage? stage) => switch (stage) {
        api.OrderStage.accepted => OrderStage.accepted,
        api.OrderStage.measured => OrderStage.measured,
        api.OrderStage.production => OrderStage.production,
        api.OrderStage.installation => OrderStage.installation,
        api.OrderStage.handover => OrderStage.handover,
        null => OrderStage.accepted,
      };

  List<Map<String, dynamic>> _items(api.OrderEntity order) {
    final raw = order.proposal['items'];
    if (raw is List && raw.isNotEmpty) {
      return [
        for (final item in raw)
          if (item is Map) Map<String, dynamic>.from(item),
      ];
    }
    return [order.proposal];
  }

  int _qty(Map<String, dynamic> item) {
    final q = item['qty'];
    if (q is int) return q < 1 ? 1 : q;
    return int.tryParse('$q') ?? 1;
  }

  FramePreviewSpec? _drawing(api.OrderEntity order) =>
      ProposalSpecCodec.decode(order.proposal['spec']);

  List<OrderDrawingSpec> _drawings(api.OrderEntity order) => [
        for (final item in _items(order))
          if (ProposalSpecCodec.decode(item['spec']) case final spec?)
            (
              spec: spec,

              frameArgb: _argb(item['color_argb']) ?? _frameArgb(order),
            ),
      ];

  int? _frameArgb(api.OrderEntity order) => _argb(order.proposal['color_argb']);

  int? _argb(Object? raw) {
    if (raw is! int || raw == 0) return null;
    return (raw & 0xFFFFFF) == 0xFFFFFF ? null : raw;
  }

  Map<String, String> _spec(api.OrderEntity order) {
    final p = order.proposal;
    final spec = <String, String>{};
    void put(String label, Object? value) {
      if (value != null && value.toString().isNotEmpty) {
        spec[label] = value.toString();
      }
    }

    put(specSpecialty, order.specialtyName);
    put(specNote, order.description);

    if (p['calculator'] == 'variant') {
      final variant = p['variant']?.toString() ?? '';
      final note = p['variant_note']?.toString() ?? '';
      put(specVariant, note.isEmpty ? variant : '$variant ($note)');
    }
    if (p['calculator'] == 'area' || p['calculator'] == 'variant') {
      final area = _number(p['area_m2']);
      if (area != null) put(specArea, '${_trim(area)} ${p['unit'] ?? 'm²'}');
      final unitPrice = _positiveInt(p['unit_price']);
      if (unitPrice != null) put(specUnitPrice, unitPrice);
      final place = [
        if (order.regionName != null) order.regionName!,
        if (order.districtName != null) order.districtName!,
        if (order.address.isNotEmpty) order.address,
      ].join(' · ');
      put(specAddress, place);
      return spec;
    }

    final w = p['width_mm'];
    final h = p['height_mm'];
    if (w != null && h != null) put(specSize, '$w×$h');
    put(specShape, p['shape_title']);
    put(specBrand, p['brand_name']);

    if (p['color_key'] != 'WHITE') put(specColor, p['color_label']);
    put(
        specMaterial,
        switch (p['material']) {
          0 => specValuePlastic,
          1 => specValueAluminium,
          2 => specValueTermo,
          _ => null,
        });

    if (p['layer_type'] != null) {
      put(specGlass,
          p['layer_type'] == 1 ? specValueDoubleGlass : specValueSingleGlass);
    }
    if (p['has_sill'] == true) put(specSill, p['sill_width_cm']);
    if (p['flower_size'] != null) {
      put(
          specFlower,
          switch (p['flower_size']) {
            0 => specValueLarge,
            1 => specValueMedium,
            2 => specValueSmall,
            _ => null,
          });
    }
    final items = _items(order);
    if (items.length > 1) {
      final count = items.fold<int>(0, (sum, i) => sum + _qty(i));
      spec[specProduct] = specItemsValue(items.length, count);
      spec.remove(specSize);
    } else if (_qty(items.first) > 1) {
      final size = spec[specSize];
      if (size != null) spec[specSize] = '$size × ${_qty(items.first)}';
    }
    final place = [
      if (order.regionName != null) order.regionName!,
      if (order.districtName != null) order.districtName!,
      if (order.address.isNotEmpty) order.address,
    ].join(' · ');
    put(specAddress, place);
    return spec;
  }

  List<String> _windows(api.OrderEntity order) => [
        for (final item in _items(order))
          if (item['width_mm'] != null && item['height_mm'] != null)
            '${item['width_mm']}×${item['height_mm']}',
      ];

  static double? _number(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value');
  }

  static String _trim(double value) =>
      value == value.roundToDouble() ? '${value.round()}' : '$value';

  static int? _positiveInt(Object? value) {
    final parsed = value is int ? value : int.tryParse('$value');
    return (parsed != null && parsed > 0) ? parsed : null;
  }

  OrderRequestEntity _toRequest(api.OrderEntity order) => OrderRequestEntity(
        id: order.id.toString(),
        number: '#${order.id}',
        title: order.title,
        summary: [
          if (order.districtName != null) order.districtName!,
          if (order.proposal['shape_subtitle'] != null)
            order.proposal['shape_subtitle'].toString(),
        ].join(' · '),
        clientName: order.clientName,
        address: order.address,
        distanceKm: 0,
        calculatedPrice: order.calculatedPrice,
        drawing: _drawing(order),
        material: order.proposal['material'] is int
            ? order.proposal['material'] as int
            : null,
        specialtyCode: order.specialtyCode,
        specialtyName: order.specialtyName,
        expiresAt: order.expiresAt ?? DateTime.now(),
        spec: _spec(order),
        windows: _windows(order),
        drawings: _drawings(order),
        frameArgb: _frameArgb(order),
        proposalItems: _items(order),
        offerSent: order.myResponseStatus == api.ResponseStatus.interested,
        responsesCount: order.responsesCount,
        createdAt: order.createdAt,
        isInvited: order.isInvited,
        inviteDeclined: order.inviteStatus == 'declined',
        isRepair: order.isRepair,
      );

  MasterOrderEntity _toOrder(api.OrderEntity order) {
    final stageDates = <OrderStage, DateTime>{};
    for (final event in order.stageEvents) {
      final stage = _stage(event.stage);
      if (event.createdAt != null) stageDates[stage] = event.createdAt!;
    }
    return MasterOrderEntity(
      id: order.id.toString(),
      number: '#${order.id}',
      title: order.title,
      summary: order.description,
      clientName: order.client?.displayName ?? '',
      clientPhone: order.client?.phoneNumber ?? '',
      address: order.address,
      totalPrice: order.calculatedPrice,
      stage: _stage(order.stage),
      createdAt: order.createdAt ?? DateTime.now(),
      completedAt: order.completedAt,
      rating: order.review?.rating,
      spec: _spec(order),
      drawings: _drawings(order),
      specialtyCode: order.specialtyCode,
      specialtyName: order.specialtyName,
      stageDates: stageDates,
    );
  }

  @override
  Future<Either<Failure, List<OrderRequestEntity>>> requests() async {
    final result = await _api.feed();
    if (result.isLeft) return Left(result.left);

    final open = result.right.where((o) =>
        o.myResponseStatus == null ||
        o.myResponseStatus == api.ResponseStatus.interested);

    final list = open.map(_toRequest).toList()
      ..sort((a, b) {
        if (a.isInvited != b.isInvited) return a.isInvited ? -1 : 1;
        if (a.offerSent != b.offerSent) return a.offerSent ? 1 : -1;
        return b.expiresAt.compareTo(a.expiresAt);
      });
    return Right(list);
  }

  @override
  Future<Either<Failure, List<MasterOrderEntity>>> orders() async {
    final result = await _api.list(scope: 'assigned');
    if (result.isLeft) return Left(result.left);
    return Right(result.right.map(_toOrder).toList());
  }

  @override
  Future<Either<Failure, MasterOrderEntity>> historicalDetail(
      String orderId) async {
    final id = int.tryParse(orderId);
    if (id == null) return Left(ParsingFailure(t.orders.invalidId));
    final result = await _api.detail(id);
    if (result.isLeft) return Left(result.left);
    final order = result.right;
    final closedReason = switch (order.status) {
      OrderStatus.assigned when !order.viewerIsAssigned =>
        ClosedOrderReason.takenByAnother,
      OrderStatus.cancelled => ClosedOrderReason.cancelled,
      OrderStatus.expired => ClosedOrderReason.expired,
      OrderStatus.completed => ClosedOrderReason.completed,
      _ => null,
    };
    return Right(_toOrder(order).copyWith(
      closedReason: closedReason,
      assignedMasterName: order.assignedMaster?.displayName,
      cancelledReason: order.cancelledReason,
      readOnlyHistory: !order.viewerIsAssigned,
    ));
  }

  @override
  Future<Either<Failure, void>> sendOffer({
    required String requestId,
    String? note,
  }) async {
    final id = int.tryParse(requestId);
    if (id == null) return Left(ParsingFailure(t.orders.invalidRequestId));

    final responded = await _api.respond(id, message: note ?? '');
    if (responded.isLeft) return Left(responded.left);
    return Right(null);
  }

  @override
  Future<Either<Failure, void>> declineRequest(
    String requestId, {
    bool invited = false,
    String reason = '',
  }) async {
    final id = int.tryParse(requestId);
    if (id == null) return Left(ParsingFailure(t.orders.invalidRequestId));
    final result = invited
        ? await _api.decline(id, reason: reason)
        : await _api.withdraw(id);
    if (result.isLeft && !_nothingToWithdraw(result.left)) {
      return Left(result.left);
    }
    return Right(null);
  }

  bool _nothingToWithdraw(Failure failure) =>
      failure is ServerFailure && failure.statusCode == 400;

  @override
  Future<Either<Failure, MasterOrderEntity>> completeStage(
      String orderId) async {
    final id = int.tryParse(orderId);
    if (id == null) return Left(ParsingFailure(t.orders.invalidId));
    final result = await _api.advance(id);
    if (result.isLeft) return Left(result.left);
    return Right(_toOrder(result.right));
  }
}
