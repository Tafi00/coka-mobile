import 'package:flutter/material.dart';

class MulticonnectPage extends StatelessWidget {
  final String organizationId;

  const MulticonnectPage({
    super.key,
    required this.organizationId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết nối đa nguồn'),
      ),
      body: Center(
        child: Text('Chiến dịch kết nối đa nguồn của tổ chức $organizationId'),
      ),
    );
  }
}
