import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'models/level.dart';
import 'models/transformation_result.dart';

/// Servicio principal que actúa como el "Backend" de IA para SketchMage.
/// Gestiona la comunicación con Gemini y la interpretación de los trazos físicos.
class SketchMageAIService {
  final String apiKey;
  late GenerativeModel _model;

  SketchMageAIService(this.apiKey) {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        temperature: 0.1, // Precisión sobre creatividad para validación motriz
      ),
    );
  }

  /// Pasarela Principal: Recibe la imagen del boceto y el contexto del nivel.
  /// Retorna un TransformationResult con la validación y el prompt de transformación.
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
      if (response.text == null) throw Exception('La IA no devolvió respuesta');
      
      final Map<String, dynamic> jsonResponse = jsonDecode(response.text!);
      return TransformationResult.fromJson(jsonResponse);
    } catch (e) {
      return TransformationResult(
        objectName: 'Error de Conexión',
        coordinates: [0, 0, 0, 0],
        stylePrompt: '',
        educationalFact: '',
        soundTag: 'error',
        isValid: false,
        feedback: 'La magia se interrumpió: $e',
      );
    }
  }

  String _buildLevelPrompt(Level level) {
    return '''
      ${level.systemPrompt}
      Estamos en el nivel: ${level.title}.
      Misión: ${level.mission}.
      
      Debes analizar el trazo del niño y responder ESTRICTAMENTE en JSON:
      {
        "object_name": "nombre del trazo (ej: puente, circulo)",
        "coordinates": [ymin, xmin, ymax, xmax],
        "isValid": bool (si cumple el objetivo del nivel),
        "feedback": "mensaje motivador o guía pedagógica",
        "style_prompt": "descripción para transformar este dibujo en un objeto 3D de alta calidad",
        "educational_fact": "dato sobre ${level.skill}",
        "sound_tag": "magic_sparkle"
      }
    ''';
  }

  String _buildCreativePrompt() {
    return '''
      Analiza este dibujo libre. Identifica el objeto y conviértelo en algo mágico.
      Responde en JSON:
      {
        "object_name": "nombre del objeto",
        "coordinates": [ymin, xmin, ymax, xmax],
        "style_prompt": "prompt detallado para generar este objeto en estilo 3D Pixar",
        "educational_fact": "un dato curioso sobre el objeto",
        "sound_tag": "object_sound",
        "isValid": true,
        "feedback": "¡Tu dibujo ha cobrado vida!"
      }
    ''';
  }
}
