import 'package:flutter/material.dart';
import 'router.dart';
import 'api/api_service.dart';
import 'core/theme/app_theme.dart';

void main() {
  final apiService = ApiService();
  runApp(MyApp(apiService: apiService));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.apiService});

  final ApiService apiService;

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
