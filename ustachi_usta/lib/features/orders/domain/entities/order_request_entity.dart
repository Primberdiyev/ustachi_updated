import 'package:equatable/equatable.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/calculate_ui_models.dart';
import 'package:ustachi/features/orders/domain/entities/order_drawing_spec.dart';

class OrderRequestEntity extends Equatable {
  const OrderRequestEntity({
    required this.id,
    required this.number,
    required this.title,
    required this.clientName,
    required this.address,
    required this.distanceKm,
    required this.calculatedPrice,
    required this.expiresAt,
    this.summary = '',
    this.spec = const <String, String>{},
    this.windows = const <String>[],
    this.drawing,
    this.drawings = const <OrderDrawingSpec>[],
    this.frameArgb,
    this.material,
    this.specialtyCode,
    this.specialtyName,
    this.offerSent = false,
    this.responsesCount = 0,
    this.createdAt,
    this.isInvited = false,
    this.inviteDeclined = false,
    this.isRepair = false,
    this.proposalItems = const <Map<String, dynamic>>[],
  });

  final List<Map<String, dynamic>> proposalItems;

  final String id;
  final String number;
  final String title;
  final String summary;
  final String clientName;
  final String address;
  final double distanceKm;

  final int calculatedPrice;

  final String? specialtyCode;
  final String? specialtyName;

  bool get hasPrice => calculatedPrice > 0;

  bool get isRom => material != null;

  final FramePreviewSpec? drawing;

  final List<OrderDrawingSpec> drawings;

  final int? frameArgb;

  final int? material;

  final DateTime expiresAt;

  final Map<String, String> spec;

  final List<String> windows;

  final bool offerSent;

  final int responsesCount;

  final DateTime? createdAt;

  final bool isInvited;

  final bool inviteDeclined;

  final bool isRepair;

  Duration timeLeft(DateTime now) {
    final left = expiresAt.difference(now);
    return left.isNegative ? Duration.zero : left;
  }

  bool isExpired(DateTime now) => !now.isBefore(expiresAt);

  OrderRequestEntity copyWith({bool? offerSent, bool? inviteDeclined}) =>
      OrderRequestEntity(
        id: id,
        number: number,
        title: title,
        clientName: clientName,
        address: address,
        distanceKm: distanceKm,
        calculatedPrice: calculatedPrice,
        expiresAt: expiresAt,
        summary: summary,
        spec: spec,
        windows: windows,
        drawing: drawing,
        drawings: drawings,
        frameArgb: frameArgb,
        material: material,
        specialtyCode: specialtyCode,
        specialtyName: specialtyName,
        offerSent: offerSent ?? this.offerSent,
        responsesCount: responsesCount,
        createdAt: createdAt,
        isInvited: isInvited,
        inviteDeclined: inviteDeclined ?? this.inviteDeclined,
        isRepair: isRepair,
      );

  @override
  List<Object?> get props =>
      [id, expiresAt, offerSent, responsesCount, isInvited, inviteDeclined];
}
