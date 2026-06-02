import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/main_shell.dart';
import 'services/history_service.dart';

void main() async {
  // Guarantee widgets binding handles native services asynchronously
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize and seed default mock values on first launch
  final historyService = HistoryService();
  await historyService.init();

  // Read onboarding complete flags from local storage cache
  final prefs = await SharedPreferences.getInstance();
  final showOnboarding = !(prefs.getBool('leafscan_onboarding_done') ?? false);

  runApp(MyApp(showOnboarding: showOnboarding));
}

class MyApp extends StatefulWidget {
  final bool showOnboarding;

  const MyApp({super.key, required this.showOnboarding});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _showOnboarding;

  @override
  void initState() {
    super.initState();
    _showOnboarding = widget.showOnboarding;
  }

  void _finishOnboarding() {
    setState(() {
      _showOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LeafScan',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: _showOnboarding
          ? SplashScreen(onFinished: _finishOnboarding)
          : const MainShell(),
    );
  }
}
