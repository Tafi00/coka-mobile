import 'package:go_router/go_router.dart';
import 'pages/auth/login_page.dart';
import 'pages/organization/organization_page.dart';
import 'pages/organization/messages/messages_page.dart';
import 'pages/organization/messages/message_detail_page.dart';
import 'pages/organization/messages/message_settings_page.dart';
import 'pages/organization/campaigns/campaigns_page.dart';
import 'pages/organization/campaigns/multiconnect_page.dart';
import 'pages/organization/campaigns/aichatbot_page.dart';
import 'pages/organization/campaigns/filldata_page.dart';
import 'pages/organization/workspace/customers/customers_page.dart';
import 'pages/organization/workspace/customers/customer_detail_page.dart';
import 'pages/organization/workspace/teams/teams_page.dart';
import 'pages/organization/workspace/teams/team_detail_page.dart';
import 'pages/organization/workspace/reports/reports_page.dart';
import 'pages/organization/settings/settings_page.dart';

final appRoutes = [
  // Auth route
  GoRoute(
    path: '/',
    builder: (context, state) => const LoginPage(),
  ),

  // Organization routes
  GoRoute(
    path: '/organization/:organizationId',
    builder: (context, state) {
      final organizationId = state.pathParameters['organizationId']!;
      return OrganizationPage(organizationId: organizationId);
    },
    routes: [
      // Messages routes
      GoRoute(
        path: 'messages',
        builder: (context, state) {
          final organizationId = state.pathParameters['organizationId']!;
          return MessagesPage(organizationId: organizationId);
        },
      ),
      GoRoute(
        path: 'messages/:roomId',
        builder: (context, state) {
          final organizationId = state.pathParameters['organizationId']!;
          final roomId = state.pathParameters['roomId']!;
          return MessageDetailPage(
              organizationId: organizationId, roomId: roomId);
        },
      ),
      GoRoute(
        path: 'messages/settings',
        builder: (context, state) {
          final organizationId = state.pathParameters['organizationId']!;
          return MessageSettingsPage(organizationId: organizationId);
        },
      ),

      // Campaigns routes
      GoRoute(
        path: 'campaigns',
        builder: (context, state) {
          final organizationId = state.pathParameters['organizationId']!;
          return CampaignsPage(organizationId: organizationId);
        },
      ),
      GoRoute(
        path: 'campaigns/multiconnect',
        builder: (context, state) {
          final organizationId = state.pathParameters['organizationId']!;
          return MulticonnectPage(organizationId: organizationId);
        },
      ),
      GoRoute(
        path: 'campaigns/aichatbot',
        builder: (context, state) {
          final organizationId = state.pathParameters['organizationId']!;
          return AIChatbotPage(organizationId: organizationId);
        },
      ),
      GoRoute(
        path: 'campaigns/filldata',
        builder: (context, state) {
          final organizationId = state.pathParameters['organizationId']!;
          return FillDataPage(organizationId: organizationId);
        },
      ),

      // Workspace routes
      GoRoute(
        path: 'workspace/:workspaceId/customers',
        builder: (context, state) {
          final organizationId = state.pathParameters['organizationId']!;
          final workspaceId = state.pathParameters['workspaceId']!;
          return CustomersPage(
            organizationId: organizationId,
            workspaceId: workspaceId,
          );
        },
      ),
      GoRoute(
        path: 'workspace/:workspaceId/customers/:customerId',
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
      ),
      GoRoute(
        path: 'workspace/:workspaceId/teams',
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
        path: 'workspace/:workspaceId/teams/:teamId',
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
      GoRoute(
        path: 'workspace/:workspaceId/reports',
        builder: (context, state) {
          final organizationId = state.pathParameters['organizationId']!;
          final workspaceId = state.pathParameters['workspaceId']!;
          return ReportsPage(
            organizationId: organizationId,
            workspaceId: workspaceId,
          );
        },
      ),

      // Settings route
      GoRoute(
        path: 'settings',
        builder: (context, state) {
          final organizationId = state.pathParameters['organizationId']!;
          return SettingsPage(organizationId: organizationId);
        },
      ),
    ],
  ),
];

final router = GoRouter(
  initialLocation: '/',
  routes: appRoutes,
);
