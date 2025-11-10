import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quest_on/presentation/providers/vision_v2_provider.dart';

/// AI 비전 노트 생성 로딩 화면 (30초 소요)
class VisionGeneratingScreen extends ConsumerStatefulWidget {
  final String visionId;

  const VisionGeneratingScreen({
    super.key,
    required this.visionId,
  });

  @override
  ConsumerState<VisionGeneratingScreen> createState() =>
      _VisionGeneratingScreenState();
}

class _VisionGeneratingScreenState
    extends ConsumerState<VisionGeneratingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isGenerating = false;
  String _currentStep = '당신의 답변을 분석하고 있어요...';

  final List<String> _steps = [
    '당신의 답변을 분석하고 있어요...',
    '가치관과 목표를 정리하고 있어요...',
    '비전 노트를 작성하고 있어요...',
    '거의 다 됐어요!',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _startGeneration();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _startGeneration() async {
    setState(() {
      _isGenerating = true;
    });

    // 단계별 메시지 변경
    _animateSteps();

    try {
      // AI 비전 노트 생성 (30초 소요)
      final vision = await ref
          .read(visionNotifierProvider.notifier)
          .generateVisionNote(widget.visionId);

      if (mounted) {
        // 비전 노트 확인 화면으로 이동
        context.go('/vision/review', extra: vision);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString());
      }
    }
  }

  void _animateSteps() {
    int stepIndex = 0;
    // 7.5초마다 다음 단계로
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 7500));
      if (!mounted || !_isGenerating) return false;

      stepIndex++;
      if (stepIndex < _steps.length) {
        setState(() {
          _currentStep = _steps[stepIndex];
        });
        return true;
      }
      return false;
    });
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('오류 발생'),
        content: Text('비전 노트 생성 중 오류가 발생했습니다.\n\n$error'),
        actions: [
          TextButton(
            onPressed: () {
              context.go('/');
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // 로딩 애니메이션
              _buildLoadingAnimation(),

              const SizedBox(height: 48),

              // 제목
              Text(
                'AI가 당신의 비전을\n분석하고 있어요',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 16),

              // 부제목
              Text(
                '약 30초 정도 소요됩니다',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 48),

              // 현재 단계 표시
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        _currentStep,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // 안내 메시지
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.secondaryContainer,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: theme.colorScheme.secondary,
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'AI가 당신의 답변을 바탕으로\n맞춤형 비전 노트를 작성하고 있습니다',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingAnimation() {
    return RotationTransition(
      turns: _animationController,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: const Icon(
          Icons.auto_awesome,
          size: 60,
          color: Colors.white,
        ),
      ),
    );
  }
}
