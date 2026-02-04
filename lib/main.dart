import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() {
  runApp(const SketchMageApp());
}

class SketchMageApp extends StatelessWidget {
  const SketchMageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SketchMage Lab',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SketchMageHomePage(),
    );
  }
}

class SketchMageHomePage extends StatefulWidget {
  const SketchMageHomePage({super.key});

  @override
  State<SketchMageHomePage> createState() => _SketchMageHomePageState();
}

class _SketchMageHomePageState extends State<SketchMageHomePage> {
  // CONFIGURACIÓN: Pon tu API Key aquí para probar
  final String _apiKey = 'TU_API_KEY_AQUI';

  Uint8List? _imageBytes;
  Map<String, dynamic>? _analysisResult;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  // --- SERVICIO DE IA (Lógica de Persona A) ---
  Future<void> _analyzeSketch() async {
    if (_imageBytes == null) return;

    setState(() {
      _isLoading = true;
      _analysisResult = null;
    });

    try {
      // Usamos Gemini 1.5 Flash (actualizar a 3.0 cuando esté disponible en SDK)
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
        ),
      );

      final prompt = '''
        Analiza este boceto infantil. Responde estrictamente en JSON con este formato:
        {
          "object_name": "nombre del objeto",
          "coordinates": [ymin, xmin, ymax, xmax],
          "educational_fact": "dato curioso corto",
          "sound_tag": "onomatopeya",
          "style_prompt": "descripción para generar imagen 3D"
        }
      ''';

      final content = [
        Content.multi([TextPart(prompt), DataPart('image/jpeg', _imageBytes!)]),
      ];

      final response = await model.generateContent(content);
      setState(() {
        _analysisResult = jsonDecode(response.text ?? '{}');
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --- INTERFAZ DE USUARIO ---
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _analysisResult = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧙‍♂️ SketchMage: AI Lab'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Área de previsualización de la imagen
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey),
              ),
              child: _imageBytes != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(_imageBytes!, fit: BoxFit.contain),
                    )
                  : const Center(child: Text('Selecciona un boceto')),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Cargar Dibujo'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (_imageBytes != null && !_isLoading)
                        ? _analyzeSketch
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('¡Dar Vida!'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_analysisResult != null)
              _buildResultCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '✨ Resultado de la "Magia":',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            _infoRow('Objeto:', _analysisResult!['object_name']),
            _infoRow('Dato Curioso:', _analysisResult!['educational_fact']),
            _infoRow('Sonido:', _analysisResult!['sound_tag']),
            const SizedBox(height: 8),
            Text(
              'Prompt para Imagen 4:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            Text(
              _analysisResult!['style_prompt'] ?? 'N/A',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 16),
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value?.toString() ?? 'Analizando...'),
          ],
        ),
      ),
    );
  }
}
