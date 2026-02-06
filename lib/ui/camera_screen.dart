import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import '../logic/game_controller.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      
      _controller = CameraController(cameras.first, ResolutionPreset.medium);
      await _controller!.initialize();
      if (mounted) setState(() => _isInit = true);
    } catch (e) {
      print("Camera init error: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final image = await _controller!.takePicture();
      if (mounted) {
        context.read<GameController>().captureImage(image);
      }
    } catch (e) {
      print("Capture error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameController>();
    final styles = gameState.appConfig?.styles ?? [];

    return Scaffold(
      appBar: AppBar(title: Text("Nivel ${gameState.currentLevel}")),
      body: Stack(
        children: [
          // Camera Preview
          if (_isInit && gameState.state != GameState.preview) 
            CameraPreview(_controller!)
          else if (gameState.state == GameState.preview && gameState.pendingImage != null)
             Image.network(
               gameState.pendingImage!.path, 
               fit: BoxFit.cover, 
               width: double.infinity, 
               height: double.infinity
             )
          else 
            const Center(child: Text("Buscando cámara / Simulador...")),

          // Style Selector Overlay (Top) - Only show in Camera Mode
          if (styles.isNotEmpty && gameState.state == GameState.initial)
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    dropdownColor: Colors.black87,
                    value: gameState.selectedStyle,
                    hint: const Text("Estilo Mágico (Opcional)", style: TextStyle(color: Colors.white)),
                    icon: const Icon(Icons.brush, color: Colors.purpleAccent),
                    isExpanded: true,
                    style: const TextStyle(color: Colors.white),
                    items: styles.map((s) => DropdownMenuItem(
                      value: s,
                      child: Text(s),
                    )).toList(),
                    onChanged: (val) => context.read<GameController>().setStyle(val),
                  ),
                ),
              ),
            ),

          // Generated Texture Display
          if (gameState.state == GameState.success && gameState.generatedTexturePath != null)
            Positioned(
              top: 70, // Moved down below selector
              right: 20,
              width: 150,
              height: 150,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 10)],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    gameState.generatedTexturePath!,
                    fit: BoxFit.cover,
                    loadingBuilder: (ctx, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (ctx, error, stackTrace) => const Center(child: Icon(Icons.error, color: Colors.red)),
                  ),
                ),
              ),
            ),

          // Loading Overlay
          if (gameState.state == GameState.validating)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.purpleAccent),
                    SizedBox(height: 20),
                    Text(
                      "Consultando a los espíritus de la IA...",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

          // Success/Failure Feedback
          if (gameState.state == GameState.success)
            Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              child: Card(
                color: Colors.green.withOpacity(0.9),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "¡Mágico! ${gameState.lastValidation?.feedback ?? ''}",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
            
           if (gameState.state == GameState.failure)
            Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              child: Card(
                color: Colors.red.withOpacity(0.9),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "${gameState.lastValidation?.feedback ?? 'Error desconocido'}",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
            
           // Preview Controls
           if (gameState.state == GameState.preview)
             Positioned(
               bottom: 30,
               left: 0,
               right: 0,
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                 children: [
                   FloatingActionButton.extended(
                     heroTag: "retake",
                     onPressed: () => context.read<GameController>().retake(),
                     icon: const Icon(Icons.refresh),
                     label: const Text("Repetir"),
                     backgroundColor: Colors.redAccent,
                   ),
                   FloatingActionButton.extended(
                     heroTag: "confirm",
                     onPressed: () => context.read<GameController>().confirmAndProcess(),
                     icon: const Icon(Icons.check),
                     label: const Text("Enviar a la IA"),
                     backgroundColor: Colors.greenAccent,
                   ),
                 ],
               ),
             ),
        ],
      ),
      // Main Camera Button (Only if Initial state)
      floatingActionButton: gameState.state == GameState.initial 
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton(
                heroTag: "gallery_import",
                onPressed: () => context.read<GameController>().pickFromGallery(),
                backgroundColor: Colors.white,
                child: const Icon(Icons.photo_library, color: Colors.purple),
              ),
              const SizedBox(width: 20),
              FloatingActionButton(
                heroTag: "camera_capture",
                onPressed: _capture,
                child: const Icon(Icons.camera),
              ),
            ],
          )
        : gameState.state == GameState.success 
           ? FloatingActionButton.extended(
                onPressed: () {
                   // context.read<GameController>().saveGeneratedImage();
                   ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text("Imagen guardada en la galería (Simulado)"))
                   );
                },
                icon: const Icon(Icons.download),
                label: const Text("Descargar al Dispositivo"),
             )
           : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
// Removed ARPathPainter as requested (the "strange line").
