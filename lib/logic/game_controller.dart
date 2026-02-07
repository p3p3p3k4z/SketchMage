import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cross_file/cross_file.dart';
import 'package:path_provider/path_provider.dart';
import '../models/sketch_validation.dart';
import '../models/app_config.dart';
import '../services/gemini_service.dart';
import '../services/tts_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gal/gal.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';

enum GameState { initial, preview, loading, validating, success, failure }

class GameController extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  final TtsService _ttsService = TtsService();

  GameState _state = GameState.initial;
  GameState get state => _state;

  int _currentLevel = 1;
  int get currentLevel => _currentLevel;

  SketchValidation? _lastValidation;
  SketchValidation? get lastValidation => _lastValidation;

  // Public getter for the last identified object type
  String? get lastObjectType => _lastValidation?.objectType;

  Uint8List? _generatedImageBytes;
  Uint8List? get generatedImageBytes => _generatedImageBytes;

  XFile? _pendingImage;
  Uint8List? _pendingImageBytes;
  Uint8List? get pendingImageBytes => _pendingImageBytes;

  AppConfig? _appConfig;
  AppConfig? get appConfig => _appConfig;

  String? _selectedStyle;
  String? get selectedStyle => _selectedStyle;

  final List<String> _unlockedObjects = [];
  List<String> get unlockedObjects => _unlockedObjects;

  List<String> _galleryImages = [];
  List<String> get galleryImages => _galleryImages;

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
    reset(); // Reset state when changing levels
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
        orElse: () => _appConfig!.levels.first,
      );

      final validation = await _geminiService.validateSketch(
        _pendingImage!,
        levelConfig,
        selectedStyle: _selectedStyle,
      );

      _lastValidation = validation;

      if (validation.success) {
        // Speak the full feedback sequence
        String fullSpeech = "";
        if (validation.objectType.isNotEmpty) {
          fullSpeech += "It's a ${validation.objectType}! ";
        }
        fullSpeech += validation.feedback;
        _ttsService.speak(fullSpeech);

        if (validation.objectType.isNotEmpty && !_unlockedObjects.contains(validation.objectType)) {
          _unlockedObjects.add(validation.objectType);
        }

        _state = GameState.success;
        await _saveSketchToGallery(_pendingImage!);
      } else {
        _ttsService.speak(validation.feedback); // Speak feedback on failure too
        _state = GameState.failure;
      }
    } catch (e) {
      debugPrint("Game Logic Error: $e");
      _state = GameState.failure;
      _ttsService.speak("Oh no! Something went wrong with the magic.");
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

  Future<void> _saveSketchToGallery(XFile imageFile) async {
    try {
      if (kIsWeb) return;
      final appDir = await getApplicationDocumentsDirectory();
      final sketchesDir = Directory('${appDir.path}/sketches');
      if (!await sketchesDir.exists()) await sketchesDir.create(recursive: true);
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
    _ttsService.stop();
    _state = GameState.initial;
    _lastValidation = null;
    _generatedImageBytes = null;
    _pendingImage = null;
    _pendingImageBytes = null;
    notifyListeners();
  }
}
