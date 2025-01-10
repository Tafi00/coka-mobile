import 'package:flutter/material.dart';
import 'router.dart';
import 'api/api_service.dart';
import 'core/theme/app_theme.dart';
import 'api/api_client.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final apiService = ApiService();
  final apiClient = ApiClient();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Kiểm tra token
  final token = await ApiClient.storage.read(key: 'access_token');
  final initialLocation = token != null ? '/organization/default' : '/';

  final router = GoRouter(
    initialLocation: initialLocation,
    routes: appRoutes,
    redirect: (context, state) async {
      final token = await ApiClient.storage.read(key: 'access_token');
      final isLoginRoute = state.matchedLocation == '/';

      // Nếu không có token và không ở trang login -> chuyển về login
      if (token == null && !isLoginRoute) {
        return '/';
      }

      // Nếu có token và đang ở trang login -> chuyển về trang chủ
      if (token != null && isLoginRoute) {
        return '/organization/default';
      }

      return null;
    },
  );

  runApp(MyApp(apiService: apiService, router: router));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.apiService,
    required this.router,
  });

  final ApiService apiService;
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Coka',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
