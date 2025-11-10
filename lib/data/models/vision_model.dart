import 'dart:convert';
import 'package:quest_on/domain/entities/vision.dart';

/// D x¸ pt0 ¨x
class VisionModel extends Vision {
  const VisionModel({
    required super.id,
    required super.userId,
    required super.answers,
    required super.visionNote,
    required super.createdAt,
    super.updatedAt,
  });

  /// Supabase JSONÐ ¨x Ý1
  factory VisionModel.fromJson(Map<String, dynamic> json) {
    return VisionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      answers: Map<String, String>.from(
        json['answers'] != null
            ? (json['answers'] is String
                ? jsonDecode(json['answers'] as String)
                : json['answers'])
            : {},
      ),
      visionNote: json['vision_note'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// ¨xD JSON<\ ÀX (INSERT©)
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'answers': jsonEncode(answers),
      'vision_note': visionNote,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// ¨xD JSON<\ ÀX (UPDATE©)
  Map<String, dynamic> toUpdateJson() {
    return {
      'answers': jsonEncode(answers),
      'vision_note': visionNote,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Ôðð\ ÀX
  Vision toEntity() {
    return Vision(
      id: id,
      userId: userId,
      answers: answers,
      visionNote: visionNote,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
