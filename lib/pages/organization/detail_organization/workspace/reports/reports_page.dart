import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
  final String organizationId;
  final String workspaceId;

  const ReportsPage({
    super.key,
    required this.organizationId,
    required this.workspaceId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo'),
      ),
      body: Center(
        child: Text(
          'Báo cáo của workspace $workspaceId',
        ),
      ),
    );
  }
}
