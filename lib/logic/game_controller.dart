import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cross_file/cross_file.dart';
import 'package:path_provider/path_provider.dart';
import '../models/sketch_validation.dart';
import '../models/app_config.dart';
import '../services/gemini_service.dart';
import '../services/image_generation_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:gal/gal.dart'; // Asegúrate de tener gal: ^2.3.0 en pubspec
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';

enum GameState { initial, preview, loading, validating, success, failure }

class GameController extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  final ImageGenerationService _imageGenService = ImageGenerationService();

  GameState _state = GameState.initial;
  GameState get state => _state;
  
  int _currentLevel = 1;
  int get currentLevel => _currentLevel;

  SketchValidation? _lastValidation;
  SketchValidation? get lastValidation => _lastValidation;

  Uint8List? _generatedImageBytes;
  Uint8List? get generatedImageBytes => _generatedImageBytes;
  
  // Getter de compatibilidad para evitar errores si la UI busca el path antiguo
  String? get generatedTexturePath => _generatedImageBytes != null ? "IN_MEMORY" : null;

  AppConfig? _appConfig;
  AppConfig? get appConfig => _appConfig;
  
  String? _selectedStyle;
  String? get selectedStyle => _selectedStyle;
  
  List<String> _galleryImages = [];
  List<String> get galleryImages => _galleryImages;

  XFile? _pendingImage;
  XFile? get pendingImage => _pendingImage;

  Uint8List? _pendingImageBytes;
  Uint8List? get pendingImageBytes => _pendingImageBytes;

  GameController() {
    _init();
  }

  Future<void> _init() async {
    _appConfig = await AppConfig.load();
    await _loadGallery(); 
    notifyListeners();
  }

  void setStyle(String? style) {
    _selectedStyle = style;
    notifyListeners();
  }

  void setLevel(int levelId) {
    _currentLevel = levelId;
    _state = GameState.initial;
    _lastValidation = null;
    _generatedImageBytes = null;
    notifyListeners();
  }

  Future<void> captureImage(XFile imageFile) async {
    _pendingImage = imageFile;
    _pendingImageBytes = await imageFile.readAsBytes();
    _state = GameState.preview;
    notifyListeners();
  }
  
  void retake() {
    _pendingImage = null;
    _pendingImageBytes = null;
    _state = GameState.initial;
    notifyListeners();
  }

  Future<void> confirmAndProcess() async {
    if (_pendingImage == null || _appConfig == null) return;
    
    _state = GameState.validating;
    notifyListeners();

    try {
      final levelConfig = _appConfig!.levels.firstWhere(
        (l) => l.id == _currentLevel, 
        orElse: () => _appConfig!.levels.first
      );

      final validation = await _geminiService.validateSketch(
        _pendingImage!, 
        levelConfig, 
        selectedStyle: _selectedStyle
      );
      
      _lastValidation = validation;

      if (validation.success) {
        if (validation.stylePrompt.isNotEmpty) {
           _generatedImageBytes = await _imageGenService.generate3DImage(validation.stylePrompt);
        }
        _state = GameState.success;
        await _saveSketchToGallery(_pendingImage!);
      } else {
        _state = GameState.failure;
      }
    } catch (e) {
      debugPrint("Game Logic Error: $e");
      _state = GameState.failure;
    }
    notifyListeners();
  }

  Future<void> pickFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        await captureImage(image);
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  // --- FUNCIÓN RECUPERADA ---
  Future<void> saveGeneratedImage() async {
    if (_generatedImageBytes == null) return;
    
    try {
      if (kIsWeb) {
        final blob = html.Blob([_generatedImageBytes!]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", "sketchmage_${DateTime.now().millisecondsSinceEpoch}.jpg")
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        await Gal.putImageBytes(_generatedImageBytes!);
        debugPrint("Imagen guardada en galería");
      }
    } catch (e) {
      debugPrint("Error saving image: $e");
    }
  }

  Future<void> _saveSketchToGallery(XFile imageFile) async {
    try {
      if (kIsWeb) return;
      final appDir = await getApplicationDocumentsDirectory();
      final sketchesDir = Directory('${appDir.path}/sketches');
      if (!await sketchesDir.exists()) {
        await sketchesDir.create(recursive: true);
      }
      final fileName = 'sketch_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = '${sketchesDir.path}/$fileName';
      await imageFile.saveTo(savedPath);
      _galleryImages.insert(0, savedPath);
      notifyListeners();
    } catch (e) {
      debugPrint("Error saving sketch: $e");
    }
  }

  Future<void> _loadGallery() async {
    try {
      if (kIsWeb) return;
      final appDir = await getApplicationDocumentsDirectory();
      final sketchesDir = Directory('${appDir.path}/sketches');
      if (await sketchesDir.exists()) {
        final files = sketchesDir.listSync()
          .where((item) => item.path.endsWith('.jpg'))
          .map((item) => item.path)
          .toList();
        files.sort((a, b) => b.compareTo(a));
        _galleryImages = files;
      }
    } catch (e) {
      debugPrint("Error loading gallery: $e");
    }
  }

  void reset() {
    _state = GameState.initial;
    _lastValidation = null;
    _generatedImageBytes = null;
    _pendingImage = null;
    _pendingImageBytes = null;
    notifyListeners();
  }
}