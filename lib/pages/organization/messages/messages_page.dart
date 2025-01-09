import 'package:flutter/material.dart';

class MessagesPage extends StatelessWidget {
  final String organizationId;

  const MessagesPage({
    super.key,
    required this.organizationId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tin nhắn'),
      ),
      body: Center(
        child: Text('Danh sách tin nhắn của tổ chức $organizationId'),
      ),
    );
  }
}
