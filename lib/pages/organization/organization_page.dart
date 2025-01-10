import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:coka/api/repositories/auth_repository.dart';
import 'package:coka/api/api_client.dart';

class OrganizationPage extends StatelessWidget {
  final String organizationId;

  const OrganizationPage({
    super.key,
    required this.organizationId,
  });

  Future<void> _handleLogout(BuildContext context) async {
    final authRepository = AuthRepository(ApiClient());

    // Xóa token và chuyển về trang login
    await authRepository.logout();

    if (context.mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tổ chức $organizationId'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: Center(
        child: Text('Trang tổ chức'),
      ),
    );
  }
}
