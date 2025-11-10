import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// OpenAI GPT-4o-mini를 활용한 AI 서비스
///
/// 비전 노트 생성, 목표 트리 생성, 퀘스트 추천, 회고 코칭 메시지 생성 기능 제공
class OpenAIService {
  static final OpenAIService _instance = OpenAIService._internal();
  factory OpenAIService() => _instance;
  OpenAIService._internal();

  bool _initialized = false;

  /// OpenAI API 초기화
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // .env 파일에서 API 키 로드
      final apiKey = dotenv.env['OPENAI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('OPENAI_API_KEY가 .env 파일에 설정되지 않았습니다.');
      }

      OpenAI.apiKey = apiKey;
      OpenAI.showLogs = kDebugMode;
      _initialized = true;

      if (kDebugMode) {
        print('[OpenAI] API 초기화 완료');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[OpenAI] 초기화 실패: $e');
      }
      rethrow;
    }
  }

  /// 1. 비전 노트 생성
  ///
  /// 사용자의 9가지 질문 응답을 바탕으로 비전 노트를 생성합니다.
  Future<String> generateVisionNote(Map<String, String> answers) async {
    if (!_initialized) {
      throw Exception('OpenAI API가 초기화되지 않았습니다.');
    }

    try {
      final prompt = _buildVisionNotePrompt(answers);

      final response = await OpenAI.instance.chat.create(
        model: 'gpt-4o-mini',
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.system,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                '당신은 진로 상담 전문가입니다. 사용자의 꿈과 비전을 명확하게 정리해주고, 그들의 미래 모습을 구체적으로 그려주세요.',
              ),
            ],
          ),
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt),
            ],
          ),
        ],
        temperature: 0.7,
        maxTokens: 1000,
      );

      final visionNote = response.choices.first.message.content?.first.text ?? '';

      if (kDebugMode) {
        print('[OpenAI] 비전 노트 생성 완료 (${visionNote.length}자)');
      }

      return visionNote;
    } catch (e) {
      if (kDebugMode) {
        print('[OpenAI] 비전 노트 생성 실패: $e');
      }
      throw Exception('비전 노트 생성 중 오류가 발생했습니다: $e');
    }
  }

  /// 2. 목표 트리 생성
  ///
  /// 비전 노트를 바탕으로 계층적 목표 트리를 생성합니다.
  Future<Map<String, dynamic>> generateGoalTree(String visionNote) async {
    if (!_initialized) {
      throw Exception('OpenAI API가 초기화되지 않았습니다.');
    }

    try {
      final prompt = _buildGoalTreePrompt(visionNote);

      final response = await OpenAI.instance.chat.create(
        model: 'gpt-4o-mini',
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.system,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                '당신은 목표 설정 전문가입니다. 사용자의 비전을 달성할 수 있는 구체적이고 실행 가능한 목표를 제시하세요.',
              ),
            ],
          ),
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt),
            ],
          ),
        ],
        temperature: 0.8,
        maxTokens: 800,
      );

      final goalTreeJson = response.choices.first.message.content?.first.text ?? '{}';

      if (kDebugMode) {
        print('[OpenAI] 목표 트리 생성 완료');
      }

      // JSON 파싱 (현재는 raw 응답만 반환)
      // TODO: 실제 JSON 파싱 로직 추가
      return {'raw': goalTreeJson};
    } catch (e) {
      if (kDebugMode) {
        print('[OpenAI] 목표 트리 생성 실패: $e');
      }
      throw Exception('목표 트리 생성 중 오류가 발생했습니다: $e');
    }
  }

  /// 3. 일일 퀘스트 추천
  ///
  /// 목표 트리와 사용자 레벨을 고려한 맞춤형 퀘스트를 추천합니다.
  Future<List<Map<String, dynamic>>> recommendDailyQuests({
    required String visionNote,
    required Map<String, dynamic> goalTree,
    required int userLevel,
    int count = 3,
  }) async {
    if (!_initialized) {
      throw Exception('OpenAI API가 초기화되지 않았습니다.');
    }

    try {
      final prompt = _buildQuestRecommendationPrompt(
        visionNote: visionNote,
        goalTree: goalTree,
        userLevel: userLevel,
        count: count,
      );

      final response = await OpenAI.instance.chat.create(
        model: 'gpt-4o-mini',
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.system,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                '당신은 일일 목표 설정 코치입니다. 사용자의 현재 수준에 맞는 구체적이고 실행 가능한 퀘스트를 제안하세요.',
              ),
            ],
          ),
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt),
            ],
          ),
        ],
        temperature: 0.9,
        maxTokens: 500,
      );

      final questsJson = response.choices.first.message.content?.first.text ?? '[]';

      if (kDebugMode) {
        print('[OpenAI] 퀘스트 $count개 추천 완료');
      }

      // TODO: JSON 파싱하여 List<Map<String, dynamic>> 변환
      return [
        {'title': '샘플 퀘스트 1', 'description': '설명', 'priority': 10},
      ];
    } catch (e) {
      if (kDebugMode) {
        print('[OpenAI] 퀘스트 추천 실패: $e');
      }
      throw Exception('퀘스트 추천 중 오류가 발생했습니다: $e');
    }
  }

  /// 4. 회고 코칭 메시지 생성
  ///
  /// 주간/월간 회고 결과를 바탕으로 AI 코칭 메시지를 생성합니다.
  Future<String> generateCoachingMessage({
    required String visionNote,
    required double achievementRate,
    required int totalQuests,
    required int completedQuests,
    required String userThoughts,
  }) async {
    if (!_initialized) {
      throw Exception('OpenAI API가 초기화되지 않았습니다.');
    }

    try {
      final prompt = _buildCoachingMessagePrompt(
        visionNote: visionNote,
        achievementRate: achievementRate,
        totalQuests: totalQuests,
        completedQuests: completedQuests,
        userThoughts: userThoughts,
      );

      final response = await OpenAI.instance.chat.create(
        model: 'gpt-4o-mini',
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.system,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                '당신은 따뜻하고 격려하는 상담 전문가입니다. 사용자의 노력을 인정하고, 앞으로 나아갈 방향을 제시하세요.',
              ),
            ],
          ),
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt),
            ],
          ),
        ],
        temperature: 0.8,
        maxTokens: 600,
      );

      final coachingMessage = response.choices.first.message.content?.first.text ?? '';

      if (kDebugMode) {
        print('[OpenAI] 코칭 메시지 생성 완료 (${coachingMessage.length}자)');
      }

      return coachingMessage;
    } catch (e) {
      if (kDebugMode) {
        print('[OpenAI] 코칭 메시지 생성 실패: $e');
      }
      throw Exception('코칭 메시지 생성 중 오류가 발생했습니다: $e');
    }
  }

  // ==================== 프롬프트 빌더 메서드 ====================

  String _buildVisionNotePrompt(Map<String, String> answers) {
    final values = answers['values'] ?? '미입력';
    final currentIdentity = answers['currentIdentity'] ?? '미입력';
    final futureIdentity = answers['futureIdentity'] ?? '미입력';
    final concern = answers['concern'] ?? '미입력';
    final routine = answers['routine'] ?? '미입력';
    final motivation = answers['motivation'] ?? '';

    return '''
사용자가 작성한 응답을 바탕으로 영감을 주는 비전 노트를 생성해주세요.

응답:
1. 가장 중요한 가치: $values
2. 지금의 나: $currentIdentity
3. 3년 후의 나: $futureIdentity
4. 집중하고 싶은 주제/고민: $concern
5. 만들고 싶은 습관: $routine
${motivation.isNotEmpty ? '6. 동기부여 방식: $motivation' : ''}

아래 구조로 비전 노트를 생성해주세요:

# 당신이 중요하게 여기는 가치
(사용자가 선택한 가치관을 바탕으로 2-3줄로 요약)

# 지금의 당신, 그리고 미래
(현재 모습과 3년 후 되고 싶은 모습을 연결하여 정리)

# 당신이 집중할 방향
(집중하고 싶은 주제와 고민을 바탕으로 성장 방향 제시)

# 성장을 위한 첫 걸음
(만들고 싶은 습관을 바탕으로 구체적인 실천 방법 제안)

친근하고 격려하는 어조로 작성하되, 400-600자 분량으로 작성해주세요. 따뜻하고 격려하는 톤으로 작성해주세요.
''';
  }

  String _buildGoalTreePrompt(String visionNote) {
    return '''
아래 비전 노트를 바탕으로 계층적 목표 트리를 생성해주세요.

비전 노트:
$visionNote

아래 구조로 JSON 형식을 생성해주세요:

{
  "longTermGoals": [
    {"title": "1-3년 목표 1", "description": "설명"},
    {"title": "1-3년 목표 2", "description": "설명"}
  ],
  "midTermGoals": [
    {"title": "3-6개월 목표 1", "description": "설명"},
    {"title": "3-6개월 목표 2", "description": "설명"}
  ],
  "shortTermGoals": [
    {"title": "1개월 목표 1", "description": "설명"},
    {"title": "1개월 목표 2", "description": "설명"}
  ]
}

각 단계별로 2-3개의 목표를 추천해주세요.
''';
  }

  String _buildQuestRecommendationPrompt({
    required String visionNote,
    required Map<String, dynamic> goalTree,
    required int userLevel,
    required int count,
  }) {
    final goalTreeStr = goalTree.toString();
    return '''
아래 정보를 바탕으로 맞춤형 일일 퀘스트 $count개를 추천해주세요.

비전 노트:
$visionNote

목표 트리:
$goalTreeStr

사용자 레벨: Lv.$userLevel

아래 구조로 JSON 배열을 생성해주세요:

[
  {
    "title": "퀘스트 제목",
    "description": "구체적인 설명",
    "category": "카테고리",
    "difficulty": 1-5,
    "priority": 1-10,
    "estimatedTime": "예상 소요 시간(분)"
  }
]

- 목표를 달성하는데 도움이 되는 퀘스트를 추천하세요
- 사용자 레벨에 맞는 난이도로 설정하세요
- 사용자가 레벨이 낮으면 쉬운 퀘스트를, 높으면 어려운 퀘스트를 추천하세요
- 구체적이고 실행 가능한 퀘스트를 제시하세요
''';
  }

  String _buildCoachingMessagePrompt({
    required String visionNote,
    required double achievementRate,
    required int totalQuests,
    required int completedQuests,
    required String userThoughts,
  }) {
    final rateStr = achievementRate.toStringAsFixed(1);
    return '''
아래 정보를 바탕으로 따뜻하고 격려하는 코칭 메시지를 생성해주세요.

비전:
$visionNote

최근 성과 요약:
- 달성률: $rateStr%
- 완료: $completedQuests / $totalQuests

사용자 소회:
$userThoughts

아래 내용을 포함해주세요:
1. 노력에 대한 인정과 칭찬
2. 목표 달성을 위한 격려
3. 앞으로 나아갈 방향 제시
4. 아래 주에 도전할 과제 제안

친근하고 격려하는 어조로 200-300자 분량으로 작성해주세요.
''';
  }
}
