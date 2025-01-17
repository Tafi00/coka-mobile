import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class DetailWorkspacePage extends StatefulWidget {
  final String organizationId;
  final String workspaceId;
  final Widget child;

  const DetailWorkspacePage({
    super.key,
    required this.organizationId,
    required this.workspaceId,
    required this.child,
  });

  @override
  State<DetailWorkspacePage> createState() => _DetailWorkspacePageState();
}

class _DetailWorkspacePageState extends State<DetailWorkspacePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              );
            }
            return const TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w400,
              fontSize: 12,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          animationDuration: const Duration(milliseconds: 500),
          indicatorColor: const Color(0xFFDCDBFF),
          backgroundColor: Colors.white,
          elevation: 4,
          shadowColor: Colors.black,
          surfaceTintColor: Colors.white,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          height: 68,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
            switch (index) {
              case 0:
                context.replace(
                    '/organization/${widget.organizationId}/workspace/${widget.workspaceId}/customers');
                break;
              case 1:
                context.replace(
                    '/organization/${widget.organizationId}/workspace/${widget.workspaceId}/teams');
                break;
              case 2:
                context.replace(
                    '/organization/${widget.organizationId}/workspace/${widget.workspaceId}/reports');
                break;
            }
          },
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.people_outline, color: AppColors.textTertiary),
              selectedIcon: Icon(Icons.people, color: AppColors.primary),
              label: 'Khách hàng',
            ),
            NavigationDestination(
              icon: Icon(Icons.groups_outlined, color: AppColors.textTertiary),
              selectedIcon: Icon(Icons.groups, color: AppColors.primary),
              label: 'Đội sale',
            ),
            NavigationDestination(
              icon:
                  Icon(Icons.analytics_outlined, color: AppColors.textTertiary),
              selectedIcon: Icon(Icons.analytics, color: AppColors.primary),
              label: 'Báo cáo',
            ),
          ],
        ),
      ),
    );
  }
}
