import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Import your files (adjust paths according to your project)
import 'logic/game_controller.dart';
import 'ui/level_dashboard.dart';

// FIX to override HTTP client to avoid Proxy environment lookup failure on some Linux/Desktop envs
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..findProxy = (uri) => "DIRECT";
  }
}

Future<void> main() async {
  // 1. Ensure Widgets Initialization (Vital for plugins)
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Load environment variables (.env)
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Error loading .env: $e");
  }

  // 3. Apply HTTP overrides
  HttpOverrides.global = MyHttpOverrides();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameController()),
      ],
      child: const SketchMageApp(),
    ),
  );
}

class SketchMageApp extends StatelessWidget {
  const SketchMageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SketchMage',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const LevelDashboard(), // Your initial screen
    );
  }
}