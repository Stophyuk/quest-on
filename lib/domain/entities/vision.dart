import 'dart:convert';

/// 비전 노트 엔티티
///
/// 사용자의 꿈과 비전, 가치관 등을 담은 핵심 데이터
class Vision {
  final String id;
  final String userId;
  final Map<String, String> answers; // 9가지 질문에 대한 응답
  final String visionNote; // AI 생성 비전 노트
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Vision({
    required this.id,
    required this.userId,
    required this.answers,
    required this.visionNote,
    required this.createdAt,
    this.updatedAt,
  });

  /// 특정 질문에 대한 응답 가져오기
  String? getAnswer(VisionQuestion question) {
    return answers[question.key];
  }

  /// 모든 필수 질문에 답했는지 확인 (온보딩 완료 여부)
  bool get isComplete {
    return VisionQuestion.values
        .where((q) => !q.isOptional)
        .every((q) => answers[q.key]?.isNotEmpty == true);
  }

  /// 온보딩 진행률 (0.0 ~ 1.0) - 필수 질문 기준
  double get progress {
    final requiredQuestions = VisionQuestion.values.where((q) => !q.isOptional).toList();
    final answeredCount = requiredQuestions
        .where((q) => answers[q.key]?.isNotEmpty == true)
        .length;
    return answeredCount / requiredQuestions.length;
  }

  /// copyWith 메서드
  Vision copyWith({
    String? id,
    String? userId,
    Map<String, String>? answers,
    String? visionNote,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Vision(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      answers: answers ?? this.answers,
      visionNote: visionNote ?? this.visionNote,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Vision &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId;

  @override
  int get hashCode => id.hashCode ^ userId.hashCode;
}

/// 비전 질문 열거형
enum VisionQuestion {
  valuesQuestion('values', '당신이 가장 중요하게 생각하는 가치는 무엇인가요?', true),
  currentIdentity('currentIdentity', '지금의 당신을 한 문장으로 표현한다면?', false),
  futureIdentity('futureIdentity', '3년 후, 어떤 사람이 되어 있고 싶나요?', false),
  concern('concern', '요즘 가장 집중하고 싶은 주제나 고민은 무엇인가요?', false),
  routine('routine', '앞으로 만들고 싶은 새로운 습관은 무엇인가요?', false),
  motivation('motivation', '어떤 방식에서 가장 동기부여를 받나요?', true, true);

  const VisionQuestion(this.key, this.questionText, this.isKeywordType, [this.isOptional = false]);

  final String key;
  final String questionText;
  final bool isKeywordType; // 키워드 선택형 여부
  final bool isOptional; // 선택사항 여부

  /// 질문 번호 (1부터 시작)
  int get number => index + 1;

  /// 전체 질문 개수
  static int get totalCount => VisionQuestion.values.length;

  /// 필수 질문 개수
  static int get requiredCount => VisionQuestion.values.where((q) => !q.isOptional).length;
}

/// 가치관 키워드 옵션
class ValueKeywords {
  static const List<String> options = [
    '성장',
    '자유',
    '안정',
    '도전',
    '관계',
    '창의성',
    '성취',
    '균형',
    '배움',
    '기여',
    '독립',
    '열정',
  ];
}

/// 동기부여 방식 키워드 옵션
class MotivationKeywords {
  static const List<String> options = [
    '목표 달성',
    '칭찬과 인정',
    '경쟁과 비교',
    '보상',
    '성장 실감',
    '자기만족',
    '타인의 응원',
    '새로운 도전',
  ];
}
