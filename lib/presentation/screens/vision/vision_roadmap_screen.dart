import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quest_on/core/theme/app_theme.dart';
import 'package:quest_on/core/constants/app_constants.dart';
import 'package:quest_on/domain/entities/goal.dart';
import 'package:quest_on/domain/entities/goal_tree.dart';
import 'package:quest_on/presentation/providers/auth_provider.dart';
import 'package:quest_on/presentation/providers/goal_provider.dart';
import 'package:quest_on/presentation/providers/vision_v2_provider.dart';

/// 로드맵 화면 (하단 네비게이션 탭)
///
/// - 비전 없음: 온보딩 시작 유도
/// - 비전 노트 없음: AI 코칭 먼저 생성 유도
/// - 로드맵 있음: 로드맵 표시
/// - 로드맵 없음: 로드맵 생성 유도
class VisionRoadmapScreen extends ConsumerStatefulWidget {
  const VisionRoadmapScreen({super.key});

  @override
  ConsumerState<VisionRoadmapScreen> createState() =>
      _VisionRoadmapScreenState();
}

class _VisionRoadmapScreenState extends ConsumerState<VisionRoadmapScreen> {
  @override
  void initState() {
    super.initState();
    // 비전 및 Goal Tree 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(visionNotifierProvider.notifier).loadVision();
      ref.read(goalTreeNotifierProvider.notifier).loadGoalTree();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authStateAsync = ref.watch(authStateProvider);
    final visionStateAsync = ref.watch(visionNotifierProvider);
    final goalTreeStateAsync = ref.watch(goalTreeNotifierProvider);

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

            return goalTreeStateAsync.when(
              data: (goalTree) {
                if (goalTree == null) {
                  return _buildNoRoadmap(context);
                }
                return _buildRoadmap(context, goalTree);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildError(context, error),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildError(context, error),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildError(context, error),
    );
  }

  /// 비전 없음 (온보딩 시작 유도)
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
                color: AppTheme.secondaryColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.map_outlined,
                size: 80,
                color: AppTheme.secondaryColor,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              '실행 로드맵을 만들어보세요',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              '먼저 비전 온보딩을 완료해주세요.\nAI가 목표 달성을 위한 구체적인\n실행 계획을 생성해드립니다',
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

  /// 비전 노트 없음 (온보딩 완료 유도)
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
              '온보딩을 완료해주세요',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              '로드맵을 생성하기 위해서는\n온보딩 완료가 필요합니다',
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

  /// 로드맵 없음 (로드맵 자동 생성 안내)
  Widget _buildNoRoadmap(BuildContext context) {
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
                Icons.route,
                size: 80,
                color: AppTheme.secondaryColor,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              '로드맵이 아직 생성되지 않았습니다',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              '온보딩 완료 시 자동으로 생성됩니다.\n비전 탭에서 온보딩을 완료해주세요',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.6,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  context.go('/onboarding');
                },
                icon: const Icon(Icons.edit_note),
                label: const Text(
                  '온보딩 시작하기',
                  style: TextStyle(fontSize: 16),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 로드맵 표시
  Widget _buildRoadmap(BuildContext context, GoalTree goalTree) {
    final longTermGoals = goalTree.longTermGoals;
    final midTermGoals = goalTree.midTermGoals;
    final shortTermGoals = goalTree.shortTermGoals;

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
                  color: AppTheme.secondaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.map_outlined,
                  color: AppTheme.secondaryColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '실행 로드맵',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '목표 달성을 위한 단계별 계획',
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

          // 장기 목표 (1-3년)
          if (longTermGoals.isNotEmpty) ...[
            _buildGoalSection(
              context,
              '장기 목표 (1-3년)',
              Icons.flag,
              Colors.purple,
              longTermGoals,
            ),
            const SizedBox(height: 24),
          ],

          // 중기 목표 (3-6개월)
          if (midTermGoals.isNotEmpty) ...[
            _buildGoalSection(
              context,
              '중기 목표 (3-6개월)',
              Icons.trending_up,
              Colors.blue,
              midTermGoals,
            ),
            const SizedBox(height: 24),
          ],

          // 단기 목표 (1개월)
          if (shortTermGoals.isNotEmpty) ...[
            _buildGoalSection(
              context,
              '단기 목표 (1개월)',
              Icons.bolt,
              Colors.orange,
              shortTermGoals,
            ),
            const SizedBox(height: 24),
          ],

          // 빈 상태
          if (goalTree.goals.isEmpty)
            const Center(
              child: Text('목표가 아직 설정되지 않았습니다'),
            ),
        ],
      ),
    );
  }

  /// 목표 섹션 (기간별)
  Widget _buildGoalSection(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    List<Goal> goals,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 헤더
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 목표 리스트
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: goals.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final goal = goals[index];
            return _buildGoalCard(context, goal, color);
          },
        ),
      ],
    );
  }

  /// 목표 카드
  Widget _buildGoalCard(BuildContext context, Goal goal, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: accentColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목
          Text(
            goal.title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),

          // 설명
          if (goal.description != null && goal.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              goal.description!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
            ),
          ],
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
        title: const Text('로드맵 재생성'),
        content: const Text(
          '로드맵을 다시 생성하려면 온보딩을 다시 진행해야 합니다.\n기존 비전과 로드맵이 삭제됩니다.\n계속하시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/onboarding');
            },
            child: const Text('재생성'),
          ),
        ],
      ),
    );
  }
}
