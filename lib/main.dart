import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

// Tus importaciones
import 'logic/game_controller.dart';
import 'ui/level_dashboard.dart';
import 'firebase_options.dart';

// NOTA: Se eliminó 'dart:io' y 'flutter_dotenv' porque rompen la versión Web.

Future<void> main() async {
  // 1. Inicialización básica
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializar Firebase
  // Esto es crucial para que tu Hosting y otras funciones conecten bien
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // NOTA: Ya no cargamos .env aquí.
  // La API Key se inyectará automáticamente gracias a los cambios
  // que hiciste en 'gemini_service.dart' usando String.fromEnvironment.

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
      home: const LevelDashboard(),
    );
  }
}