import 'package:flutter/material.dart';

class CustomersPage extends StatelessWidget {
  final String organizationId;
  final String workspaceId;

  const CustomersPage({
    super.key,
    required this.organizationId,
    required this.workspaceId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Khách hàng'),
      ),
      body: Center(
        child: Text(
          'Danh sách khách hàng của workspace $workspaceId',
        ),
      ),
    );
  }
}
