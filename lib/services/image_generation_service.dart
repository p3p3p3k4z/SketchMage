import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ImageGenerationService {
  // 2026 FIX: Unified Endpoint for Google AI SDK
  final String _url = "https://generativelanguage.googleapis.com/v1beta/models/imagen-3.0-fast-generate-001:predict";

  Future<Uint8List?> generate3DImage(String stylePrompt) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    
    if (apiKey == null || apiKey.isEmpty) {
      print("ERROR: GEMINI_API_KEY not found in .env");
      return null;
    }

    try {
      // Add key query parameter explicitly
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
            // Remove safetySetting here if you get 400 error, 
            // as some models handle it via header
          }
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        // Security check for Google response structure
        if (data.containsKey('predictions') && (data['predictions'] as List).isNotEmpty) {
          final String base64Image = data['predictions'][0]['bytesBase64Encoded'];
          return base64Decode(base64Image);
        } else {
          print("API responded 200 but without predictions: $data");
        }
      } else {
        // This will tell you exactly what is wrong (e.g. Quota exceeded or Format Error)
        print("Imagen API Error (${response.statusCode}): ${response.body}");
      }
    } catch (e) {
      print("Critical Error in ImageGenerationService: $e");
    }
    return null;
  }
}