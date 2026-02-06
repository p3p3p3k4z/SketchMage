import 'dart:convert';
import 'dart:ui';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cross_file/cross_file.dart';
import '../models/sketch_validation.dart';
import '../models/app_config.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  late final GenerativeModel _model; // Keeping this for backward compatibility if needed, but we use dynamic models now
  
  GeminiService() {
   // Constructor logic mainly for initialization verification
   final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      print("CRITIAL: GEMINI_API_KEY is missing in .env");
      throw Exception("GEMINI_API_KEY is missing. Please check .env file.");
    }
    print("GeminiService: Ready (Key present)");
    
    // Initialize a default model just in case
    _model = GenerativeModel(
      model: 'gemini-3.0-flash', // Available in your dashboard
      apiKey: apiKey,
    );
  }

  GenerativeModel _getModelForLevel(int levelId, String apiKey) {
    // Model Selection based on your AI Studio Dashboard:
    // Available: Gemini 3 Flash (5 RPM), Gemini 2.5 Flash (5 RPM)
    // 
    // Levels 1-5 (Validation) -> gemini-3.0-flash (Newest, Fast)
    // Creative Mode -> gemini-2.5-flash (Alternative, balanced)
    
    String modelName;
    if (levelId >= 1 && levelId <= 5) {
      modelName = 'gemini-3.0-flash'; 
    } else {
      modelName = 'gemini-2.5-flash'; 
    }

    print("GeminiService: Using model $modelName for Level $levelId");

    return GenerativeModel(
      model: modelName,
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
      ),
    );
  }

  String _getSystemPrompt(LevelConfig levelConfig) {
    // Hemos refinado el prompt para que el style_prompt sea óptimo para Imagen 4
    const String basePrompt = """
    Rol: Eres SketchMage, un experto en visión artificial y diseño 3D para niños.
    Tu misión es analizar bocetos a lápiz y validarlos según el nivel.
    
    IMPORTANTE PARA EL CAMPO 'style_prompt': 
    Debes generar un prompt descriptivo en inglés para un modelo de generación de imágenes. 
    El estilo DEBE SER: "3D claymation style, cute toy aesthetic, soft studio lighting, vibrant colors, high resolution, octane render, isometric view".
    Describe el objeto detectado con ese estilo. Ej: "A cute 3D clay figurine of a [objeto], toy style..."
    
    Salida JSON requerida:
    {
      "tipo_objeto": "string",
      "calidad_trazo": number,
      "conectividad": boolean,
      "coordenadas_trayectoria": [[x,y]], 
      "feedback": "string",
      "style_prompt": "string descriptivo en inglés"
    }
    """;

    return """
    $basePrompt
    Nivel ${levelConfig.id}: ${levelConfig.title}.
    Misión: ${levelConfig.mission}.
    Validación: ${levelConfig.validationCriteria}.
    Style Prompt Template: ${levelConfig.stylePromptTemplate}
    """;
  }

  Future<SketchValidation> validateSketch(XFile imageFile, LevelConfig levelConfig, {String? selectedStyle}) async {
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY']!.trim();
      final model = _getModelForLevel(levelConfig.id, apiKey);
      
      var prompt = _getSystemPrompt(levelConfig);
      
      // Inject selected style if present
      if (selectedStyle != null && selectedStyle.isNotEmpty) {
        prompt += "\n\nUser Selected Style: $selectedStyle. Please ensure the 'style_prompt' output uses this style.";
      }

      final imageBytes = await imageFile.readAsBytes();
      
      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await model.generateContent(content);
      
      if (response.text == null) {
        throw Exception("Empty response from Gemini");
      }

      // Cleanup potential markdown formatting if model output wraps json code block
      String cleanJson = response.text!.replaceAll('```json', '').replaceAll('```', '').trim();
      
      final Map<String, dynamic> jsonResponse = jsonDecode(cleanJson);
      return SketchValidation.fromJson(jsonResponse);
      
    } catch (e, stackTrace) {
      print("Gemini Validation Error: $e");
      
      String errorMsg = "Error de conexión mágica: $e";
      if (e.toString().contains('429') || e.toString().contains('Quota')) {
        errorMsg = "¡Demasiada magia! (Límite de 5 intentos/min alcanzado). Espera un momento.";
      }
      
      return SketchValidation(
        success: false,
        trajectory: [],
        feedback: errorMsg,
        stylePrompt: "",
      );
    }
  }
}
