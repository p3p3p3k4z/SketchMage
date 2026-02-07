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
    var coords = json['trajectory_coordinates'] as List? ?? json['coordenadas_trayectoria'] as List? ?? [];
    List<Offset> path = coords.map((point) {
      if (point is List && point.length >= 2) {
        return Offset((point[0] as num).toDouble(), (point[1] as num).toDouble());
      }
      return Offset.zero;
    }).toList();

    return SketchValidation(
      success: json['connectivity'] ?? json['conectividad'] ?? false,
      trajectory: path,
      feedback: json['feedback'] ?? '',
      stylePrompt: json['style_prompt'] ?? '',
      objectType: json['object_type'] ?? json['tipo_objeto'] ?? '',
      quality: (json['trazo_quality'] as num?)?.toDouble() ?? (json['calidad_trazo'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  String toString() {
    return 'SketchValidation(success: $success, object: $objectType, quality: $quality, points: ${trajectory.length})';
  }
}
