import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quest_on/core/theme/app_theme.dart';
import 'package:quest_on/core/constants/app_constants.dart';
import 'package:quest_on/domain/entities/vision.dart';
import 'package:quest_on/presentation/providers/auth_provider.dart';
import 'package:quest_on/presentation/providers/vision_v2_provider.dart';

/// 비전 메인 화면
///
/// - 프로필이 없으면: 설문 시작 유도
/// - 프로필이 있고 비전 노트가 있으면: 비전 노트 표시
/// - 프로필이 있지만 비전 노트가 없으면: 비전 노트 생성 유도
class VisionScreen extends ConsumerStatefulWidget {
  const VisionScreen({super.key});

  @override
  ConsumerState<VisionScreen> createState() => _VisionScreenState();
}

class _VisionScreenState extends ConsumerState<VisionScreen> {
  @override
  void initState() {
    super.initState();
    // 비전 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(visionNotifierProvider.notifier).loadVision();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authStateAsync = ref.watch(authStateProvider);
    final visionStateAsync = ref.watch(visionNotifierProvider);

    return authStateAsync.when(
      data: (user) {
        if (user == null) {
          return const Center(child: Text('로그인이 필요합니다'));
        }

        return visionStateAsync.when(
          data: (vision) {
            if (vision == null) {
              return _buildNoVision(context);
            }

            if (vision.visionNote.isEmpty) {
              return _buildNoVisionNote(context);
            }

            return _buildVisionNote(context, vision);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildError(context, error),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildError(context, error),
    );
  }

  /// 비전이 없는 경우 (온보딩 시작 유도)
  Widget _buildNoVision(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 80,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              '나만의 비전을 만들어보세요',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'AI가 당신의 가치관과 목표를 분석하여\n맞춤형 코칭과 실행 계획을 제공합니다',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.6,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.go('/onboarding');
                },
                icon: const Icon(Icons.edit_note),
                label: const Text(
                  '비전 온보딩 시작하기',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 비전은 있지만 비전 노트가 없는 경우
  Widget _buildNoVisionNote(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.psychology,
                size: 80,
                color: AppTheme.secondaryColor,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'AI 비전 노트를\n생성해보세요',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              '온보딩 내용을 바탕으로 AI가\n맞춤형 비전 노트를 작성해드립니다',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.6,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.go('/onboarding');
                },
                icon: const Icon(Icons.auto_awesome),
                label: const Text(
                  '온보딩 시작하기',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 비전 노트 표시
  Widget _buildVisionNote(BuildContext context, Vision vision) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacing * 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppTheme.primaryColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '나의 비전',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'AI 생성 비전 노트',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // AI 비전 노트
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Text(
              vision.visionNote,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                  ),
            ),
          ),
          const SizedBox(height: 24),

          // 로드맵 버튼
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                context.push('/vision/roadmap');
              },
              icon: const Icon(Icons.map_outlined),
              label: const Text('실행 로드맵 보기'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),

          // 재생성 버튼
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () {
                _showRegenerateDialog(context);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('비전 다시 설정하기'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 오류 표시
  Widget _buildError(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              '오류가 발생했습니다',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 재생성 다이얼로그
  void _showRegenerateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('비전 재설정'),
        content: const Text(
          '비전을 다시 설정하면 기존 코칭과 로드맵이 삭제됩니다.\n계속하시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.push('/vision/survey');
            },
            child: const Text('재설정'),
          ),
        ],
      ),
    );
  }
}
