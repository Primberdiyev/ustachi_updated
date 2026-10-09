import 'package:equatable/equatable.dart';

enum OrderStatus {
  published('published'),
  assigned('assigned'),
  completed('completed'),
  cancelled('cancelled'),
  expired('expired');

  const OrderStatus(this.code);
  final String code;

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
  accepted('accepted'),
  measured('measured'),
  production('production'),
  installation('installation'),
  handover('handover');

  const OrderStage(this.code);
  final String code;

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
  interested('interested'),
  withdrawn('withdrawn'),
  chosen('chosen'),
  rejected('rejected');

  const ResponseStatus(this.code);
  final String code;

  static ResponseStatus? fromCode(String? code) {
    if (code == null) return null;
    for (final s in ResponseStatus.values) {
      if (s.code == code) return s;
    }
    return null;
  }
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
    this.createdAt,
  });

  final int id;
  final PersonEntity master;
  final ResponseStatus? status;
  final String message;

  final int? threadId;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [id, status, threadId];
}

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
    this.isInvited = false,
    this.inviteStatus,
    this.isRepair = false,
    this.viewerIsAssigned = false,
  });

  final int id;
  final String title;
  final String description;

  final Map<String, dynamic> proposal;

  final int calculatedPrice;

  final String? specialtyCode;
  final String? specialtyName;

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

  final bool isInvited;

  final String? inviteStatus;

  final bool isRepair;
  final bool viewerIsAssigned;

  bool get hasReview => review != null;

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
  List<Object?> get props => [
        id,
        status,
        stage,
        responsesCount,
        myResponseStatus,
        isInvited,
        viewerIsAssigned,
      ];
}
