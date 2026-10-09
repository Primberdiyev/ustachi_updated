import 'package:ustachi/features/marketplace/data/models/master_page_model.dart';
import 'package:ustachi/features/marketplace/domain/entities/master_page.dart';
import 'package:ustachi/features/marketplace/domain/entities/specialty_entity.dart';
import 'package:dio/dio.dart';
import 'package:ustachi/core/api/api_urls.dart';
import 'package:ustachi/features/marketplace/domain/entities/master_card_entity.dart';
import 'package:ustachi/features/marketplace/data/models/master_card_model.dart';
import 'package:ustachi/features/marketplace/data/models/chat_model.dart';
import 'package:ustachi/features/marketplace/data/models/master_profile_model.dart';
import 'package:ustachi/features/marketplace/data/models/order_model.dart';
import 'package:ustachi/features/marketplace/domain/entities/chat_entity.dart';
import 'package:ustachi/features/marketplace/domain/entities/master_profile_entity.dart';
import 'package:ustachi/features/marketplace/domain/entities/notification_entity.dart';
import 'package:ustachi/features/marketplace/domain/entities/order_entity.dart';

abstract class MarketplaceRemoteDataSource {

  Future<List<OrderEntity>> list({String? status, String? scope});
  Future<List<OrderEntity>> feed();
  Future<OrderEntity> detail(int id);
  Future<OrderEntity> create(Map<String, dynamic> body);
  Future<OrderEntity> cancel(int id, {String reason});

  Future<List<OrderResponseEntity>> responses(int orderId);
  Future<OrderEntity> choose(int orderId, int responseId);
  Future<ReviewEntity> review(int orderId,
      {required int rating, String comment});

  Future<OrderEntity> invite(int orderId, List<int> masterIds);

  Future<OrderEntity> publishToEveryone(int orderId);

  Future<OrderResponseEntity> respond(int orderId, {String message});
  Future<OrderResponseEntity> withdraw(int orderId);
  Future<OrderEntity> advance(int orderId, {String note});

  Future<OrderEntity> decline(int orderId, {String reason});

  Future<List<ChatThreadEntity>> threads({int? orderId});

  Future<List<ChatMessageEntity>> messages(
    int threadId, {
    int? limit,
    int? before,
    int? after,
  });
  Future<ChatMessageEntity> sendMessage(int threadId, String text);

  Future<List<MasterCardEntity>> masters({
    String? search,
    int? regionId,
    int? specialtyId,
    bool repairsOnly,
    int? districtId,
  });

  Future<MasterPage> mastersPage(
      {int page = 1, int? regionId, int? specialtyId});

  Future<MasterProfileEntity> masterProfile(int masterId);

  Future<List<SpecialtyEntity>> specialties();

  Future<NotificationPage> notifications({bool unreadOnly = false});
  Future<void> markRead(int id);
  Future<void> markAllRead();
}

class MarketplaceRemoteDataSourceImpl implements MarketplaceRemoteDataSource {
  MarketplaceRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<OrderEntity>> list({String? status, String? scope}) async {
    final response = await _dio.get(
      ApiUrls.orders,
      queryParameters: {
        if (status != null) 'status': status,
        if (scope != null) 'scope': scope,
      },
    );
    return OrderModel.listFrom(response.data);
  }

  @override
  Future<List<OrderEntity>> feed() async {
    final response = await _dio.get(ApiUrls.ordersFeed);
    return OrderModel.listFrom(response.data);
  }

  @override
  Future<OrderEntity> detail(int id) async {
    final response = await _dio.get(ApiUrls.orderDetail(id));
    return OrderModel.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  @override
  Future<OrderEntity> create(Map<String, dynamic> body) async {
    final response = await _dio.post(ApiUrls.orders, data: body);
    return OrderModel.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  @override
  Future<OrderEntity> cancel(int id, {String reason = ''}) async {
    final response =
        await _dio.post(ApiUrls.orderCancel(id), data: {'reason': reason});
    return OrderModel.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  @override
  Future<List<OrderResponseEntity>> responses(int orderId) async {
    final response = await _dio.get(ApiUrls.orderResponses(orderId));
    return OrderResponseModel.listFrom(response.data);
  }

  @override
  Future<OrderEntity> choose(int orderId, int responseId) async {
    final response = await _dio.post(ApiUrls.orderChoose(orderId, responseId));
    return OrderModel.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  @override
  Future<ReviewEntity> review(
    int orderId, {
    required int rating,
    String comment = '',
  }) async {
    final response = await _dio.post(
      ApiUrls.orderReview(orderId),
      data: {'rating': rating, 'comment': comment},
    );
    return ReviewModel.fromJson(
        Map<String, dynamic>.from(response.data as Map));
  }

  @override
  Future<OrderEntity> invite(int orderId, List<int> masterIds) async {
    final response = await _dio.post(
      ApiUrls.orderInvite(orderId),
      data: {'master_ids': masterIds},
    );
    return OrderModel.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  @override
  Future<OrderEntity> publishToEveryone(int orderId) async {
    final response = await _dio.post(ApiUrls.orderPublish(orderId));
    return OrderModel.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  @override
  Future<OrderEntity> decline(int orderId, {String reason = ''}) async {
    final response = await _dio.post(
      ApiUrls.orderDecline(orderId),
      data: {'reason': reason},
    );
    return OrderModel.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  @override
  Future<OrderResponseEntity> respond(int orderId,
      {String message = ''}) async {
    final response = await _dio.post(
      ApiUrls.orderRespond(orderId),
      data: {'message': message},
    );
    return OrderResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map));
  }

  @override
  Future<OrderResponseEntity> withdraw(int orderId) async {
    final response = await _dio.post(ApiUrls.orderWithdraw(orderId));
    return OrderResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map));
  }

  @override
  Future<OrderEntity> advance(int orderId, {String note = ''}) async {
    final response =
        await _dio.post(ApiUrls.orderAdvance(orderId), data: {'note': note});
    return OrderModel.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  @override
  Future<List<ChatThreadEntity>> threads({int? orderId}) async {
    final response = await _dio.get(
      ApiUrls.chatThreads,
      queryParameters: orderId == null ? null : {'order': orderId},
    );
    return ChatThreadModel.listFrom(response.data);
  }

  @override
  Future<List<ChatMessageEntity>> messages(
    int threadId, {
    int? limit,
    int? before,
    int? after,
  }) async {
    final response = await _dio.get(
      ApiUrls.chatMessages(threadId),
      queryParameters: {
        if (limit != null) 'limit': limit,
        if (before != null) 'before': before,
        if (after != null) 'after': after,
      },
    );
    return ChatMessageModel.listFrom(response.data);
  }

  @override
  Future<ChatMessageEntity> sendMessage(int threadId, String text) async {
    final response = await _dio.post(
      ApiUrls.chatMessages(threadId),
      data: {'text': text},
    );
    return ChatMessageModel.fromJson(
        Map<String, dynamic>.from(response.data as Map));
  }

  @override
  Future<List<MasterCardEntity>> masters({
    String? search,
    int? regionId,
    int? specialtyId,
    bool repairsOnly = false,
    int? districtId,
  }) async {
    final response = await _dio.get(
      ApiUrls.mastersList,
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (regionId != null) 'region': regionId,
        if (specialtyId != null) 'specialty': specialtyId,

        if (repairsOnly) 'repairs': 1,
        if (districtId != null) 'district': districtId,
      },
    );
    return MasterCardModel.listFrom(response.data);
  }

  @override
  Future<MasterPage> mastersPage(
      {int page = 1, int? regionId, int? specialtyId}) async {
    final response = await _dio.get(ApiUrls.mastersList, queryParameters: {
      'page': page,
      'page_size': 20,
      if (regionId != null) 'region': regionId,
      if (specialtyId != null) 'specialty': specialtyId,
    });
    return MasterPageModel.fromJson(response.data);
  }

  @override
  Future<List<SpecialtyEntity>> specialties() async {
    final response = await _dio.get(ApiUrls.specialties);
    return SpecialtyEntity.listFrom(response.data);
  }

  @override
  Future<MasterProfileEntity> masterProfile(int masterId) async {
    final response = await _dio.get(ApiUrls.masterPublicProfile(masterId));
    return MasterProfileModel.fromJson(
        Map<String, dynamic>.from(response.data as Map));
  }

  @override
  Future<NotificationPage> notifications({bool unreadOnly = false}) async {
    final response = await _dio.get(
      ApiUrls.notifications,
      queryParameters: unreadOnly ? {'unread': 'true'} : null,
    );
    return AppNotificationModel.pageFrom(response.data);
  }

  @override
  Future<void> markRead(int id) => _dio.post(ApiUrls.notificationRead(id));

  @override
  Future<void> markAllRead() => _dio.post(ApiUrls.notificationsReadAll);
}
