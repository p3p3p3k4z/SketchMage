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
      debugPrint("Camera init error: $e");
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
      debugPrint("Capture error: $e");
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
          // 1. PREVIEW (Camera or Taken Photo)
          if (_isInit && gameState.state != GameState.preview && gameState.state != GameState.success && gameState.state != GameState.failure) 
            CameraPreview(_controller!)
          else if (gameState.pendingImageBytes != null)
             Image.memory(
               gameState.pendingImageBytes!, 
               fit: BoxFit.cover, 
               width: double.infinity, 
               height: double.infinity
             )
          else 
            const Center(child: Text("Loading magic...")),

          // 2. STYLE SELECTOR (Only at start)
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
                    hint: const Text("Magic Style (Optional)", style: TextStyle(color: Colors.white)),
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

          // 3. 3D RESULT (Overlay on original sketch)
          if (gameState.state == GameState.success && gameState.generatedImageBytes != null)
            Positioned(
              top: 70,
              right: 20,
              width: 180,
              height: 180,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.purpleAccent, width: 3),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 15)],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    gameState.generatedImageBytes!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

          // 4. LOADING OVERLAY
          if (gameState.state == GameState.validating)
            Container(
              color: Colors.black87,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.purpleAccent),
                    SizedBox(height: 20),
                    Text(
                      "Summoning AI...",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

          // 5. FEEDBACK MESSAGES
          if (gameState.state == GameState.success || gameState.state == GameState.failure)
            Positioned(
              bottom: 110,
              left: 20,
              right: 20,
              child: Card(
                color: gameState.state == GameState.success 
                    ? Colors.green.withOpacity(0.9) 
                    : Colors.red.withOpacity(0.9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        gameState.state == GameState.success ? "SUCCESS!" : "TRY AGAIN!",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        gameState.lastValidation?.feedback ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
           // 6. PREVIEW CONTROLS
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
                     onPressed: () => gameState.retake(),
                     icon: const Icon(Icons.refresh),
                     label: const Text("Retake"),
                     backgroundColor: Colors.grey[800],
                   ),
                   FloatingActionButton.extended(
                     heroTag: "confirm",
                     onPressed: () => gameState.confirmAndProcess(),
                     icon: const Icon(Icons.auto_awesome),
                     label: const Text("Bring to Life"),
                     backgroundColor: Colors.purpleAccent,
                   ),
                 ],
               ),
             ),
        ],
      ),

      // 7. MAIN BUTTONS AND FINAL ACTION
      floatingActionButton: _buildMainActionButtons(context, gameState),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget? _buildMainActionButtons(BuildContext context, GameController gameState) {
    if (gameState.state == GameState.initial) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            heroTag: "gallery",
            onPressed: () => gameState.pickFromGallery(),
            backgroundColor: Colors.white,
            child: const Icon(Icons.photo_library, color: Colors.purple),
          ),
          const SizedBox(width: 25),
          FloatingActionButton.large(
            heroTag: "capture",
            onPressed: _capture,
            backgroundColor: Colors.purpleAccent,
            child: const Icon(Icons.camera_alt, size: 40, color: Colors.white),
          ),
        ],
      );
    }

    if (gameState.state == GameState.success) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: "download",
            onPressed: () => gameState.saveGeneratedImage(),
            icon: const Icon(Icons.download),
            label: const Text("Save Magic"),
            backgroundColor: Colors.blueAccent,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => gameState.reset(),
            child: const Text("Start Over", style: TextStyle(color: Colors.white)),
          )
        ],
      );
    }
    
    if (gameState.state == GameState.failure) {
       return FloatingActionButton.extended(
            onPressed: () => gameState.retake(),
            icon: const Icon(Icons.edit),
            label: const Text("Try Again"),
            backgroundColor: Colors.orangeAccent,
          );
    }

    return null;
  }
}