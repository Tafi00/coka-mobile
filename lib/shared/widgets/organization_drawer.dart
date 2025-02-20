import 'package:coka/shared/widgets/avatar_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:coka/core/theme/text_styles.dart';
import 'package:coka/core/theme/app_colors.dart';

class OrganizationDrawer extends StatelessWidget {
  final Map<String, dynamic>? userInfo;
  final String currentOrganizationId;
  final List<dynamic> organizations;
  final VoidCallback onLogout;

  const OrganizationDrawer({
    super.key,
    required this.userInfo,
    required this.currentOrganizationId,
    required this.organizations,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.24,
            decoration: const BoxDecoration(
              color: AppColors.backgroundTertiary,
            ),
            padding: const EdgeInsets.only(top: 8),
            child: ListView.builder(
              itemCount: organizations.length + 1,
              itemBuilder: (context, index) {
                if (index == organizations.length) {
                  return Container(
                    padding: const EdgeInsets.all(8),
                    alignment: Alignment.center,
                    child: InkWell(
                      onTap: () {
                        context.push('/organization/create');
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                    ),
                  );
                }
                final org = organizations[index];
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    if (org['id'] == currentOrganizationId)
                      Positioned(
                        left: 0,
                        top: 8,
                        child: Container(
                          width: 3,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.horizontal(
                                right: Radius.circular(24.0)),
                          ),
                        ),
                      ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              context.go('/organization/${org['id']}');
                              Navigator.pop(context);
                            },
                            child: AvatarWidget(
                              width: 40,
                              height: 40,
                              borderRadius: 8,
                              fallbackText: org['name'],
                              imgUrl: org['avatar'],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            org['name'] ?? '',
                            style: const TextStyle(fontSize: 10),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 32, bottom: 12),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AvatarWidget(
                        width: 48,
                        height: 48,
                        borderRadius: 26,
                        fallbackText: userInfo?['fullName'],
                        imgUrl: userInfo?['avatar'],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        userInfo?['fullName'] ?? '',
                        style: TextStyles.heading3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () {
                          // TODO: Navigate to profile
                        },
                        child: const Text(
                          'Xem Profile của bạn',
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            decorationColor: AppColors.textTertiary,
                            decoration: TextDecoration.underline,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.group_add_outlined,
                              color: AppColors.primary),
                          title: const Text('Tham gia tổ chức'),
                          dense: true,
                          visualDensity: const VisualDensity(vertical: -1.0),
                          onTap: () {
                            // TODO: Navigate to join organization
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.person_add_outlined,
                              color: AppColors.primary),
                          title: const Text('Lời mời'),
                          dense: true,
                          visualDensity: const VisualDensity(vertical: -1.0),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '24',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          onTap: () {
                            // TODO: Navigate to invitations
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.workspace_premium_outlined,
                              color: AppColors.primary),
                          title: const Text('Nâng cấp tài khoản'),
                          dense: true,
                          visualDensity: const VisualDensity(vertical: -1.0),
                          onTap: () {
                            // TODO: Navigate to upgrade account
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.help_outline,
                              color: AppColors.primary),
                          title: const Text('Trợ giúp - Hỗ trợ'),
                          dense: true,
                          visualDensity: const VisualDensity(vertical: -1.0),
                          onTap: () {
                            // TODO: Navigate to help
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.settings_outlined,
                              color: AppColors.primary),
                          title: const Text('Cài đặt'),
                          dense: true,
                          visualDensity: const VisualDensity(vertical: -1.0),
                          onTap: () {
                            // TODO: Navigate to settings
                          },
                        ),
                        const Spacer(),
                        const Divider(
                          thickness: 0,
                          height: 1,
                        ),
                        ListTile(
                          leading: const Icon(Icons.logout,
                              color: AppColors.primary),
                          title: const Text('Đăng xuất'),
                          dense: true,
                          visualDensity: const VisualDensity(vertical: -1.0),
                          onTap: onLogout,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
