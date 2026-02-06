import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();

  TtsService() {
    _init();
  }

  Future<void> _init() async {
    // Default setup
    await _flutterTts.setLanguage("en-US"); 
    await _flutterTts.setPitch(1.1); // Slightly higher pitch for a "magical" helper feel
    await _flutterTts.setSpeechRate(0.5); // Normal speed
    await _flutterTts.setVolume(1.0);
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    try {
      await _flutterTts.stop(); // Stop potential previous speech
      await _flutterTts.speak(text);
    } catch (e) {
      print("TTS Error: $e");
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      print("TTS Stop Error: $e");
    }
  }
}
