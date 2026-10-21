import 'package:flutter/material.dart';
import 'package:kisekae/screens/dashboard.dart';
import 'package:kisekae/screens/getting_started.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kisekae/screens/home_screen.dart';
import 'package:kisekae/screens/onboarding_screen.dart';
import 'package:kisekae/screens/seller_start.dart';
import 'package:kisekae/services/dio.dart';
import 'package:kisekae/services/storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await DioClient.init();

  final token = await TokenStorage().readAccessToken();
  final bool isLoggedIn = token != null && token.isNotEmpty;
  final bool isSeller = isLoggedIn && await TokenStorage().readIsSeller();

  runApp(MyApp(isLoggedIn: isLoggedIn, isSeller: isSeller));
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;
  final bool isSeller;
  const MyApp({super.key, required this.isLoggedIn, required this.isSeller});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _setDark(bool isDark) {
    setState(() => _themeMode = isDark ? ThemeMode.dark : ThemeMode.light);
  }

  static const _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF8B2E3E),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF6F2532),
    onSecondary: Color(0xFFFFFFFF),
    error: Color(0xFFFF2C2C),
    onError: Color(0xFFEAEAEA),
    surface: Color(0xFFEEE9E4),
    onSurface: Color(0xFF09090A),
    surfaceContainerHighest: Color(0xFFEEE0E2),
  );

  static const _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFC4566A),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFFD9798A),
    onSecondary: Color(0xFF09090A),
    error: Color(0xFFFF5C5C),
    onError: Color(0xFF09090A),
    surface: Color(0xFF121212),
    onSurface: Color(0xFFEEE9E4),
    surfaceContainerHighest: Color(0xFF2A2A2C),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kisekae',
      themeMode: _themeMode,
      theme: ThemeData(colorScheme: _lightScheme),
      darkTheme: ThemeData(colorScheme: _darkScheme),
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      routes: {
        '/seller-store': (context) => const StoreSelectionScreen(),
        '/seller-dashboard': (context) => const SellerDashboardScreen(),
        '/login': (context) => const GettingStartedScreen(),
        '/home': (context) => const HomeScreen(),
      },
      home: _startScreen(),
    );
  }

  Widget _startScreen() {
    if (!widget.isLoggedIn) return OnboardingScreen(onThemeChanged: _setDark);
    return widget.isSeller ? const SellerDashboardScreen() : const HomeScreen();
  }
}
