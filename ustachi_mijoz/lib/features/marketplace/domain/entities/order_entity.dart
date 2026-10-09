import 'package:equatable/equatable.dart';

enum OrderStatus {
  published('published', 'E\'lon qilingan'),
  assigned('assigned', 'Usta tanlangan'),
  completed('completed', 'Yakunlangan'),
  cancelled('cancelled', 'Bekor qilingan'),
  expired('expired', 'Muddati o\'tgan');

  const OrderStatus(this.code, this.label);
  final String code;
  final String label;

  static OrderStatus fromCode(String? code) => OrderStatus.values.firstWhere(
        (e) => e.code == code,
        orElse: () => OrderStatus.published,
      );

  bool get isOpen => this == OrderStatus.published;
  bool get isActive => this == OrderStatus.assigned;
  bool get isFinished =>
      this == OrderStatus.completed ||
      this == OrderStatus.cancelled ||
      this == OrderStatus.expired;
}

enum OrderStage {
  accepted('accepted', 'Qabul qilindi'),
  measured('measured', 'O\'lchov olindi'),
  production('production', 'Ishlab chiqarish'),
  installation('installation', 'O\'rnatish'),
  handover('handover', 'Topshirildi');

  const OrderStage(this.code, this.label);
  final String code;
  final String label;

  static const List<OrderStage> romStages = [accepted, measured];

  static const List<OrderStage> otherStages = [accepted];

  static List<OrderStage> stagesFor({required bool isRom}) =>
      isRom ? romStages : otherStages;

  bool get isLegacy => !romStages.contains(this);

  static const int totalSteps = 2;

  static OrderStage? fromCode(String? code) {
    if (code == null) return null;
    for (final s in OrderStage.values) {
      if (s.code == code) return s;
    }
    return null;
  }

  int get step => index + 1;

  bool get isLast => this == OrderStage.handover;

  OrderStage? get next => isLast ? null : OrderStage.values[index + 1];
}

enum ResponseStatus {
  interested('interested', 'Qabul qilaman'),
  withdrawn('withdrawn', 'Voz kechdi'),
  chosen('chosen', 'Tanlandi'),
  rejected('rejected', 'Tanlanmadi');

  const ResponseStatus(this.code, this.label);
  final String code;
  final String label;

  static ResponseStatus? fromCode(String? code) {
    if (code == null) return null;
    for (final s in ResponseStatus.values) {
      if (s.code == code) return s;
    }
    return null;
  }
}

enum InviteStatus {
  pending('pending', 'Javob kutilmoqda'),
  accepted('accepted', 'Qabul qildi'),
  declined('declined', 'Rad etdi');

  const InviteStatus(this.code, this.label);
  final String code;
  final String label;

  static InviteStatus? fromCode(String? code) {
    if (code == null) return null;
    for (final s in InviteStatus.values) {
      if (s.code == code) return s;
    }
    return null;
  }

  bool get isWaiting => this == InviteStatus.pending;
}

class PersonEntity extends Equatable {
  const PersonEntity({
    required this.id,
    this.fullName = '',
    this.phoneNumber = '',
    this.photo,
    this.specialty,
    this.experienceYears,
    this.rating,
    this.reviewsCount = 0,
  });

  final int id;
  final String fullName;
  final String phoneNumber;
  final String? photo;

  final String? specialty;
  final int? experienceYears;
  final double? rating;
  final int reviewsCount;

  String get displayName => fullName.isNotEmpty ? fullName : phoneNumber;

  @override
  List<Object?> get props => [id, fullName, rating, reviewsCount];
}

class StageEventEntity extends Equatable {
  const StageEventEntity({
    required this.id,
    required this.stage,
    this.note = '',
    this.createdAt,
  });

  final int id;
  final OrderStage? stage;
  final String note;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [id, stage, createdAt];
}

class ReviewEntity extends Equatable {
  const ReviewEntity({
    required this.id,
    required this.rating,
    this.comment = '',
    this.createdAt,
  });

  final int id;
  final int rating;
  final String comment;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [id, rating];
}

class OrderResponseEntity extends Equatable {
  const OrderResponseEntity({
    required this.id,
    required this.master,
    required this.status,
    this.message = '',
    this.threadId,
    this.serviceTotal,
    this.createdAt,
  });

  final int id;
  final PersonEntity master;
  final ResponseStatus? status;
  final String message;

  final int? threadId;

  final int? serviceTotal;

  final DateTime? createdAt;

  @override
  List<Object?> get props => [id, status, threadId, serviceTotal];
}

class OrderInviteEntity extends Equatable {
  const OrderInviteEntity({
    required this.id,
    required this.master,
    required this.status,
    this.declineReason = '',
    this.createdAt,
  });

  final int id;
  final PersonEntity master;
  final InviteStatus status;
  final String declineReason;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [id, status, master.id];
}

bool inviteHonored(OrderEntity order, List<int> masterIds) =>
    masterIds.isEmpty || (order.isDirect && order.invites.isNotEmpty);

class OrderEntity extends Equatable {
  const OrderEntity({
    required this.id,
    required this.title,
    required this.status,
    this.description = '',
    this.proposal = const {},
    this.calculatedPrice = 0,
    this.specialtyCode,
    this.specialtyName,
    this.client,
    this.assignedMaster,
    this.stage,
    this.stageStep = 0,
    this.stageTotal = OrderStage.totalSteps,
    this.responsesCount = 0,
    this.stageEvents = const [],
    this.review,
    this.regionName,
    this.districtName,
    this.address = '',
    this.expiresAt,
    this.completedAt,
    this.cancelledReason = '',
    this.createdAt,
    this.myResponseStatus,
    this.clientName = '',
    this.isPublic = true,
    this.invites = const [],
  });

  final int id;
  final String title;
  final String description;

  final Map<String, dynamic> proposal;

  final int calculatedPrice;

  final String? specialtyCode;
  final String? specialtyName;

  bool get hasPrice => calculatedPrice > 0;

  final PersonEntity? client;
  final PersonEntity? assignedMaster;
  final OrderStatus status;
  final OrderStage? stage;
  final int stageStep;
  final int stageTotal;
  final int responsesCount;
  final List<StageEventEntity> stageEvents;
  final ReviewEntity? review;

  final String? regionName;
  final String? districtName;
  final String address;

  final DateTime? expiresAt;
  final DateTime? completedAt;
  final String cancelledReason;
  final DateTime? createdAt;

  final ResponseStatus? myResponseStatus;

  final String clientName;

  final bool isPublic;

  final List<OrderInviteEntity> invites;

  bool get hasReview => review != null;

  bool get isDirect => !isPublic;

  List<OrderInviteEntity> get pendingInvites =>
      invites.where((i) => i.status.isWaiting).toList();

  List<OrderInviteEntity> get declinedInvites =>
      invites.where((i) => i.status == InviteStatus.declined).toList();

  Duration timeLeft(DateTime now) {
    final at = expiresAt;
    if (at == null) return Duration.zero;
    final left = at.difference(now);
    return left.isNegative ? Duration.zero : left;
  }

  bool get isRom =>
      specialtyCode == null ||
      specialtyCode == 'rom' ||
      specialtyCode == 'window';

  List<OrderStage> get activeStages => OrderStage.stagesFor(isRom: isRom);

  int get effectiveStageTotal => activeStages.length;

  int get effectiveStageStep {
    final st = stage;
    if (st == null) return 1;
    final idx = activeStages.indexOf(st);

    return idx != -1 ? idx + 1 : activeStages.length;
  }

  @override
  List<Object?> get props =>
      [id, status, stage, responsesCount, myResponseStatus, isPublic, invites];
}
