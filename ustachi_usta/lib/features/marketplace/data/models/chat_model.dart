import 'package:ustachi/core/api/api_list.dart';
import 'package:ustachi/features/marketplace/data/models/order_model.dart';
import 'package:ustachi/features/marketplace/domain/entities/chat_entity.dart';
import 'package:ustachi/features/marketplace/domain/entities/notification_entity.dart';
import 'package:ustachi/features/marketplace/domain/entities/order_entity.dart';

DateTime? _date(dynamic v) =>
    v == null ? null : DateTime.tryParse(v.toString())?.toLocal();

int _int(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;

String _str(dynamic v) => v?.toString() ?? '';

class ChatThreadModel extends ChatThreadEntity {
  const ChatThreadModel({
    required super.id,
    required super.orderId,
    required super.peer,
    super.orderTitle,
    super.lastMessage,
    super.lastMessageAt,
    super.unreadCount,
    super.createdAt,
  });

  factory ChatThreadModel.fromJson(Map<String, dynamic> json) {
    final last = json['last_message'];
    return ChatThreadModel(
      id: _int(json['id']),
      orderId: _int(json['order']),
      orderTitle: _str(json['order_title']),
      peer: json['peer'] is Map
          ? PersonModel.fromJson(Map<String, dynamic>.from(json['peer'] as Map))
          : const PersonEntity(id: 0),
      lastMessage: last is Map ? _str(last['text']) : null,
      lastMessageAt: _date(json['last_message_at']),
      unreadCount: _int(json['unread_count']),
      createdAt: _date(json['created_at']),
    );
  }

  static List<ChatThreadEntity> listFrom(dynamic data) {
    return apiList(data)
        .whereType<Map>()
        .map((e) => ChatThreadModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}

class ChatMessageModel extends ChatMessageEntity {
  const ChatMessageModel({
    required super.id,
    required super.text,
    required super.isMine,
    super.senderId,
    super.senderName,
    super.isRead,
    super.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      ChatMessageModel(
        id: _int(json['id']),
        text: _str(json['text']),
        isMine: json['is_mine'] == true,
        senderId: json['sender'] == null ? null : _int(json['sender']),
        senderName: _str(json['sender_name']),
        isRead: json['is_read'] == true,
        createdAt: _date(json['created_at']),
      );

  static List<ChatMessageEntity> listFrom(dynamic data) {
    return apiList(data)
        .whereType<Map>()
        .map((e) => ChatMessageModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}

class AppNotificationModel extends AppNotificationEntity {
  const AppNotificationModel({
    required super.id,
    required super.type,
    required super.title,
    super.body,
    super.orderId,
    super.isRead,
    super.createdAt,
  });

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) =>
      AppNotificationModel(
        id: _int(json['id']),
        type: AppNotificationType.fromCode(json['type']?.toString()),
        title: _str(json['title']),
        body: _str(json['body']),
        orderId: json['order'] == null ? null : _int(json['order']),
        isRead: json['is_read'] == true,
        createdAt: _date(json['created_at']),
      );

  static NotificationPage pageFrom(dynamic data) {
    if (data is! Map) return const NotificationPage();
    final results = data['results'];
    return NotificationPage(
      unreadCount: _int(data['unread_count']),
      items: results is List
          ? results
              .whereType<Map>()
              .map((e) =>
                  AppNotificationModel.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
    );
  }
}
