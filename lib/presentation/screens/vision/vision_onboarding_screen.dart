import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quest_on/domain/entities/vision.dart';
import 'package:quest_on/presentation/providers/vision_v2_provider.dart';

/// Vision 온보딩 화면 (6개 질문 대화형 UI)
class VisionOnboardingScreen extends ConsumerStatefulWidget {
  const VisionOnboardingScreen({super.key});

  @override
  ConsumerState<VisionOnboardingScreen> createState() =>
      _VisionOnboardingScreenState();
}

class _VisionOnboardingScreenState
    extends ConsumerState<VisionOnboardingScreen> {
  final PageController _pageController = PageController();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, Set<String>> _selectedKeywords = {}; // 키워드 선택형 답변
  final Map<String, String> _answers = {};
  int _currentPage = 0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // 텍스트 입력형 질문만 컨트롤러 초기화
    for (var question in VisionQuestion.values) {
      if (!question.isKeywordType) {
        _controllers[question.key] = TextEditingController();
      } else {
        _selectedKeywords[question.key] = {};
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _nextPage() {
    print('[온보딩] _nextPage 호출: 현재 페이지 = $_currentPage, 전체 = ${VisionQuestion.values.length}');
    if (_currentPage < VisionQuestion.values.length - 1) {
      print('[온보딩] 다음 페이지로 이동 시도');
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      print('[온보딩] 마지막 페이지입니다');
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _canProceed() {
    final currentQuestion = VisionQuestion.values[_currentPage];
    print('[온보딩] _canProceed 체크: 페이지=$_currentPage, 질문=${currentQuestion.key}');

    if (currentQuestion.isOptional) {
      print('[온보딩] 선택사항 질문 → true');
      return true; // 선택사항은 항상 진행 가능
    }

    if (currentQuestion.isKeywordType) {
      final selected = _selectedKeywords[currentQuestion.key] ?? {};
      print('[온보딩] 키워드형 질문: 선택된 개수=${selected.length}');
      return selected.isNotEmpty;
    } else {
      final text = _controllers[currentQuestion.key]?.text ?? '';
      print('[온보딩] 텍스트형 질문: 입력된 텍스트="${text}", 길이=${text.length}, isEmpty=${text.trim().isEmpty}');
      return text.trim().isNotEmpty;
    }
  }

  Future<void> _submit() async {
    print('[온보딩] _submit 시작');

    // 모든 답변 수집
    for (var question in VisionQuestion.values) {
      if (question.isKeywordType) {
        final selected = _selectedKeywords[question.key] ?? {};
        _answers[question.key] = selected.join(', ');
      } else {
        _answers[question.key] = _controllers[question.key]?.text ?? '';
      }
    }

    print('[온보딩] 수집된 답변: $_answers');

    setState(() {
      _isSubmitting = true;
    });

    try {
      print('[온보딩] Vision 생성 시작');
      // Vision 생성 (비전 노트는 나중에 AI가 생성)
      final vision = await ref
          .read(visionNotifierProvider.notifier)
          .createVision(answers: _answers);

      print('[온보딩] Vision 생성 완료: ${vision.id}');

      if (mounted) {
        print('[온보딩] /vision/generating으로 이동');
        // AI 비전 노트 생성 화면으로 이동
        context.go('/vision/generating', extra: vision.id);
      }
    } catch (e) {
      print('[온보딩] 에러 발생: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final questions = VisionQuestion.values;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentPage > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousPage,
              )
            : null,
        title: Text(
          '나의 비전 탐색',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 진행도 표시
          _buildProgressIndicator(questions.length),

          // 질문 페이지
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // 스와이프 비활성화
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: questions.length,
              itemBuilder: (context, index) {
                return _buildQuestionPage(
                  context,
                  questions[index],
                  index + 1,
                  questions.length,
                );
              },
            ),
          ),

          // 하단 버튼
          _buildBottomButtons(context),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(int totalQuestions) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: (_currentPage + 1) / totalQuestions,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                  minHeight: 4,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${_currentPage + 1}/$totalQuestions',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPage(
    BuildContext context,
    VisionQuestion question,
    int currentNumber,
    int totalQuestions,
  ) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // 질문 번호 태그
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$currentNumber/$totalQuestions',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (question.isOptional) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '선택',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 24),

          // 질문 텍스트
          Text(
            question.questionText,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 32),

          // 답변 입력 영역 (키워드형 or 텍스트형)
          if (question.isKeywordType)
            _buildKeywordSelector(question)
          else
            _buildTextInput(question, theme),

          const SizedBox(height: 24),

          // 도움말 텍스트
          _buildHintText(context, question),
        ],
      ),
    );
  }

  Widget _buildKeywordSelector(VisionQuestion question) {
    final keywords = question == VisionQuestion.valuesQuestion
        ? ValueKeywords.options
        : MotivationKeywords.options;

    final maxSelection = 3; // 가치관과 동기부여 모두 최대 3개 선택 가능
    final selectedSet = _selectedKeywords[question.key] ?? {};

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: keywords.map((keyword) {
        final isSelected = selectedSet.contains(keyword);
        final canSelect = selectedSet.length < maxSelection || isSelected;

        return FilterChip(
          label: Text(keyword),
          selected: isSelected,
          onSelected: canSelect
              ? (selected) {
                  setState(() {
                    final set = _selectedKeywords[question.key] ?? {};
                    if (selected) {
                      set.add(keyword);
                    } else {
                      set.remove(keyword);
                    }
                    _selectedKeywords[question.key] = set;
                  });
                }
              : null,
          selectedColor: Theme.of(context).colorScheme.primaryContainer,
          checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
          backgroundColor: Colors.grey[200],
          labelStyle: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextInput(VisionQuestion question, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controllers[question.key],
          maxLines: 5,
          decoration: InputDecoration(
            hintText: '자유롭게 작성해주세요...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(20),
          ),
          style: theme.textTheme.bodyLarge,
          onChanged: (_) => setState(() {}), // 버튼 상태 업데이트
        ),

        // 테스트용 예시 입력 버튼 (2~5번 질문만)
        if (_shouldShowTestButton(question)) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _fillTestExample(question),
            icon: const Icon(Icons.science, size: 18),
            label: const Text('테스트용 예시 입력'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange,
              side: const BorderSide(color: Colors.orange),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ],
    );
  }

  bool _shouldShowTestButton(VisionQuestion question) {
    // 2~5번 질문만 테스트 버튼 표시
    return question == VisionQuestion.currentIdentity ||
           question == VisionQuestion.futureIdentity ||
           question == VisionQuestion.concern ||
           question == VisionQuestion.routine;
  }

  void _fillTestExample(VisionQuestion question) {
    final examples = {
      VisionQuestion.currentIdentity: '일과 공부를 병행하며 성장하고 있는 직장인',
      VisionQuestion.futureIdentity: '자신의 전문성을 인정받으며 팀을 이끄는 리더',
      VisionQuestion.concern: '효율적인 시간 관리와 업무 역량 향상',
      VisionQuestion.routine: '매일 아침 30분 독서하고, 주 3회 운동하기',
    };

    final example = examples[question];
    print('[온보딩] 테스트 예시 입력: 질문=${question.key}, 예시=$example');
    if (example != null) {
      _controllers[question.key]?.text = example;
      print('[온보딩] 컨트롤러에 텍스트 설정 완료');
      setState(() {}); // 버튼 상태 업데이트
      print('[온보딩] setState 호출 완료');
    }
  }

  Widget _buildHintText(BuildContext context, VisionQuestion question) {
    final hints = {
      VisionQuestion.valuesQuestion:
          '💡 당신의 삶에서 가장 중요한 가치를 최대 3개까지 선택해주세요',
      VisionQuestion.currentIdentity:
          '💡 지금 당신의 상태나 역할을 자유롭게 표현해주세요\n예: 배우고 있는 학생, 일하는 직장인, 꿈을 찾는 탐험가',
      VisionQuestion.futureIdentity:
          '💡 3년 후 이루고 싶은 모습을 구체적으로 그려보세요\n예: 영향력 있는 전문가, 자유로운 창작자, 행복한 부모',
      VisionQuestion.concern:
          '💡 요즘 가장 신경 쓰이거나 집중하고 싶은 주제를 적어주세요\n예: 진로 고민, 시간 관리, 자기계발 방향성',
      VisionQuestion.routine:
          '💡 새롭게 만들고 싶은 일상 습관을 구체적으로 적어주세요\n예: 아침 운동 30분, 독서 10페이지, 영어 공부 1시간',
      VisionQuestion.motivation:
          '💡 당신에게 힘이 되는 방식을 최대 3개까지 선택하세요 (선택사항)',
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        hints[question] ?? '💡 자유롭게 작성해주세요',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    final theme = Theme.of(context);
    final isLastPage = _currentPage == VisionQuestion.values.length - 1;
    final canProceed = _canProceed();

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 이전 버튼
            if (_currentPage > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousPage,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('이전'),
                ),
              ),

            if (_currentPage > 0) const SizedBox(width: 12),

            // 다음/완료 버튼
            Expanded(
              flex: _currentPage > 0 ? 1 : 1,
              child: ElevatedButton(
                onPressed: canProceed && !_isSubmitting
                    ? (isLastPage ? _submit : _nextPage)
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        isLastPage ? '완료' : '다음',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
