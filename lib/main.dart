import 'package:flutter/material.dart';
import 'router.dart';
import 'api/api_service.dart';
import 'core/theme/app_theme.dart';
import 'api/api_client.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/customer_provider.dart';

class CustomViMessages implements timeago.LookupMessages {
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => '';
  @override
  String suffixAgo() => 'trước';
  @override
  String suffixFromNow() => 'nữa';
  @override
  String lessThanOneMinute(int seconds) => 'vài giây';
  @override
  String aboutAMinute(int minutes) => '1 phút';
  @override
  String minutes(int minutes) => '$minutes phút';
  @override
  String aboutAnHour(int minutes) => '1 giờ';
  @override
  String hours(int hours) => '$hours giờ';
  @override
  String aDay(int hours) => '1 ngày';
  @override
  String days(int days) => '$days ngày';
  @override
  String aboutAMonth(int days) => '1 tháng';
  @override
  String months(int months) => '$months tháng';
  @override
  String aboutAYear(int year) => '1 năm';
  @override
  String years(int years) => '$years năm';
  @override
  String wordSeparator() => ' ';
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final apiService = ApiService();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Kiểm tra token
  final token = await ApiClient.storage.read(key: 'access_token');
  final defaultOrgId =
      await ApiClient.storage.read(key: 'default_organization_id');
  final initialLocation =
      token != null ? '/organization/${defaultOrgId ?? 'default'}' : '/';

  final appRouter = GoRouter(
    initialLocation: initialLocation,
    routes: appRoutes,
    redirect: (context, state) async {
      final token = await ApiClient.storage.read(key: 'access_token');
      final defaultOrgId =
          await ApiClient.storage.read(key: 'default_organization_id');
      final isLoginRoute = state.matchedLocation == '/';

      if (token == null && !isLoginRoute) {
        return '/';
      }

      if (token != null && isLoginRoute) {
        return '/organization/${defaultOrgId ?? 'default'}';
      }

      return null;
    },
  );

  timeago.setLocaleMessages('vi', CustomViMessages());

  runApp(
    ProviderScope(
      child: MyApp(apiService: apiService, router: appRouter),
    ),
  );
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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('vi', 'VN'),
        Locale('en', 'US'),
      ],
      locale: const Locale('vi', 'VN'),
    );
  }
}
