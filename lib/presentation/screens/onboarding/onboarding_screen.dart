import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quest_on/core/theme/app_theme.dart';
import 'package:quest_on/core/constants/app_constants.dart';
import 'package:quest_on/domain/entities/quest.dart';
import 'package:quest_on/presentation/providers/auth_provider.dart';
import 'package:quest_on/presentation/providers/user_stats_provider.dart';
import 'package:quest_on/presentation/providers/vision_provider.dart';
import 'package:quest_on/presentation/providers/quest_provider.dart';

/// 통합 온보딩 화면 (캐릭터 + 닉네임 + 비전 설문 + AI 코칭 + 로드맵)
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  // 현재 사용자 ID (온보딩 완료 시 UserStats 생성에 사용)
  String? _userId;

  // Step 1: 캐릭터 선택
  String? _selectedCharacter;
  final List<Map<String, String>> _characters = [
    {'emoji': '🐰', 'name': '토끼'},
    {'emoji': '🐻', 'name': '곰'},
    {'emoji': '🐱', 'name': '고양이'},
    {'emoji': '🦊', 'name': '여우'},
  ];

  // Step 2: 닉네임
  final _nicknameController = TextEditingController();

  // Step 3: 가치관
  final List<String> _selectedValues = [];
  final List<String> _valueOptions = [
    '성장',
    '관계',
    '건강',
    '자유',
    '성취',
    '안정',
    '창의성',
    '기여',
  ];

  // Step 4: 목표
  final _goalController = TextEditingController();
  final _goalDeadlineController = TextEditingController();
  final _goalMeasurementController = TextEditingController();

  // Step 5: 이유
  final List<String> _selectedReasons = [];
  final _customReasonController = TextEditingController();

  // Step 2: 가치 - 커스텀 입력
  final _customValueController = TextEditingController();
  final List<String> _reasonOptions = [
    '자기계발',
    '경력 발전',
    '건강 개선',
    '관계 개선',
    '재정 안정',
    '행복 추구',
    '사회 기여',
    '자아실현',
  ];

  // Step 6-7: AI 생성 결과
  String? _visionNote;
  Map<String, dynamic>? _goalTree;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 현재 로그인된 사용자 ID 추출 (최초 1회만)
    if (_userId == null) {
      final user = ref.read(authStateProvider).value;
      if (user != null) {
        _userId = user.id;
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nicknameController.dispose();
    _goalController.dispose();
    _goalDeadlineController.dispose();
    _goalMeasurementController.dispose();
    _customReasonController.dispose();
    _customValueController.dispose();
    super.dispose();
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _selectedCharacter != null;
      case 1:
        final nickname = _nicknameController.text.trim();
        return nickname.length >= 2 && nickname.length <= 10;
      case 2:
        return _selectedValues.length >= 1 && _selectedValues.length <= 3;
      case 3:
        return _goalController.text.trim().isNotEmpty;
      case 4:
        return _selectedReasons.length >= 1 && _selectedReasons.length <= 3;
      default:
        return true;
    }
  }

  void _nextStep() {
    if (_currentStep < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    } else if (_currentStep == 4) {
      _generateVisionAndRoadmap();
    }
  }

  void _prevStep() {
    if (_currentStep > 0 && _currentStep < 5) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    }
  }

  Future<void> _generateVisionAndRoadmap() async {
    // 입력 내용 검증
    final goal = _goalController.text.trim();
    final validationError = _validateInput(goal);
    if (validationError != null) {
      setState(() {
        _error = validationError;
        _currentStep = 5; // 에러 화면으로 이동
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _currentStep = 5; // AI 생성 화면으로 이동
    });

    // 회원가입에서 전달받은 userId 사용
    if (_userId == null) {
      setState(() {
        _error = '사용자 정보를 찾을 수 없습니다';
        _isLoading = false;
      });
      return;
    }

    try {
      // 1. Vision Profile 생성 (UserStats는 마지막에 생성)
      await ref.read(visionNotifierProvider.notifier).createProfile(
            userId: _userId!,
            name: _nicknameController.text.trim(),
            values: _selectedValues,
            goal: goal,
            reasons: _selectedReasons,
          );

      // 2. AI 코칭 노트 생성
      _visionNote =
          await ref.read(visionNotifierProvider.notifier).generateVisionNote();

      setState(() {
        _currentStep = 6; // 코칭 완료 화면
      });

      // 잠시 대기 후 로드맵 생성
      await Future.delayed(const Duration(seconds: 2));

      // 3. 로드맵 생성
      _goalTree =
          await ref.read(visionNotifierProvider.notifier).generateGoalTree();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        // 사용자 친화적인 에러 메시지로 변환
        String errorMessage = _getUserFriendlyErrorMessage(e.toString());
        setState(() {
          _error = errorMessage;
          _isLoading = false;
        });
      }
    }
  }

  /// 입력 내용 검증
  String? _validateInput(String goal) {
    // 목표 길이 체크 (최소 10자)
    if (goal.length < 10) {
      return '💡 목표를 더 구체적으로 작성해주세요!\n\n'
          '현재: ${goal.length}자\n'
          '최소: 10자 이상\n\n'
          '예시: "6개월 안에 건강한 식습관을 만들고 10kg 감량하기"';
    }

    // 가치 선택 체크 (최소 2개)
    if (_selectedValues.length < 2) {
      return '💡 가치를 더 선택해주세요!\n\n'
          '현재: ${_selectedValues.length}개\n'
          '최소: 2개 이상\n\n'
          '더 많은 가치를 선택하면 AI가 당신의 성향을 더 잘 이해할 수 있어요.';
    }

    // 이유 선택 체크 (최소 2개)
    if (_selectedReasons.length < 2) {
      return '💡 목표를 이루고 싶은 이유를 더 선택해주세요!\n\n'
          '현재: ${_selectedReasons.length}개\n'
          '최소: 2개 이상\n\n'
          '구체적인 동기가 있어야 AI가 더 효과적인 코칭을 제공할 수 있어요.';
    }

    return null;
  }

  /// 사용자 친화적인 에러 메시지 생성
  String _getUserFriendlyErrorMessage(String error) {
    // Exception: 접두사 제거
    String cleanError = error;
    if (cleanError.startsWith('Exception: ')) {
      cleanError = cleanError.substring(11);
    }

    // 네트워크 관련 에러
    if (cleanError.contains('NetworkException') ||
        cleanError.contains('SocketException') ||
        cleanError.contains('TimeoutException')) {
      return '🌐 인터넷 연결을 확인해주세요\n\n'
          '네트워크 연결이 불안정하거나 서버에 접속할 수 없습니다.\n\n'
          '해결 방법:\n'
          '• Wi-Fi 또는 데이터 연결 확인\n'
          '• 잠시 후 다시 시도';
    }

    // AI 생성 관련 에러
    if (cleanError.contains('AI') || cleanError.contains('generate')) {
      return '🤖 AI 분석 중 문제가 발생했습니다\n\n'
          '입력하신 내용을 AI가 분석하는 중 오류가 발생했습니다.\n\n'
          '해결 방법:\n'
          '• 목표를 더 명확하게 작성\n'
          '• 가치와 이유를 더 많이 선택\n'
          '• 다시 시도 버튼 클릭';
    }

    // 기본 에러 메시지
    return '⚠️ 일시적인 문제가 발생했습니다\n\n'
        '$cleanError\n\n'
        '잠시 후 다시 시도해주세요.';
  }

  Future<void> _complete() async {
    try {
      // CRITICAL: UserStats를 여기서 생성 또는 로드하고 상태 확인
      try {
        await ref.read(userStatsNotifierProvider.notifier).createUserStats(
              userId: _userId!,
              nickname: _nicknameController.text.trim(),
              character: _selectedCharacter!,
            );
      } catch (e) {
        // 409 Conflict (이미 존재) 시 기존 데이터 로드
        if (e.toString().contains('409') || e.toString().contains('already exists')) {
          await ref.read(userStatsNotifierProvider.notifier).loadUserStats(_userId!);
        } else {
          rethrow;
        }
      }

      // CRITICAL: 로드맵에서 퀘스트 자동 생성 (비전-퀘스트 연계)
      if (_goalTree != null) {
        await _generateQuestsFromRoadmap();
      }

      // UserStats가 정상적으로 로드되었는지 확인 (최대 3초 대기)
      if (!mounted) return;

      int retries = 0;
      while (retries < 30) {  // 30 x 100ms = 3초
        final userStatsState = ref.read(userStatsNotifierProvider);
        if (userStatsState.value != null) {
          // 상태 확인 성공! 홈으로 이동
          if (mounted) {
            context.go('/');
          }
          return;
        }
        await Future.delayed(const Duration(milliseconds: 100));
        retries++;
      }

      // 타임아웃 - 그래도 이동 시도
      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('온보딩 완료 처리 중 오류: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  /// 로드맵의 milestones에서 자동으로 퀘스트 생성
  Future<void> _generateQuestsFromRoadmap() async {
    if (_goalTree == null) return;

    final milestones = _goalTree!['milestones'] as List<dynamic>? ?? [];
    if (milestones.isEmpty) return;

    try {
      final questNotifier = ref.read(questNotifierProvider.notifier);

      for (int i = 0; i < milestones.length; i++) {
        final milestone = milestones[i] as Map<String, dynamic>;
        final title = milestone['title'] as String? ?? '';
        final description = milestone['description'] as String? ?? '';

        if (title.isEmpty) continue;

        // 카테고리 추론 (키워드 기반)
        final category = _inferCategory(title, description);

        // 난이도 설정 (초반: 쉬움 → 후반: 어려움)
        final difficulty = _inferDifficulty(i, milestones.length);

        // 목표 횟수 (마일스톤 완료는 1회)
        final targetCount = 1;

        // 퀘스트 생성
        await questNotifier.createQuest(
          userId: _userId!,
          title: title,
          description: description.isNotEmpty ? description : null,
          category: category,
          difficulty: difficulty,
          targetCount: targetCount,
        );
      }
    } catch (e) {
      // 퀘스트 생성 실패 시 에러는 무시하고 계속 진행
      debugPrint('퀘스트 자동 생성 중 오류: $e');
    }
  }

  /// 텍스트 내용에서 카테고리 추론
  QuestCategory _inferCategory(String title, String description) {
    final text = '$title $description'.toLowerCase();

    if (text.contains('운동') || text.contains('건강') || text.contains('식단') ||
        text.contains('다이어트') || text.contains('헬스') || text.contains('요가')) {
      return QuestCategory.health;
    } else if (text.contains('공부') || text.contains('학습') || text.contains('강의') ||
        text.contains('독서') || text.contains('자격증') || text.contains('시험')) {
      return QuestCategory.study;
    } else if (text.contains('업무') || text.contains('일') || text.contains('회의') ||
        text.contains('프로젝트') || text.contains('보고서')) {
      return QuestCategory.work;
    } else if (text.contains('취미') || text.contains('그림') || text.contains('음악') ||
        text.contains('영화') || text.contains('게임')) {
      return QuestCategory.hobby;
    } else if (text.contains('관계') || text.contains('친구') || text.contains('가족') ||
        text.contains('모임') || text.contains('소통')) {
      return QuestCategory.relationship;
    } else {
      return QuestCategory.growth; // 기본값: 성장
    }
  }

  /// 마일스톤 순서에 따라 난이도 추론
  QuestDifficulty _inferDifficulty(int index, int total) {
    if (total <= 1) return QuestDifficulty.normal;

    final progress = index / (total - 1); // 0.0 ~ 1.0

    if (progress < 0.25) {
      return QuestDifficulty.easy;
    } else if (progress < 0.5) {
      return QuestDifficulty.normal;
    } else if (progress < 0.75) {
      return QuestDifficulty.hard;
    } else {
      return QuestDifficulty.veryHard;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor.withOpacity(0.1),
              AppTheme.secondaryColor.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 진행 바
              if (_currentStep < 5) _buildProgressBar(),

              // 콘텐츠
              Expanded(
                child: _currentStep < 5
                    ? PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildCharacterSelection(),
                          _buildNicknameInput(),
                          _buildValueSelection(),
                          _buildGoalInput(),
                          _buildReasonSelection(),
                        ],
                      )
                    : _buildAIGeneration(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 진행 바
  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing * 2),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '단계 ${_currentStep + 1}/5',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              Text(
                '${((_currentStep + 1) / 5 * 100).round()}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_currentStep + 1) / 5,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Step 0: 캐릭터 선택
  Widget _buildCharacterSelection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacing * 2),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Text(
            '⚡',
            style: TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 24),
          Text(
            'Quest ON에\n오신 것을 환영합니다!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            '매일 작은 성취로 성장하는\n나만의 캐릭터를 키워보세요',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          Text(
            '함께할 친구를 선택하세요',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: _characters.length,
            itemBuilder: (context, index) {
              final character = _characters[index];
              final isSelected = _selectedCharacter == character['emoji'];

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedCharacter = character['emoji'];
                  });
                },
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(AppConstants.borderRadius),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : Colors.grey[300]!,
                      width: isSelected ? 3 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        character['emoji']!,
                        style: const TextStyle(fontSize: 64),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        character['name']!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canProceed() ? _nextStep : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('다음 ✨'),
            ),
          ),
        ],
      ),
    );
  }

  /// Step 1: 닉네임 입력
  Widget _buildNicknameInput() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacing * 2),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Text(
            _selectedCharacter ?? '',
            style: const TextStyle(fontSize: 80),
          ),
          const SizedBox(height: 24),
          Text(
            '어떻게 불러드릴까요?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            '앞으로 사용할 닉네임을 설정해주세요',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '한글, 영어, 숫자만 사용 가능 (2-10자)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          TextField(
            controller: _nicknameController,
            textAlign: TextAlign.center,
            maxLength: 10,
            style: const TextStyle(fontSize: 20),
            decoration: const InputDecoration(
              hintText: '닉네임을 입력하세요',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) {
              setState(() {});
            },
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _prevStep,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('이전'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _canProceed() ? _nextStep : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('다음 ✨'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Step 2: 가치관 선택
  Widget _buildValueSelection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacing * 2),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Text(
            '💎',
            style: TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 24),
          Text(
            '어떤 가치를 추구하시나요?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            '최대 3개까지 선택할 수 있어요',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: _valueOptions.map((value) {
              final isSelected = _selectedValues.contains(value);
              return FilterChip(
                label: Text(value),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      if (_selectedValues.length < 3) {
                        _selectedValues.add(value);
                      }
                    } else {
                      _selectedValues.remove(value);
                    }
                  });
                },
                selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                checkmarkColor: AppTheme.primaryColor,
              );
            }).toList(),
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _prevStep,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('이전'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _canProceed() ? _nextStep : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('다음 ✨'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Step 3: 목표 입력
  Widget _buildGoalInput() {
    final goalLength = _goalController.text.length;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacing * 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Center(
            child: Text(
              '🎯',
              style: TextStyle(fontSize: 64),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '이루고 싶은 목표가 있나요?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            '구체적이고 측정 가능한 목표를 작성하면\nAI가 더 효과적인 코칭을 제공할 수 있어요',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // 목표
          Text(
            '목표',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _goalController,
            maxLines: 3,
            maxLength: 200,
            decoration: InputDecoration(
              hintText: '예: 6개월 안에 건강한 식습관을 만들고 10kg 감량하기',
              border: const OutlineInputBorder(),
              helperText: '$goalLength/200자 (최소 10자)',
              helperStyle: TextStyle(
                color: goalLength >= 10 ? AppTheme.successColor : AppTheme.errorColor,
              ),
            ),
            onChanged: (_) {
              setState(() {});
            },
          ),
          const SizedBox(height: 20),
          // 기한
          Text(
            '언제까지 이루고 싶나요? (선택)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _goalDeadlineController,
            decoration: const InputDecoration(
              hintText: '예: 2025년 12월 31일까지, 3개월 안에',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) {
              setState(() {});
            },
          ),
          const SizedBox(height: 20),
          // 성공 측정 기준
          Text(
            '어떻게 성공을 측정할 건가요? (선택)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _goalMeasurementController,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: '예: 체중계 숫자, 옷 사이즈 변화, 체지방률 감소',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) {
              setState(() {});
            },
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _prevStep,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('이전'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _canProceed() ? _nextStep : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('다음 ✨'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Step 4: 이유 선택
  Widget _buildReasonSelection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacing * 2),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Text(
            '💪',
            style: TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 24),
          Text(
            '왜 이 목표를 달성하고 싶으신가요?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            '최대 3개까지 선택할 수 있어요',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: _reasonOptions.map((reason) {
              final isSelected = _selectedReasons.contains(reason);
              return FilterChip(
                label: Text(reason),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      if (_selectedReasons.length < 3) {
                        _selectedReasons.add(reason);
                      }
                    } else {
                      _selectedReasons.remove(reason);
                    }
                  });
                },
                selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                checkmarkColor: AppTheme.primaryColor,
              );
            }).toList(),
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _prevStep,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('이전'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _canProceed() && !_isLoading ? _nextStep : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('AI 분석 시작 🚀'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Step 5-6: AI 생성 (코칭 + 로드맵)
  Widget _buildAIGeneration() {
    if (_error != null) {
      return _buildError();
    }

    if (_goalTree != null) {
      return _buildSuccess();
    }

    return _buildLoading();
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 6,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            _currentStep == 5
                ? 'AI가 당신의 비전을 분석하고 있습니다...'
                : 'AI가 실행 로드맵을 작성하고 있습니다...',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _currentStep == 5
                  ? '목표 달성을 위한\\n동기부여 메시지를 생성합니다'
                  : '목표 달성을 위한\\n구체적인 단계별 실행 계획을 생성합니다',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 48),
            child: LinearProgressIndicator(),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: 24),
            Text(
              '오류가 발생했습니다',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Unknown error',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _error = null;
                      _currentStep = 4; // 캐릭터 선택 화면으로 돌아가기
                    });
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('이전으로'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _generateVisionAndRoadmap,
                  icon: const Icon(Icons.refresh),
                  label: const Text('다시 시도'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccess() {
    final milestones = _goalTree!['milestones'] as List<dynamic>? ?? [];

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacing * 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 성공 메시지
                const Center(
                  child: Text(
                    '🎉',
                    style: TextStyle(fontSize: 80),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  '준비 완료!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  '당신만의 성장 여정이 시작됩니다',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // 비전 노트
                if (_visionNote != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(AppConstants.borderRadius),
                      border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.auto_awesome,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'AI 코칭 메시지',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _visionNote!,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    height: 1.6,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // 로드맵
                Text(
                  '실행 로드맵',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                if (milestones.isEmpty)
                  const Center(
                    child: Text('로드맵 데이터가 없습니다'),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: milestones.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final milestone = milestones[index] as Map<String, dynamic>;
                      return _buildMilestoneCard(index + 1, milestone);
                    },
                  ),
              ],
            ),
          ),
        ),

        // 시작하기 버튼
        Padding(
          padding: const EdgeInsets.all(AppConstants.spacing * 2),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _complete,
              icon: const Icon(Icons.rocket_launch),
              label: const Text(
                '시작하기',
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppTheme.successColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMilestoneCard(int step, Map<String, dynamic> milestone) {
    final title = milestone['title'] as String? ?? '';
    final description = milestone['description'] as String? ?? '';
    final duration = milestone['duration'] as String? ?? '';
    final successCriteria = milestone['successCriteria'] as String? ?? '';
    final potentialObstacles = milestone['potentialObstacles'] as String? ?? '';
    final keyActions = milestone['keyActions'] as List<dynamic>? ?? [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: AppTheme.secondaryColor.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                    '$step',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),

          // Description
          if (description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
            ),
          ],

          // Duration
          if (duration.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.schedule,
                  size: 16,
                  color: AppTheme.secondaryColor,
                ),
                const SizedBox(width: 4),
                Text(
                  duration,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.secondaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ],

          // Success Criteria
          if (successCriteria.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: AppTheme.successColor,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      successCriteria,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.successColor,
                            height: 1.4,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Key Actions
          if (keyActions.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...keyActions.map((action) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.arrow_forward,
                      size: 14,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        action.toString(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textPrimary,
                              height: 1.3,
                            ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],

          // Potential Obstacles
          if (potentialObstacles.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber,
                    size: 16,
                    color: AppTheme.warningColor,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      potentialObstacles,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.warningColor,
                            height: 1.4,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
