import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'models/level.dart';
import 'models/transformation_result.dart';

/// Main Service acting as the "Backend" AI for SketchMage.
/// Manages communication with Gemini and interpretation of physical sketches.
class SketchMageAIService {
  final String apiKey;
  late GenerativeModel _model;

  SketchMageAIService(this.apiKey) {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        temperature: 0.1, // Precision over creativity for motor validation
      ),
    );
  }

  /// Main Gateway: Receives the sketch image and level context.
  /// Returns a TransformationResult with validation and transformation prompt.
  Future<TransformationResult> transformSketch({
    required Uint8List imageBytes,
    Level? currentLevel,
  }) async {
    final String prompt = currentLevel != null 
      ? _buildLevelPrompt(currentLevel) 
      : _buildCreativePrompt();

    final content = [
      Content.multi([
        TextPart(prompt),
        DataPart('image/jpeg', imageBytes),
      ]),
    ];

    try {
      final response = await _model.generateContent(content);
      if (response.text == null) throw Exception('AI did not return a response');
      
      final Map<String, dynamic> jsonResponse = jsonDecode(response.text!);
      return TransformationResult.fromJson(jsonResponse);
    } catch (e) {
      return TransformationResult(
        objectName: 'Connection Error',
        coordinates: [0, 0, 0, 0],
        stylePrompt: '',
        educationalFact: '',
        soundTag: 'error',
        isValid: false,
        feedback: 'The magic was interrupted: $e',
      );
    }
  }

  String _buildLevelPrompt(Level level) {
    return '''
      ${level.systemPrompt}
      We are at level: ${level.title}.
      Mission: ${level.mission}.
      
      You must analyze the child's sketch and respond STRICTLY in JSON:
      {
        "object_name": "sketch name (e.g., bridge, circle)",
        "coordinates": [ymin, xmin, ymax, xmax],
        "isValid": bool (if it meets the level objective),
        "feedback": "motivational message or original pedagogical guide",
        "style_prompt": "description to transform this drawing into a high quality 3D object",
        "educational_fact": "fact about ${level.skill}",
        "sound_tag": "magic_sparkle"
      }
    ''';
  }

  String _buildCreativePrompt() {
    return '''
      Analyze this free drawing. Identify the object and turn it into something magical.
      Respond in JSON:
      {
        "object_name": "object name",
        "coordinates": [ymin, xmin, ymax, xmax],
        "style_prompt": "detailed prompt to generate this object in 3D Pixar style",
        "educational_fact": "a fun fact about the object",
        "sound_tag": "object_sound",
        "isValid": true,
        "feedback": "Your drawing has come to life!"
      }
    ''';
  }
}
