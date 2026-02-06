class TransformationResult {
  final String objectName;
  final List<int> coordinates; // [ymin, xmin, ymax, xmax]
  final String stylePrompt;
  final String educationalFact;
  final String soundTag;
  final bool isValid;
  final String? feedback;

  TransformationResult({
    required this.objectName,
    required this.coordinates,
    required this.stylePrompt,
    required this.educationalFact,
    required this.soundTag,
    this.isValid = true,
    this.feedback,
  });

  factory TransformationResult.fromJson(Map<String, dynamic> json) {
    return TransformationResult(
      objectName: json['object_name'] ?? 'Objeto desconocido',
      coordinates: List<int>.from(json['coordinates'] ?? [0, 0, 0, 0]),
      stylePrompt: json['style_prompt'] ?? '',
      educationalFact: json['educational_fact'] ?? '',
      soundTag: json['sound_tag'] ?? 'magic',
      isValid: json['isValid'] ?? true,
      feedback: json['feedback'],
    );
  }
}
