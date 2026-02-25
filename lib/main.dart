import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'data/seed/data_seeding_service.dart';
import 'screens/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Seed initial data on first run
  try {
    final seedingService = DataSeedingService();
    await seedingService.seedData();
  } catch (e) {
    // Continue even if seeding fails
    debugPrint('Data seeding error: $e');
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      home: const MainShell(),
    );
  }
}
