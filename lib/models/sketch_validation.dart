import 'dart:ui';

class SketchValidation {
  final bool success;
  final List<Offset> trajectory;
  final String feedback;
  final String stylePrompt;
  final String objectType;
  final double quality;

  SketchValidation({
    required this.success,
    required this.trajectory,
    required this.feedback,
    required this.stylePrompt,
    this.objectType = '',
    this.quality = 0.0,
  });

  factory SketchValidation.fromJson(Map<String, dynamic> json) {
    var coords = json['coordenadas_trayectoria'] as List? ?? [];
    List<Offset> path = coords.map((point) {
      if (point is List && point.length >= 2) {
        // Assuming normalized coordinates 0.0-1.0 or pixel values
        // We'll treat them as relative 0.0-1.0 for now to be scalable
        return Offset((point[0] as num).toDouble(), (point[1] as num).toDouble());
      }
      return Offset.zero;
    }).toList();

    return SketchValidation(
      success: json['conectividad'] ?? false,
      trajectory: path,
      feedback: json['feedback'] ?? '', // Added feedback field for pedagogical response
      stylePrompt: json['style_prompt'] ?? '', // For Imagen 4
      objectType: json['tipo_objeto'] ?? '',
      quality: (json['calidad_trazo'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  String toString() {
    return 'SketchValidation(success: $success, object: $objectType, quality: $quality, points: ${trajectory.length})';
  }
}
