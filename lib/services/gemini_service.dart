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
    // Refined prompt to optimize style_prompt for Image Generation
    const String basePrompt = """
    Role: You are SketchMage, an expert in computer vision and 3D design for children.
    Your mission is to analyze pencil sketches and validate them according to the level criteria.
    
    IMPORTANT FOR 'style_prompt' FIELD: 
    You MUST generate a descriptive English prompt for an image generation model. 
    The style MUST BE: "3D claymation style, cute toy aesthetic, soft studio lighting, vibrant colors, high resolution, octane render, isometric view".
    Describe the detected object with that style. Ex: "A cute 3D clay figurine of a [object], toy style..."
    
    Required JSON Output:
    {
      "tipo_objeto": "string", // Keep json keys as is if backend expects specific keys, but assuming we can change or just values? The user asked to translate code. I will translate keys if they are not strictly bound, but 'tipo_objeto' matches the model. I will translate descriptions.
      "calidad_trazo": number,
      "conectividad": boolean,
      "coordenadas_trayectoria": [[x,y]], 
      "feedback": "string (Valid English feedback)",
      "style_prompt": "Descriptive string in English"
    }
    """;

    return """
    $basePrompt
    Level ${levelConfig.id}: ${levelConfig.title}.
    Mission: ${levelConfig.mission}.
    Validation: ${levelConfig.validationCriteria}.
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
      
      String errorMsg = "Magic connection error: $e";
      if (e.toString().contains('429') || e.toString().contains('Quota')) {
        errorMsg = "Too much magic! (Limit of 5 attempts/min reached). Please wait a moment.";
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
