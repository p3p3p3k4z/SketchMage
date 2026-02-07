import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import '../logic/game_controller.dart';
import 'magic_result_screen.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Text("Level ${gameState.currentLevel}", style: const TextStyle(fontSize: 18)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          if (_isInit && gameState.state == GameState.initial) 
            SizedBox.expand(child: CameraPreview(_controller!))
          else if (gameState.pendingImageBytes != null)
             SizedBox.expand(
               child: Image.memory(
                 gameState.pendingImageBytes!, 
                 fit: BoxFit.cover,
               ),
             )
          else 
            const Center(child: CircularProgressIndicator()),

          if (gameState.state == GameState.success && gameState.lastValidation?.objectType.isNotEmpty == true)
            Positioned(
              top: 20,
              left: 50,
              right: 50,
              child: _buildSmallIdentityBanner(gameState),
            ),

          if (gameState.state == GameState.validating)
            _buildLoadingOverlay(),

          if (gameState.state == GameState.success || gameState.state == GameState.failure)
            Positioned(
              bottom: 120,
              left: 30,
              right: 30,
              child: _buildCompactFeedbackCard(gameState),
            ),
        ],
      ),
      floatingActionButton: _buildHorizontalActionButtons(context, gameState),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildSmallIdentityBanner(GameController gameState) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("IT'S A...", style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
          Text(
            gameState.lastValidation!.objectType.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.purpleAccent),
            SizedBox(height: 10),
            Text("Summoning magic...", style: TextStyle(color: Colors.white, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactFeedbackCard(GameController gameState) {
    return Card(
      color: gameState.state == GameState.success ? Colors.green.withOpacity(0.8) : Colors.red.withOpacity(0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Text(
          gameState.lastValidation?.feedback ?? '',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildHorizontalActionButtons(BuildContext context, GameController gameState) {
    if (gameState.state == GameState.initial) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton.small(
            heroTag: "gallery",
            onPressed: () => gameState.pickFromGallery(),
            backgroundColor: Colors.white,
            child: const Icon(Icons.photo_library, color: Colors.purple),
          ),
          const SizedBox(width: 20),
          FloatingActionButton(
            heroTag: "capture",
            onPressed: _capture,
            backgroundColor: Colors.purpleAccent,
            child: const Icon(Icons.camera_alt, color: Colors.white),
          ),
        ],
      );
    }

    if (gameState.state == GameState.preview) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton.extended(
            heroTag: "retake",
            onPressed: () => gameState.retake(),
            icon: const Icon(Icons.refresh),
            label: const Text("Retake"),
            backgroundColor: Colors.grey[800],
          ),
          const SizedBox(width: 15),
          FloatingActionButton.extended(
            heroTag: "confirm",
            onPressed: () => gameState.confirmAndProcess(),
            icon: const Icon(Icons.auto_awesome),
            label: const Text("Bring to Life"),
            backgroundColor: Colors.purpleAccent,
          ),
        ],
      );
    }

    if (gameState.state == GameState.success) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton.extended(
            heroTag: "reset",
            onPressed: () => gameState.reset(),
            icon: const Icon(Icons.replay),
            label: const Text("Next"),
            backgroundColor: Colors.blue,
          ),
          const SizedBox(width: 15),
          // MAGIC TRANSFORM BUTTON: Only appears if objectType exists
          FloatingActionButton.extended(
            heroTag: "transform",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MagicResultScreen(objectId: gameState.lastObjectType!),
                ),
              );
            },
            icon: const Icon(Icons.bolt, color: Colors.amberAccent),
            label: const Text("Transform"),
            backgroundColor: Colors.deepPurple,
          ),
        ],
      );
    }

    if (gameState.state == GameState.failure) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton.extended(
            heroTag: "retry",
            onPressed: () => gameState.reset(),
            icon: const Icon(Icons.replay),
            label: const Text("Try Again"),
            backgroundColor: Colors.orange,
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
