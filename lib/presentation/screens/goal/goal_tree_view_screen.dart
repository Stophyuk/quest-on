import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quest_on/domain/entities/goal_tree.dart';
import 'package:quest_on/domain/entities/goal.dart';
import 'package:quest_on/presentation/providers/auth_provider.dart';
import 'package:quest_on/presentation/providers/user_stats_provider.dart';

/// 목표 트리 표시 화면
class GoalTreeViewScreen extends ConsumerWidget {
  final GoalTree goalTree;

  const GoalTreeViewScreen({
    super.key,
    required this.goalTree,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '나의 목표 트리',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 안내 메시지
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.primaryContainer,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'AI가 작성한 목표 트리입니다.\n이제 일일 퀘스트를 받을 수 있어요!',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 장기 목표 (1-3년)
                  _buildGoalSection(
                    context,
                    '장기 목표 (1-3년)',
                    goalTree.longTermGoals,
                    Icons.flag_outlined,
                    theme.colorScheme.primary,
                  ),

                  const SizedBox(height: 24),

                  // 중기 목표 (3-6개월)
                  _buildGoalSection(
                    context,
                    '중기 목표 (3-6개월)',
                    goalTree.midTermGoals,
                    Icons.trending_up,
                    theme.colorScheme.secondary,
                  ),

                  const SizedBox(height: 24),

                  // 단기 목표 (1개월)
                  _buildGoalSection(
                    context,
                    '단기 목표 (1개월)',
                    goalTree.shortTermGoals,
                    Icons.calendar_today,
                    theme.colorScheme.tertiary,
                  ),

                  const SizedBox(height: 24),

                  // 통계
                  _buildStatistics(context, goalTree),
                ],
              ),
            ),
          ),

          // 하단 버튼
          _buildBottomButton(context, ref),
        ],
      ),
    );
  }

  Widget _buildGoalSection(
    BuildContext context,
    String title,
    List<Goal> goals,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 헤더
        Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${goals.length}개',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // 목표 목록
        if (goals.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '목표가 없습니다',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ),
          )
        else
          ...goals.map((goal) => _buildGoalCard(context, goal, color)),
      ],
    );
  }

  Widget _buildGoalCard(BuildContext context, Goal goal, Color color) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            goal.title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (goal.description != null && goal.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              goal.description!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
              ),
            ),
          ],
          if (goal.targetDate != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '목표일: ${goal.targetDate!.year}.${goal.targetDate!.month}.${goal.targetDate!.day}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                if (goal.dDay != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    goal.isOverdue ? 'D+${-goal.dDay!}' : 'D-${goal.dDay}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: goal.isOverdue ? Colors.red : color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatistics(BuildContext context, GoalTree goalTree) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '목표 현황',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context,
                '전체',
                '${goalTree.activeGoalsCount + goalTree.completedGoalsCount}',
                Icons.list_alt,
              ),
              _buildStatItem(
                context,
                '진행중',
                '${goalTree.activeGoalsCount}',
                Icons.play_circle_outline,
              ),
              _buildStatItem(
                context,
                '완료',
                '${goalTree.completedGoalsCount}',
                Icons.check_circle_outline,
              ),
              _buildStatItem(
                context,
                '달성률',
                '${goalTree.completionRate.toStringAsFixed(0)}%',
                Icons.trending_up,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

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
        child: ElevatedButton(
          onPressed: () async {
            print('[목표트리] 시작하기 버튼 클릭');

            try {
              // 현재 사용자 가져오기
              final user = ref.read(authStateProvider).value;
              if (user == null) {
                print('[목표트리] 에러: 사용자 정보 없음');
                return;
              }

              print('[목표트리] 사용자 ID: ${user.id}');

              // UserStats 생성 (온보딩 완료)
              print('[목표트리] UserStats 생성 중...');
              await ref.read(userStatsNotifierProvider.notifier).createUserStats(
                userId: user.id,
                nickname: '새로운 모험가', // 기본 닉네임
                character: '🐰', // 기본 캐릭터 (토끼)
              );

              print('[목표트리] UserStats 생성 완료');

              if (context.mounted) {
                print('[목표트리] 메인 화면으로 이동');
                // 메인 화면으로 이동
                context.go('/');
              }
            } catch (e) {
              print('[목표트리] 에러 발생: $e');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('오류가 발생했습니다: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            '시작하기',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
