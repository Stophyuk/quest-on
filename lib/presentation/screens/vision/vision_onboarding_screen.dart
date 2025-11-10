import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quest_on/domain/entities/vision.dart';
import 'package:quest_on/presentation/providers/vision_v2_provider.dart';

/// Vision 온보딩 화면 (9개 질문 대화형 UI)
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
  final Map<String, String> _answers = {};
  int _currentPage = 0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // 각 질문별 컨트롤러 초기화
    for (var question in VisionQuestion.values) {
      _controllers[question.key] = TextEditingController();
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
    if (_currentPage < VisionQuestion.values.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
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

  Future<void> _submit() async {
    // 모든 답변 수집
    for (var question in VisionQuestion.values) {
      _answers[question.key] = _controllers[question.key]!.text;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Vision 생성 (비전 노트는 나중에 AI가 생성)
      final vision = await ref
          .read(visionNotifierProvider.notifier)
          .createVision(answers: _answers);

      if (mounted) {
        // AI 비전 노트 생성 화면으로 이동
        context.go('/vision/generating', extra: vision.id);
      }
    } catch (e) {
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Question $currentNumber',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
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

          // 답변 입력 필드
          TextField(
            controller: _controllers[question.key],
            maxLines: 8,
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
          ),

          const SizedBox(height: 24),

          // 도움말 텍스트
          _buildHintText(context, question),
        ],
      ),
    );
  }

  Widget _buildHintText(BuildContext context, VisionQuestion question) {
    final hints = {
      VisionQuestion.values:
          '💡 예: 성장, 자유, 가족, 창의성, 도전 등',
      VisionQuestion.currentIdentity:
          '💡 예: 배우고 있는 학생, 일하는 직장인, 꿈을 찾는 탐험가 등',
      VisionQuestion.futureIdentity:
          '💡 예: 영향력 있는 전문가, 자유로운 창작자, 행복한 부모 등',
      VisionQuestion.lifeDream:
          '💡 예: 세계 여행, 나만의 사업 시작, 책 출판, 가족과 행복한 삶 등',
      VisionQuestion.concern:
          '💡 예: 진로 고민, 시간 부족, 자기계발 방향성 등',
      VisionQuestion.futureGoal:
          '💡 예: 전문 자격증 취득, 승진, 사이드 프로젝트 성공 등',
      VisionQuestion.routine:
          '💡 예: 아침 운동, 독서 30분, 영어 공부, 명상 등',
      VisionQuestion.learningStyle:
          '💡 예: 책 읽기, 강의 듣기, 실습하기, 토론하기 등',
      VisionQuestion.motivation:
          '💡 예: 성취감, 칭찬, 보상, 경쟁, 자기만족 등',
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
    final currentAnswer = _controllers[VisionQuestion.values[_currentPage].key]!.text;
    final canProceed = currentAnswer.trim().isNotEmpty;

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
