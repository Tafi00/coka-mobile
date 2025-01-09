import 'package:flutter/material.dart';

class FillDataPage extends StatelessWidget {
  final String organizationId;

  const FillDataPage({
    super.key,
    required this.organizationId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Làm đầy dữ liệu'),
      ),
      body: Center(
        child: Text(
          'Chiến dịch làm đầy dữ liệu của tổ chức $organizationId',
        ),
      ),
    );
  }
}
