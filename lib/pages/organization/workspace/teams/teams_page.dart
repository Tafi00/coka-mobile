import 'package:flutter/material.dart';

class TeamsPage extends StatelessWidget {
  final String organizationId;
  final String workspaceId;

  const TeamsPage({
    super.key,
    required this.organizationId,
    required this.workspaceId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đội sale'),
      ),
      body: Center(
        child: Text(
          'Danh sách đội sale của workspace $workspaceId',
        ),
      ),
    );
  }
}
