import 'package:flutter/material.dart';

class OrganizationPage extends StatelessWidget {
  final String organizationId;

  const OrganizationPage({
    super.key,
    required this.organizationId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tổ chức $organizationId'),
      ),
      body: Center(
        child: Text('Trang tổ chức'),
      ),
    );
  }
}
