import 'package:flutter/material.dart';

class CampaignsPage extends StatelessWidget {
  final String organizationId;

  const CampaignsPage({
    super.key,
    required this.organizationId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chiến dịch'),
      ),
      body: Center(
        child: Text('Danh sách chiến dịch của tổ chức $organizationId'),
      ),
    );
  }
}
