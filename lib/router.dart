import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'pages/auth/login_page.dart';
import 'pages/auth/complete_profile_page.dart';
import 'pages/organization/organization_page.dart';
import 'pages/organization/detail_organization/detail_organization_page.dart';
import 'pages/organization/messages/messages_page.dart';
import 'pages/organization/messages/message_detail_page.dart';
import 'pages/organization/messages/message_settings_page.dart';
import 'pages/organization/campaigns/campaigns_page.dart';
import 'pages/organization/campaigns/multiconnect_page.dart';
import 'pages/organization/campaigns/aichatbot_page.dart';
import 'pages/organization/campaigns/filldata_page.dart';
import 'pages/organization/detail_organization/workspace/detail_workspace_page.dart';
import 'pages/organization/detail_organization/workspace/customers/customers_page.dart';
import 'pages/organization/detail_organization/workspace/teams/teams_page.dart';
import 'pages/organization/detail_organization/workspace/teams/team_detail_page.dart';
import 'pages/organization/detail_organization/workspace/reports/reports_page.dart';
import 'pages/organization/detail_organization/workspace/customers/customer_detail/customer_detail_page.dart';
import 'pages/organization/detail_organization/workspace/customers/customer_detail/pages/customer_basic_info_page.dart';
import 'pages/organization/detail_organization/workspace/customers/edit_customer_page.dart';
import 'pages/organization/detail_organization/workspace/customers/add_customer_page.dart';
import 'pages/organization/settings/settings_page.dart';

final appRoutes = [
  // Auth routes
  GoRoute(
    path: '/',
    builder: (context, state) => const LoginPage(),
  ),
  GoRoute(
    path: '/complete-profile',
    builder: (context, state) => const CompleteProfilePage(),
  ),

  // Organization routes with shell
  ShellRoute(
    builder: (context, state, child) {
      final organizationId = state.pathParameters['organizationId'];
      if (organizationId == null) return const SizedBox();
      return OrganizationPage(
        organizationId: organizationId,
        child: child,
      );
    },
    routes: [
      GoRoute(
        path: '/organization/:organizationId',
        builder: (context, state) {
          final organizationId = state.pathParameters['organizationId']!;
          return DetailOrganizationPage(organizationId: organizationId);
        },
      ),
      GoRoute(
        path: '/organization/:organizationId/messages',
        builder: (context, state) {
          final organizationId = state.pathParameters['organizationId']!;
          return MessagesPage(organizationId: organizationId);
        },
        routes: [
          GoRoute(
            path: 'settings',
            builder: (context, state) {
              final organizationId = state.pathParameters['organizationId']!;
              return MessageSettingsPage(organizationId: organizationId);
            },
          ),
          GoRoute(
            path: ':roomId',
            builder: (context, state) {
              final organizationId = state.pathParameters['organizationId']!;
              final roomId = state.pathParameters['roomId']!;
              return MessageDetailPage(
                organizationId: organizationId,
                roomId: roomId,
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/organization/:organizationId/campaigns',
        builder: (context, state) {
          final organizationId = state.pathParameters['organizationId']!;
          return CampaignsPage(organizationId: organizationId);
        },
        routes: [
          GoRoute(
            path: 'multiconnect',
            builder: (context, state) {
              final organizationId = state.pathParameters['organizationId']!;
              return MulticonnectPage(organizationId: organizationId);
            },
          ),
          GoRoute(
            path: 'aichatbot',
            builder: (context, state) {
              final organizationId = state.pathParameters['organizationId']!;
              return AIChatbotPage(organizationId: organizationId);
            },
          ),
          GoRoute(
            path: 'filldata',
            builder: (context, state) {
              final organizationId = state.pathParameters['organizationId']!;
              return FillDataPage(organizationId: organizationId);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/organization/:organizationId/settings',
        builder: (context, state) {
          final organizationId = state.pathParameters['organizationId']!;
          return SettingsPage(organizationId: organizationId);
        },
      ),
    ],
  ),

  // Workspace routes with shell
  ShellRoute(
    builder: (context, state, child) {
      final organizationId = state.pathParameters['organizationId'];
      final workspaceId = state.pathParameters['workspaceId'];
      if (organizationId == null || workspaceId == null) {
        return const SizedBox();
      }
      return DetailWorkspacePage(
        organizationId: organizationId,
        workspaceId: workspaceId,
        child: child,
      );
    },
    routes: [
      GoRoute(
        path: '/organization/:organizationId/workspace/:workspaceId/customers',
        builder: (context, state) {
          final organizationId = state.pathParameters['organizationId']!;
          final workspaceId = state.pathParameters['workspaceId']!;
          return CustomersPage(
            organizationId: organizationId,
            workspaceId: workspaceId,
          );
        },
        routes: [
          GoRoute(
            path: 'new',
            builder: (context, state) {
              final organizationId = state.pathParameters['organizationId']!;
              final workspaceId = state.pathParameters['workspaceId']!;
              return AddCustomerPage(
                organizationId: organizationId,
                workspaceId: workspaceId,
              );
            },
          ),
          GoRoute(
            path: ':customerId',
            builder: (context, state) {
              final organizationId = state.pathParameters['organizationId']!;
              final workspaceId = state.pathParameters['workspaceId']!;
              final customerId = state.pathParameters['customerId']!;
              return CustomerDetailPage(
                organizationId: organizationId,
                workspaceId: workspaceId,
                customerId: customerId,
              );
            },
            routes: [
              GoRoute(
                path: 'basic-info',
                builder: (context, state) {
                  final organizationId =
                      state.pathParameters['organizationId']!;
                  final workspaceId = state.pathParameters['workspaceId']!;
                  final customerId = state.pathParameters['customerId']!;
                  final customerDetail = state.extra as Map<String, dynamic>;
                  return CustomerBasicInfoPage(
                    customerDetail: customerDetail,
                  );
                },
              ),
              GoRoute(
                path: 'edit',
                builder: (context, state) {
                  final organizationId =
                      state.pathParameters['organizationId']!;
                  final workspaceId = state.pathParameters['workspaceId']!;
                  final customerId = state.pathParameters['customerId']!;
                  final customerDetail = state.extra as Map<String, dynamic>;
                  return EditCustomerPage(
                    organizationId: organizationId,
                    workspaceId: workspaceId,
                    customerId: customerId,
                    customerData: customerDetail,
                  );
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/organization/:organizationId/workspace/:workspaceId/teams',
        builder: (context, state) {
          final organizationId = state.pathParameters['organizationId']!;
          final workspaceId = state.pathParameters['workspaceId']!;
          return TeamsPage(
            organizationId: organizationId,
            workspaceId: workspaceId,
          );
        },
      ),
      GoRoute(
        path: '/organization/:organizationId/workspace/:workspaceId/reports',
        builder: (context, state) {
          final organizationId = state.pathParameters['organizationId']!;
          final workspaceId = state.pathParameters['workspaceId']!;
          return ReportsPage(
            organizationId: organizationId,
            workspaceId: workspaceId,
          );
        },
      ),
    ],
  ),

  // Detail routes
  GoRoute(
    path: '/organization/:organizationId/workspace/:workspaceId/teams/:teamId',
    builder: (context, state) {
      final organizationId = state.pathParameters['organizationId']!;
      final workspaceId = state.pathParameters['workspaceId']!;
      final teamId = state.pathParameters['teamId']!;
      return TeamDetailPage(
        organizationId: organizationId,
        workspaceId: workspaceId,
        teamId: teamId,
      );
    },
  ),
];
