import 'package:ustachi/features/marketplace/domain/entities/order_entity.dart';
import 'package:ustachi/features/marketplace/domain/entities/specialty_entity.dart' show specialtyDisplayName;
import 'package:ustachi/core/api/media_url.dart';

DateTime? _date(dynamic v) =>
    v == null ? null : DateTime.tryParse(v.toString())?.toLocal();

int _int(dynamic v) =>
    v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;

double? _double(dynamic v) =>
    v == null ? null : (v is num ? v.toDouble() : double.tryParse(v.toString()));

String _str(dynamic v) => v?.toString() ?? '';

class PersonModel extends PersonEntity {
  const PersonModel({
    required super.id,
    super.fullName,
    super.phoneNumber,
    super.photo,
    super.specialty,
    super.experienceYears,
    super.rating,
    super.reviewsCount,
  });

  factory PersonModel.fromJson(Map<String, dynamic> json) => PersonModel(
        id: _int(json['id']),
        fullName: _str(json['full_name']),
        phoneNumber: _str(json['phone_number']),
        photo: mediaUrl(json['photo']?.toString()),
        specialty: json['specialty']?.toString(),
        experienceYears:
            json['experience_years'] == null ? null : _int(json['experience_years']),
        rating: _double(json['rating']),
        reviewsCount: _int(json['reviews_count']),
      );
}

class StageEventModel extends StageEventEntity {
  const StageEventModel({
    required super.id,
    required super.stage,
    super.note,
    super.createdAt,
  });

  factory StageEventModel.fromJson(Map<String, dynamic> json) => StageEventModel(
        id: _int(json['id']),
        stage: OrderStage.fromCode(json['stage']?.toString()),
        note: _str(json['note']),
        createdAt: _date(json['created_at']),
      );
}

class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    required super.rating,
    super.comment,
    super.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
        id: _int(json['id']),
        rating: _int(json['rating']),
        comment: _str(json['comment']),
        createdAt: _date(json['created_at']),
      );
}

class OrderResponseModel extends OrderResponseEntity {
  const OrderResponseModel({
    required super.id,
    required super.master,
    required super.status,
    super.message,
    super.threadId,
    super.serviceTotal,
    super.createdAt,
  });

  factory OrderResponseModel.fromJson(Map<String, dynamic> json) =>
      OrderResponseModel(
        id: _int(json['id']),
        master: PersonModel.fromJson(
          Map<String, dynamic>.from(json['master'] as Map? ?? const {}),
        ),
        status: ResponseStatus.fromCode(json['status']?.toString()),
        message: _str(json['message']),
        threadId: json['thread_id'] == null ? null : _int(json['thread_id']),
        serviceTotal: json['service_total'] == null
            ? null
            : _int(json['service_total']),
        createdAt: _date(json['created_at']),
      );

  static List<OrderResponseEntity> listFrom(dynamic data) {
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((e) => OrderResponseModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}

class OrderInviteModel extends OrderInviteEntity {
  const OrderInviteModel({
    required super.id,
    required super.master,
    required super.status,
    super.declineReason,
    super.createdAt,
  });

  factory OrderInviteModel.fromJson(Map<String, dynamic> json) =>
      OrderInviteModel(
        id: _int(json['id']),
        master: PersonModel.fromJson(
          Map<String, dynamic>.from(json['master'] as Map? ?? const {}),
        ),
        status: InviteStatus.fromCode(json['status']?.toString()) ??
            InviteStatus.pending,
        declineReason: _str(json['decline_reason']),
        createdAt: _date(json['created_at']),
      );

  static List<OrderInviteEntity> listFrom(dynamic data) {
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((e) => OrderInviteModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.title,
    required super.status,
    super.description,
    super.proposal,
    super.specialtyCode,
    super.specialtyName,
    super.calculatedPrice,
    super.client,
    super.assignedMaster,
    super.stage,
    super.stageStep,
    super.stageTotal,
    super.responsesCount,
    super.stageEvents,
    super.review,
    super.regionName,
    super.districtName,
    super.address,
    super.expiresAt,
    super.completedAt,
    super.cancelledReason,
    super.createdAt,
    super.myResponseStatus,
    super.clientName,
    super.isPublic,
    super.invites,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final events = json['stage_events'];
    return OrderModel(
      id: _int(json['id']),
      title: _str(json['title']),
      description: _str(json['description']),
      proposal: json['proposal'] is Map
          ? Map<String, dynamic>.from(json['proposal'] as Map)
          : const {},
      calculatedPrice: _int(json['calculated_price']),

      specialtyCode: json['specialty_code']?.toString(),
      specialtyName: json['specialty_name'] == null ? null : specialtyDisplayName(json['specialty_name'].toString()),
      client: json['client'] is Map
          ? PersonModel.fromJson(Map<String, dynamic>.from(json['client'] as Map))
          : null,
      assignedMaster: json['assigned_master'] is Map
          ? PersonModel.fromJson(
              Map<String, dynamic>.from(json['assigned_master'] as Map))
          : null,
      status: OrderStatus.fromCode(json['status']?.toString()),
      stage: OrderStage.fromCode(json['stage']?.toString()),
      stageStep: _int(json['stage_step']),
      stageTotal: json['stage_total'] == null
          ? OrderStage.totalSteps
          : _int(json['stage_total']),
      responsesCount: _int(json['responses_count']),
      stageEvents: events is List
          ? events
              .whereType<Map>()
              .map((e) => StageEventModel.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      review: json['review'] is Map
          ? ReviewModel.fromJson(Map<String, dynamic>.from(json['review'] as Map))
          : null,
      regionName: json['region_name']?.toString(),
      districtName: json['district_name']?.toString(),
      address: _str(json['address']),
      expiresAt: _date(json['expires_at']),
      completedAt: _date(json['completed_at']),
      cancelledReason: _str(json['cancelled_reason']),
      createdAt: _date(json['created_at']),
      myResponseStatus:
          ResponseStatus.fromCode(json['my_response_status']?.toString()),
      clientName: _str(json['client_name']),

      isPublic: json['is_public'] == null || json['is_public'] == true,
      invites: OrderInviteModel.listFrom(json['invites']),
    );
  }

  static List<OrderEntity> listFrom(dynamic data) {
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((e) => OrderModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
