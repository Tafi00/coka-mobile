import 'package:flutter/material.dart';

class MessageDetailPage extends StatelessWidget {
  final String organizationId;
  final String roomId;

  const MessageDetailPage({
    super.key,
    required this.organizationId,
    required this.roomId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Phòng chat $roomId'),
      ),
      body: Center(
        child: Text('Chi tiết tin nhắn của phòng $roomId'),
      ),
    );
  }
}
