import 'dart:convert';
import 'package:flutter/services.dart';

class LevelConfig {
  final int id;
  final String title;
  final String mission;
  final String validationCriteria;
  final String successFeedback;
  final String failureFeedback;
  final String stylePromptTemplate;

  LevelConfig({
    required this.id,
    required this.title,
    required this.mission,
    required this.validationCriteria,
    required this.successFeedback,
    required this.failureFeedback,
    required this.stylePromptTemplate,
  });

  factory LevelConfig.fromJson(Map<String, dynamic> json) {
    return LevelConfig(
      id: json['id'],
      title: json['title'],
      mission: json['mission'],
      validationCriteria: json['validation_criteria'],
      successFeedback: json['success_feedback'],
      failureFeedback: json['failure_feedback'],
      stylePromptTemplate: json['style_prompt_template'],
    );
  }
}

class AppConfig {
  final List<LevelConfig> levels;
  final List<String> styles;

  AppConfig({required this.levels, required this.styles});

  static Future<AppConfig> load() async {
    final jsonString = await rootBundle.loadString('assets/data/app_config.json');
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    
    final levels = (jsonMap['levels'] as List)
        .map((l) => LevelConfig.fromJson(l))
        .toList();
        
    final styles = List<String>.from(jsonMap['styles']);

    return AppConfig(levels: levels, styles: styles);
  }
}
