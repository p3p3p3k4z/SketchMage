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
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:typed_data';

enum GameState { initial, preview, loading, validating, success, failure }

class GameController extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  final ImageGenerationService _imageGenService = ImageGenerationService();

  // State Management
  GameState _state = GameState.initial;
  GameState get state => _state;
  
  // Levels
  int _currentLevel = 1;
  int get currentLevel => _currentLevel;

  // Validation Results
  SketchValidation? _lastValidation;
  SketchValidation? get lastValidation => _lastValidation;

  String? _generatedTexturePath;
  String? get generatedTexturePath => _generatedTexturePath;

  // Configuration
  AppConfig? _appConfig;
  AppConfig? get appConfig => _appConfig;
  
  // Style and Gallery
  String? _selectedStyle;
  String? get selectedStyle => _selectedStyle;
  
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
    _state = GameState.initial;
    _lastValidation = null;
    _generatedTexturePath = null;
    notifyListeners();
  }

  XFile? _pendingImage;
  XFile? get pendingImage => _pendingImage;

  Future<void> captureImage(XFile imageFile) async {
    _pendingImage = imageFile;
    _state = GameState.preview;
    notifyListeners();
  }
  
  void retake() {
    _pendingImage = null;
    _state = GameState.initial;
    notifyListeners();
  }

  Future<void> confirmAndProcess() async {
    if (_pendingImage == null || _appConfig == null) return;
    
    _state = GameState.validating;
    notifyListeners();

    try {
      // Find config for current level
      final levelConfig = _appConfig!.levels.firstWhere(
        (l) => l.id == _currentLevel, 
        orElse: () => _appConfig!.levels.first
      );

      // 1. Validate with Gemini (passing config and style)
      final validation = await _geminiService.validateSketch(
        _pendingImage!, 
        levelConfig, 
        selectedStyle: _selectedStyle
      );
      
      _lastValidation = validation;

      if (validation.success) {
        _state = GameState.success;
        // 2. Generate Texture if successful
        if (validation.stylePrompt.isNotEmpty) {
           _generatedTexturePath = await _imageGenService.generateTexture(validation.stylePrompt);
        }
        
        // 3. Auto-save to gallery
        await _saveSketchToGallery(_pendingImage!);
        
      } else {
        _state = GameState.failure;
      }
    } catch (e) {
      print("Game Logic Error: $e");
      _state = GameState.failure;
    }

    notifyListeners();
  }

  void reset() {
    _state = GameState.initial;
    _lastValidation = null;
    _generatedTexturePath = null;
    _pendingImage = null;
    notifyListeners();
  }
  
  Future<void> pickFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        captureImage(image);
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<void> saveGeneratedImage() async {
    if (_generatedTexturePath == null) return;
    
    try {
      // Download the image bytes
      var response = await http.get(Uri.parse(_generatedTexturePath!));
      
      if (response.statusCode == 200) {
        final result = await ImageGallerySaver.saveImage(
          Uint8List.fromList(response.bodyBytes),
          quality: 100,
          name: "magic_sketch_${DateTime.now().millisecondsSinceEpoch}"
        );
        print("Image saved to gallery: $result");
      } else {
        print("Failed to download image: ${response.statusCode}");
      }

    } catch (e) {
      print("Error saving image: $e");
    }
  }

  Future<void> _saveSketchToGallery(XFile imageFile) async {
    try {
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
      print("Error saving sketch: $e");
    }
  }
  
  Future<void> _loadGallery() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final sketchesDir = Directory('${appDir.path}/sketches');
      if (await sketchesDir.exists()) {
        final files = sketchesDir.listSync()
          .where((item) => item.path.endsWith('.jpg'))
          .map((item) => item.path)
          .toList();
        // Sort by date desc (filename)
        files.sort((a, b) => b.compareTo(a));
        _galleryImages = files;
      }
    } catch (e) {
      print("Error loading gallery: $e");
    }
  }
}
