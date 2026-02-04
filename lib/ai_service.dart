import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart'; // Import corregido

class SketchMageService {
  final String apiKey;
  late GenerativeModel _model;

  SketchMageService(this.apiKey) {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
    );
  }

  Future<Map<String, dynamic>> analyzeSketch(Uint8List imageBytes) async {
    final prompt = '''
      Actúa como un experto en visión artificial para niños. 
      Analiza este boceto y devuelve un objeto JSON con:
      1. "object_name": Nombre del objeto principal.
      2. "coordinates": [ymin, xmin, ymax, xmax] (normalizado 0-1000).
      3. "style_prompt": Un prompt descriptivo para generar una versión de plastilina 3D.
      4. "educational_fact": Un dato curioso corto sobre el objeto.
      5. "sound_tag": Una etiqueta simple para el sonido (ej: "dog_bark", "car_vroom").
      
      Responde solo el JSON.
    ''';

    final content = [
      Content.multi([TextPart(prompt), DataPart('image/jpeg', imageBytes)]),
    ];

    try {
      final response = await _model.generateContent(content);
      if (response.text == null) return {'error': 'Respuesta vacía de la IA'};
      return jsonDecode(response.text!);
    } catch (e) {
      return {'error': 'Error procesando la imagen: $e'};
    }
  }
}
