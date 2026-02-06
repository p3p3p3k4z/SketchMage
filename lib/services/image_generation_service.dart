import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ImageGenerationService {
  // 2026 FIX: Endpoint unificado para Google AI SDK
  final String _url = "https://generativelanguage.googleapis.com/v1beta/models/imagen-3.0-fast-generate-001:predict";

  Future<Uint8List?> generate3DImage(String stylePrompt) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    
    if (apiKey == null || apiKey.isEmpty) {
      print("ERROR: GEMINI_API_KEY no encontrada en .env");
      return null;
    }

    try {
      // Agregamos el query parameter de la llave de forma explícita
      final uri = Uri.parse("$_url?key=$apiKey");

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "instances": [
            {
              "prompt": stylePrompt,
            }
          ],
          "parameters": {
            "sampleCount": 1,
            "aspectRatio": "1:1",
            // Eliminamos safetySetting aquí si te da error 400, 
            // ya que algunos modelos lo manejan por header
          }
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        // Verificación de seguridad de la estructura de respuesta de Google
        if (data.containsKey('predictions') && (data['predictions'] as List).isNotEmpty) {
          final String base64Image = data['predictions'][0]['bytesBase64Encoded'];
          return base64Decode(base64Image);
        } else {
          print("La API respondió 200 pero sin predicciones: $data");
        }
      } else {
        // Esto te dirá exactamente qué está mal (ej. Cuota excedida o Error de formato)
        print("Error Imagen API (${response.statusCode}): ${response.body}");
      }
    } catch (e) {
      print("Error crítico en ImageGenerationService: $e");
    }
    return null;
  }
}