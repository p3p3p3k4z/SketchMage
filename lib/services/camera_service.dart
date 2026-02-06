import 'package:camera/camera.dart';
import 'dart:typed_data';

class CameraService {
  CameraController? _controller;
  List<CameraDescription>? _cameras;

  Future<void> initialize() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _controller = CameraController(
        _cameras![0],
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await _controller!.initialize();
    }
  }

  Future<Uint8List?> captureFrame() async {
    if (_controller == null || !_controller!.value.isInitialized) return null;
    
    final image = await _controller!.takePicture();
    return await image.readAsBytes();
  }

  CameraController? get controller => _controller;

  void dispose() {
    _controller?.dispose();
  }
}
