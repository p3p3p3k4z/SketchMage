import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'logic/game_controller.dart';
import 'ui/level_dashboard.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// FIX: Override HTTP client to avoid Proxy environment lookup failure on some Linux/Desktop envs
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..findProxy = (uri) {
      return "DIRECT";
    };
  }
}

Future<void> main() async {
  // Apply the override
  HttpOverrides.global = MyHttpOverrides();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("DotEnv Load Error: $e");
    // Continue even if dotenv fails, logic will catch missing key later
  }
  
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
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const LevelDashboard(),
    );
  }
}
