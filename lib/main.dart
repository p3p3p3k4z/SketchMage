import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Importa tus archivos (ajusta las rutas según tu proyecto)
import 'logic/game_controller.dart';
import 'ui/level_dashboard.dart';

// FIX para entornos de escritorio/algunos navegadores
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..findProxy = (uri) => "DIRECT";
  }
}

Future<void> main() async {
  // 1. Asegurar inicialización de Widgets (Vital para plugins)
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Cargar variables de entorno (.env)
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Error cargando .env: $e");
  }

  // 3. Aplicar overrides de HTTP
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
      home: const LevelDashboard(), // Tu pantalla inicial
    );
  }
}