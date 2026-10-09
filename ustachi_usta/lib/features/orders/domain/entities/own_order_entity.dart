import 'package:equatable/equatable.dart';

enum OwnOrderStatus {
  draft('draft'),
  newOrder('new'),
  inProgress('in_progress'),
  done('done'),
  debt('debt'),
  cancelled('cancelled');

  const OwnOrderStatus(this.wire);

  final String wire;

  static OwnOrderStatus fromWire(Object? raw) => values.firstWhere(
        (status) => status.wire == raw,
        orElse: () => OwnOrderStatus.newOrder,
      );

  bool get isClosed =>
      this == OwnOrderStatus.done || this == OwnOrderStatus.cancelled;
}

class OwnOrderItemEntity extends Equatable {
  const OwnOrderItemEntity({
    required this.title,
    required this.qty,
    this.id,
    this.materialLabel = '',
    this.widthMm = 0,
    this.heightMm = 0,
    this.drawing = const <String, dynamic>{},
  });

  final int? id;
  final String title;
  final String materialLabel;
  final int widthMm;
  final int heightMm;
  final int qty;

  final Map<String, dynamic> drawing;

  String get subtitle => materialLabel;

  @override
  List<Object?> get props => [id, title, qty, widthMm, heightMm];
}

class OwnOrderEntity extends Equatable {
  const OwnOrderEntity({
    required this.id,
    required this.customerName,
    required this.status,
    required this.createdAt,
    this.syncClientId = '',
    this.customerPhone = '',
    this.customerAddress = '',
    this.deadline,
    this.note = '',
    this.completedAt,
    this.items = const <OwnOrderItemEntity>[],
  });

  final int id;
  final String syncClientId;

  final String customerName;
  final String customerPhone;
  final String customerAddress;

  final DateTime? deadline;
  final String note;

  final OwnOrderStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final List<OwnOrderItemEntity> items;

  int get productCount => items.fold(0, (sum, item) => sum + item.qty);

  String get number => '#$id';

  String get summary => customerAddress;

  @override
  List<Object?> get props => [id, status, items.length];
}
