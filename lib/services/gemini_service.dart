import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/level.dart';
import '../models/transformation_result.dart';

class GeminiService {
  final String apiKey;
  late GenerativeModel _model;

  GeminiService(this.apiKey) {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        temperature: 0.1, // Baja temperatura para respuestas más deterministas en validación
      ),
    );
  }

  /// Procesa un boceto en el contexto de un nivel específico (Modo Aventura)
  Future<TransformationResult> validateLevelSketch(Uint8List imageBytes, Level level) async {
    final prompt = '''
      ${level.systemPrompt}
      
      Contexto adicional: Estamos en el nivel "${level.title}".
      El objetivo es: ${level.mission}.
      
      Debes retornar estrictamente un JSON con:
      {
        "object_name": "nombre del trazo detectado",
        "coordinates": [ymin, xmin, ymax, xmax],
        "isValid": bool (si cumple con la misión del nivel),
        "feedback": "mensaje para el niño si falló o lo hizo bien",
        "style_prompt": "descripción visual para transformar este trazo en un objeto de ${level.skill}",
        "educational_fact": "dato curioso sobre la habilidad ${level.skill}",
        "sound_tag": "efecto_magico"
      }
    ''';

    return _generateAndParse(imageBytes, prompt);
  }

  /// Procesa un boceto libre (Modo Creativo)
  Future<TransformationResult> analyzeCreativeSketch(Uint8List imageBytes) async {
    const prompt = '''
      Analiza este dibujo libre de un niño.
      Identifica el objeto principal y conviértelo en algo mágico.
      
      Retorna un JSON con:
      {
        "object_name": "nombre del objeto",
        "coordinates": [ymin, xmin, ymax, xmax],
        "style_prompt": "un prompt detallado para generar este objeto con un estilo de arte digital 3D brillante",
        "educational_fact": "un dato curioso sobre lo que el niño dibujó",
        "sound_tag": "nombre_del_sonido_del_objeto",
        "isValid": true,
        "feedback": "¡Qué increíble dibujo!"
      }
    ''';

    return _generateAndParse(imageBytes, prompt);
  }

  Future<TransformationResult> _generateAndParse(Uint8List imageBytes, String prompt) async {
    final content = [
      Content.multi([TextPart(prompt), DataPart('image/jpeg', imageBytes)]),
    ];

    try {
      final response = await _model.generateContent(content);
      if (response.text == null) {
        throw Exception('Respuesta vacía de Gemini');
      }
      final jsonResponse = jsonDecode(response.text!);
      return TransformationResult.fromJson(jsonResponse);
    } catch (e) {
      return TransformationResult(
        objectName: 'Error',
        coordinates: [0,0,0,0],
        style_prompt: '',
        educational_fact: '',
        sound_tag: 'error',
        isValid: false,
        feedback: 'Hubo un problema al conectar con la magia: $e'
      );
    }
  }
}
