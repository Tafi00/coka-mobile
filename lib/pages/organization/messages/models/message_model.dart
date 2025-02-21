import 'dart:convert';

class Message {
  final String id;
  final String conversationId;
  final String messageId;
  final String from;
  final String fromName;
  final String to;
  final String toName;
  final String message;
  final int timestamp;
  final bool isGpt;
  final String type;
  final String fullName;
  final int status;
  final List<Attachment>? attachments;

  Message({
    required this.id,
    required this.conversationId,
    required this.messageId,
    required this.from,
    required this.fromName,
    required this.to,
    required this.toName,
    required this.message,
    required this.timestamp,
    required this.isGpt,
    required this.type,
    required this.fullName,
    required this.status,
    this.attachments,
  });

  bool get isFromMe =>
      from !=
      '124662217400086'; // Tin nhắn từ khách hàng khi from khác ID của page

  String get content => message;

  String get senderName => fromName;

  String? get senderAvatar => null; // TODO: Add avatar from API if available

  factory Message.fromJson(Map<String, dynamic> json) {
    List<Attachment>? attachments;
    if (json['attachments'] != null) {
      try {
        final List<dynamic> attachmentsList = json['attachments'] is String
            ? jsonDecode(json['attachments'])
            : json['attachments'];
        attachments =
            attachmentsList.map((e) => Attachment.fromJson(e)).toList();
      } catch (e) {
        print('Error parsing attachments: $e');
      }
    }

    return Message(
      id: json['id'] ?? '',
      conversationId: json['conversationId'] ?? '',
      messageId: json['messageId'] ?? '',
      from: json['from'] ?? '',
      fromName: json['fromName'] ?? '',
      to: json['to'] ?? '',
      toName: json['toName'] ?? '',
      message: json['message'] ?? '',
      timestamp: json['timestamp'] is int
          ? json['timestamp']
          : int.tryParse(json['timestamp']?.toString() ?? '0') ?? 0,
      isGpt: json['isGpt'] ?? false,
      type: json['type'] ?? 'MESSAGE',
      fullName: json['fullName'] ?? '',
      status: json['status'] ?? 0,
      attachments: attachments,
    );
  }
}

class Attachment {
  final String type;
  final String url;
  final String? name;
  final Map<String, dynamic>? payload;

  Attachment({
    required this.type,
    required this.url,
    this.name,
    this.payload,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    final payload = json['payload'] as Map<String, dynamic>?;
    final url = payload?['url']?.toString() ?? json['url']?.toString() ?? '';

    return Attachment(
      type: json['type']?.toString() ?? '',
      url: url,
      name: json['name']?.toString(),
      payload: payload,
    );
  }
}
