import 'package:equatable/equatable.dart';
import 'package:ustachi/features/orders/domain/entities/order_drawing_spec.dart';
import 'package:ustachi/features/orders/domain/entities/order_stage.dart';
import 'package:ustachi/features/orders/domain/entities/own_order_entity.dart';

enum ClosedOrderReason { takenByAnother, cancelled, expired, completed }

class MasterOrderEntity extends Equatable {
  const MasterOrderEntity({
    required this.id,
    required this.number,
    required this.title,
    required this.clientName,
    this.clientPhone = '',
    required this.address,
    required this.totalPrice,
    required this.stage,
    required this.createdAt,
    this.summary = '',
    this.prepaid = 0,
    this.dueDate,
    this.completedAt,
    this.rating,
    this.unreadMessages = 0,
    this.spec = const <String, String>{},
    this.stageDates = const <OrderStage, DateTime>{},
    this.ownStatus,
    this.productCount = 0,
    this.drawings = const <OrderDrawingSpec>[],
    this.proposalItems = const <Map<String, dynamic>>[],
    this.specialtyCode,
    this.specialtyName,
    this.closedReason,
    this.assignedMasterName,
    this.cancelledReason = '',
    this.readOnlyHistory = false,
  });

  final String? specialtyCode;
  final String? specialtyName;
  final ClosedOrderReason? closedReason;
  final String? assignedMasterName;
  final String cancelledReason;
  final bool readOnlyHistory;
  bool get isReadOnlyHistory => readOnlyHistory || closedReason != null;

  bool get isRom =>
      specialtyCode == null ||
      specialtyCode == 'rom' ||
      specialtyCode == 'window';

  List<OrderStage> get activeStages => OrderStage.stagesFor(isRom: isRom);

  int get effectiveStageTotal => activeStages.length;

  int get effectiveStageStep {
    final idx = activeStages.indexOf(stage);

    return idx != -1 ? idx + 1 : activeStages.length;
  }

  final List<Map<String, dynamic>> proposalItems;

  final String id;

  final String number;
  final String title;

  final String summary;
  final String clientName;

  /// Mijoz telefoni. Server uni FAQAT tanlangan ustaga beradi, shuning
  /// uchun bo'sh bo'lsa — hali tanlanmagan (yoki eski buyurtma).
  final String clientPhone;
  final String address;

  final int totalPrice;
  final int prepaid;

  final OrderStage stage;
  final DateTime createdAt;

  final DateTime? dueDate;
  final DateTime? completedAt;

  final int? rating;

  final int unreadMessages;

  final Map<String, String> spec;

  final Map<OrderStage, DateTime> stageDates;

  final OwnOrderStatus? ownStatus;

  final int productCount;

  final List<OrderDrawingSpec> drawings;

  bool get isOwn => ownStatus != null;

  bool get isCompleted => completedAt != null;

  bool isLate(DateTime now) {
    final due = dueDate;
    if (due == null || isCompleted) return false;
    return now.isAfter(due);
  }

  int lateDays(DateTime now) {
    final due = dueDate;
    if (due == null || isCompleted) return 0;
    return now.difference(due).inDays;
  }

  int get remainingPayment => (totalPrice - prepaid).clamp(0, totalPrice);

  MasterOrderEntity copyWith({
    OrderStage? stage,
    DateTime? completedAt,
    int? unreadMessages,
    Map<OrderStage, DateTime>? stageDates,
    OwnOrderStatus? ownStatus,
    ClosedOrderReason? closedReason,
    String? assignedMasterName,
    String? cancelledReason,
    bool? readOnlyHistory,
    bool clearCompletedAt = false,
  }) {
    return MasterOrderEntity(
      id: id,
      number: number,
      title: title,
      clientName: clientName,
      clientPhone: clientPhone,
      address: address,
      totalPrice: totalPrice,
      stage: stage ?? this.stage,
      createdAt: createdAt,
      summary: summary,
      prepaid: prepaid,
      dueDate: dueDate,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      rating: rating,
      unreadMessages: unreadMessages ?? this.unreadMessages,
      spec: spec,
      stageDates: stageDates ?? this.stageDates,
      ownStatus: ownStatus ?? this.ownStatus,
      productCount: productCount,
      drawings: drawings,
      proposalItems: proposalItems,
      specialtyCode: specialtyCode,
      specialtyName: specialtyName,
      closedReason: closedReason ?? this.closedReason,
      assignedMasterName: assignedMasterName ?? this.assignedMasterName,
      cancelledReason: cancelledReason ?? this.cancelledReason,
      readOnlyHistory: readOnlyHistory ?? this.readOnlyHistory,
    );
  }

  @override
  List<Object?> get props => [
        id,
        stage,
        clientPhone,
        completedAt,
        unreadMessages,
        ownStatus,
        closedReason,
        readOnlyHistory
      ];
}
