import 'package:flutter/material.dart';

class CustomerDetailPage extends StatelessWidget {
  final String organizationId;
  final String workspaceId;
  final String customerId;

  const CustomerDetailPage({
    super.key,
    required this.organizationId,
    required this.workspaceId,
    required this.customerId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Khách hàng $customerId'),
      ),
      body: Center(
        child: Text(
          'Chi tiết khách hàng $customerId của workspace $workspaceId',
        ),
      ),
    );
  }
}
