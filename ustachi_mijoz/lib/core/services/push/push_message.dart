
class PushMessage {
  const PushMessage({
    required this.topic,
    this.title = '',
    this.body = '',
    this.orderId,
    this.threadId,
  });

  final String topic;

  final String title;
  final String body;

  final int? orderId;
  final int? threadId;

  bool get isChat => topic == 'chat_message';
  bool get isNewOrder => topic == 'order_published';

  static int? _int(Object? value) {
    if (value is int) return value;
    if (value == null) return null;
    return int.tryParse(value.toString());
  }

  factory PushMessage.fromData(
    Map<String, dynamic> data, {
    String title = '',
    String body = '',
  }) =>
      PushMessage(
        topic: (data['topic'] ?? '').toString(),
        title: title,
        body: body,
        orderId: _int(data['order_id']),
        threadId: _int(data['thread_id']),
      );

  @override
  String toString() =>
      'PushMessage($topic, order=$orderId, thread=$threadId)';
}
