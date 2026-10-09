import 'package:equatable/equatable.dart';
import 'package:ustachi/features/marketplace/domain/entities/order_entity.dart';

class ChatThreadEntity extends Equatable {
  const ChatThreadEntity({
    required this.id,
    required this.orderId,
    required this.peer,
    this.orderTitle = '',
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.createdAt,
  });

  final int id;
  final int orderId;
  final String orderTitle;

  final PersonEntity peer;

  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final DateTime? createdAt;

  bool get hasUnread => unreadCount > 0;

  @override
  List<Object?> get props => [id, lastMessageAt, unreadCount];
}

class ChatMessageEntity extends Equatable {
  const ChatMessageEntity({
    required this.id,
    required this.text,
    required this.isMine,
    this.senderId,
    this.senderName = '',
    this.isRead = false,
    this.createdAt,
  });

  final int id;
  final String text;

  final bool isMine;
  final int? senderId;
  final String senderName;
  final bool isRead;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [id, text, isMine, isRead];
}
