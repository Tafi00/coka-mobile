import 'package:flutter/material.dart';

class AIChatbotPage extends StatelessWidget {
  final String organizationId;

  const AIChatbotPage({
    super.key,
    required this.organizationId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI ChatBot'),
      ),
      body: Center(
        child: Text(
          'Chiến dịch AI ChatBot của tổ chức $organizationId',
        ),
      ),
    );
  }
}
