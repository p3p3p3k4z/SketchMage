import 'dart:typed_data';
import '../services/camera_service.dart';
import '../services/gemini_service.dart';
import '../models/level.dart';
import '../models/transformation_result.dart';

class SketchMageController {
  final GeminiService _geminiService;
  final CameraService _cameraService;
  
  Level? _currentLevel;
  bool _isProcessing = false;

  SketchMageController(this._geminiService, this._cameraService);

  bool get isProcessing => _isProcessing;

  /// Inicia un nivel específico
  void setLevel(Level level) {
    _currentLevel = level;
  }

  /// El núcleo de "The Living Path": Captura y transforma
  Future<TransformationResult?> processCurrentSketch() async {
    if (_isProcessing) return null;
    
    _isProcessing = true;
    try {
      // 1. Capturar el frame de la cámara
      final Uint8List? imageBytes = await _cameraService.captureFrame();
      if (imageBytes == null) throw Exception('No se pudo capturar la imagen');

      // 2. Procesar con Gemini (Aventura o Creativo)
      TransformationResult result;
      if (_currentLevel != null) {
        result = await _geminiService.validateLevelSketch(imageBytes, _currentLevel!);
      } else {
        result = await _geminiService.analyzeCreativeSketch(imageBytes);
      }

      return result;
    } finally {
      _isProcessing = false;
    }
  }
}
