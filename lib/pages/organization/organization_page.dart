import 'package:coka/core/theme/text_styles.dart';
import 'package:coka/shared/widgets/avatar_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:coka/api/repositories/auth_repository.dart';
import 'package:coka/api/api_client.dart';
import 'package:coka/shared/widgets/custom_bottom_navigation.dart';
import 'package:coka/api/repositories/organization_repository.dart';
import 'package:coka/shared/widgets/organization_drawer.dart';
import 'package:shimmer/shimmer.dart';

class OrganizationPage extends StatefulWidget {
  final String organizationId;
  final Widget child;

  const OrganizationPage({
    super.key,
    required this.organizationId,
    required this.child,
  });

  @override
  State<OrganizationPage> createState() => _OrganizationPageState();
}

class _OrganizationPageState extends State<OrganizationPage> {
  Map<String, dynamic>? _userInfo;
  Map<String, dynamic>? _organizationInfo;
  List<dynamic> _organizations = [];
  bool _isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void didUpdateWidget(OrganizationPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    print(
        'didUpdateWidget - old: ${oldWidget.organizationId}, new: ${widget.organizationId}');
    if (oldWidget.organizationId != widget.organizationId) {
      print('Organization ID changed - reloading data');
      _loadOrganizations();
    }
  }

  Future<void> _initData() async {
    await Future.wait([
      _loadUserInfo(),
      _loadOrganizations(),
    ]);
  }

  Future<void> _loadOrganizations() async {
    try {
      final organizationRepository = OrganizationRepository(ApiClient());
      final response = await organizationRepository.getOrganizations();
      if (mounted) {
        final organizations = response['content'] ?? [];
        setState(() {
          _organizations = organizations;
        });

        if (widget.organizationId == 'default') {
          // Đọc organization mặc định từ storage
          final defaultOrgId =
              await ApiClient.storage.read(key: 'default_organization_id');
          print('Đọc organization mặc định: $defaultOrgId');

          if (defaultOrgId != null && organizations.isNotEmpty) {
            // Tìm organization mặc định trong danh sách
            final defaultOrg = organizations.firstWhere(
              (org) => org['id'] == defaultOrgId,
              orElse: () => organizations[0],
            );
            print('Tìm thấy organization mặc định: ${defaultOrg['id']}');
            if (mounted) {
              context.go('/organization/${defaultOrg['id']}');
            }
          } else if (organizations.isNotEmpty) {
            // Nếu không có organization mặc định, dùng organization đầu tiên
            print(
                'Không có organization mặc định, dùng organization đầu tiên: ${organizations[0]['id']}');
            if (mounted) {
              context.go('/organization/${organizations[0]['id']}');
            }
          }
        } else {
          // Cập nhật thông tin organization hiện tại và lưu làm mặc định
          final currentOrg = organizations.firstWhere(
            (org) => org['id'] == widget.organizationId,
            orElse: () => null,
          );
          if (currentOrg != null) {
            setState(() {
              _organizationInfo = currentOrg;
            });
            // Lưu organization mặc định
            print('Lưu organization mặc định: ${widget.organizationId}');
            await ApiClient.storage.write(
              key: 'default_organization_id',
              value: widget.organizationId,
            );
            // Kiểm tra lại giá trị đã lưu
            final savedOrgId =
                await ApiClient.storage.read(key: 'default_organization_id');
            print('Kiểm tra lại organization mặc định đã lưu: $savedOrgId');
          }
        }
      }
    } catch (e) {
      print('Lỗi khi load organizations: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể tải danh sách tổ chức')),
        );
      }
    }
  }

  Future<void> _loadUserInfo() async {
    try {
      final authRepository = AuthRepository(ApiClient());
      final response = await authRepository.getUserInfo();
      if (mounted) {
        setState(() {
          _userInfo = response['content'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể tải thông tin người dùng')),
        );
      }
    }
  }

  String _getRoleText(String? role) {
    switch (role) {
      case 'ADMIN':
        return 'Quản trị viên';
      case 'OWNER':
        return 'Chủ tổ chức';
      default:
        return 'Thành viên';
    }
  }

  Widget _buildSkeletonTitle() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 130,
            height: 14,
            color: Colors.white,
          ),
          const SizedBox(height: 2),
          Container(
            width: 80,
            height: 12,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
      child: GestureDetector(
        onTap: () {
          _scaffoldKey.currentState?.openDrawer();
        },
        child: AvatarWidget(
          width: 48,
          height: 48,
          borderRadius: 16,
          fallbackText: _userInfo?['fullName'],
          imgData: _userInfo?['avatar'],
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.contains('/messages')) {
      return const Text('Tin nhắn');
    }
    if (location.contains('/campaigns')) {
      return const Text('Chiến dịch');
    }

    if (_isLoading) {
      return _buildSkeletonTitle();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _userInfo?['fullName'] ?? '',
          style: TextStyles.heading3,
        ),
        Text(
          _getRoleText(_organizationInfo?['type']),
          style: TextStyles.subtitle2,
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    return OrganizationDrawer(
      userInfo: _userInfo,
      currentOrganizationId: widget.organizationId,
      organizations: _organizations,
      onLogout: () => _handleLogout(context),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.contains('/messages')) {
      return 1;
    }
    if (location.contains('/campaigns')) {
      return 2;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.replace('/organization/${widget.organizationId}');
        break;
      case 1:
        context.replace('/organization/${widget.organizationId}/messages');
        break;
      case 2:
        context.replace('/organization/${widget.organizationId}/campaigns');
        break;
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final authRepository = AuthRepository(ApiClient());
    await authRepository.logout();
    if (context.mounted) {
      context.replace('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      appBar: AppBar(
        leading: _buildAvatar(),
        title: _buildTitle(context),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
            style: const ButtonStyle(
              tapTargetSize:
                  MaterialTapTargetSize.shrinkWrap, // the '2023' part
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implement notifications
            },
            style: const ButtonStyle(
              tapTargetSize:
                  MaterialTapTargetSize.shrinkWrap, // the '2023' part
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: widget.child,
      bottomNavigationBar: CustomBottomNavigation(
        selectedIndex: _calculateSelectedIndex(context),
        onTapped: (index) => _onItemTapped(index, context),
        showCampaignBadge: false,
        showSettingsBadge: false,
      ),
    );
  }
}
