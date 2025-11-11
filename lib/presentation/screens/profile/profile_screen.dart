import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quest_on/core/theme/app_theme.dart';
import 'package:quest_on/core/constants/app_constants.dart';
import 'package:quest_on/presentation/providers/auth_provider.dart';
import 'package:quest_on/presentation/providers/user_stats_provider.dart';
import 'package:quest_on/presentation/providers/quest_provider.dart';
import 'package:quest_on/presentation/widgets/error_view.dart';
import 'package:quest_on/presentation/widgets/loading_view.dart';
import 'package:quest_on/domain/entities/user_stats.dart';
import 'package:quest_on/domain/entities/quest.dart';

/// 프로필 화면
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStateAsync = ref.watch(authStateProvider);
    final user = authStateAsync.value;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('로그인이 필요합니다'),
        ),
      );
    }

    final userStatsAsync = ref.watch(userStatsStreamProvider(user.id));
    final todayCountAsync = ref.watch(todayCompletedCountProvider(user.id));
    final completedQuestsAsync = ref.watch(completedQuestsProvider(user.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacing * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 사용자 정보 카드
            userStatsAsync.when(
              data: (stats) {
                if (stats == null) return const SizedBox.shrink();

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.spacing * 2),
                    child: Column(
                      children: [
                        // 편집 버튼
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            color: AppTheme.primaryColor,
                            onPressed: () => _showEditProfileDialog(context, ref, stats),
                            tooltip: '프로필 편집',
                          ),
                        ),
                        // 캐릭터
                        Text(
                          stats.character,
                          style: const TextStyle(fontSize: 80),
                        ),
                        const SizedBox(height: 16),
                        // 닉네임
                        Text(
                          stats.nickname,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        // 레벨
                        Text(
                          'Lv.${stats.level} ${stats.levelTitle}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppTheme.primaryColor,
                              ),
                        ),
                        const SizedBox(height: 16),
                        // 경험치 정보
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              context,
                              '현재 EXP',
                              '${stats.currentExp}',
                            ),
                            _buildStatItem(
                              context,
                              '총 EXP',
                              '${stats.totalExp}',
                            ),
                            _buildStatItem(
                              context,
                              '다음 레벨까지',
                              '${stats.expToNextLevel}',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
              loading: () => Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spacing * 2),
                  child: const LoadingView(message: '사용자 정보 로딩 중...'),
                ),
              ),
              error: (error, stack) => ErrorCard(
                message: ErrorView.getFriendlyMessage(error),
                onRetry: () {
                  ref.invalidate(userStatsStreamProvider(user.id));
                },
              ),
            ),
            const SizedBox(height: 24),

            // 통계 카드
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacing * 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '퀘스트 통계',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    todayCountAsync.when(
                      data: (count) => _buildStatRow(
                        context,
                        '오늘 완료',
                        '$count개',
                        Icons.check_circle,
                      ),
                      loading: () => const SmallLoadingIndicator(),
                      error: (error, __) => ErrorCard(
                        message: ErrorView.getFriendlyMessage(error),
                        onRetry: () {
                          ref.invalidate(todayCompletedCountProvider(user.id));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 퀘스트 히스토리 카드
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacing * 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '퀘스트 히스토리',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        completedQuestsAsync.when(
                          data: (quests) => Text(
                            '${quests.length}개 완료',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    completedQuestsAsync.when(
                      data: (quests) {
                        if (quests.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.emoji_events_outlined,
                                    size: 48,
                                    color: Colors.grey[300],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    '완료한 퀘스트가 없습니다',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        // 최근 5개만 표시
                        final recentQuests = quests.take(5).toList();

                        return Column(
                          children: [
                            ...recentQuests.map((quest) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppTheme.primaryColor.withOpacity(0.1),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        quest.category.emoji,
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            quest.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.star,
                                                size: 14,
                                                color: Colors.amber[700],
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '+${quest.difficulty.baseExp} EXP',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.amber[700],
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: _getDifficultyColor(quest.difficulty)
                                                      .withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  quest.difficulty.label,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: _getDifficultyColor(quest.difficulty),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.check_circle,
                                      color: AppTheme.primaryColor,
                                      size: 24,
                                    ),
                                  ],
                                ),
                              );
                            }),
                            if (quests.length > 5) ...[
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: () {
                                  // TODO: 전체 히스토리 페이지로 이동
                                },
                                icon: const Icon(Icons.history, size: 18),
                                label: Text(
                                  '전체 히스토리 보기 (+${quests.length - 5})',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                      loading: () => const SmallLoadingIndicator(),
                      error: (error, stack) => ErrorCard(
                        message: ErrorView.getFriendlyMessage(error),
                        onRetry: () {
                          ref.invalidate(completedQuestsProvider(user.id));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 업적 버튼
            Card(
              child: InkWell(
                onTap: () {
                  // TODO: 업적 화면으로 이동
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('업적 시스템은 곧 출시됩니다!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.amber[600]!,
                              Colors.orange[600]!,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.emoji_events,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '업적',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '달성한 업적을 확인하세요',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 로그아웃 버튼
            ElevatedButton(
              onPressed: () async {
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('로그아웃'),
                    content: const Text('정말 로그아웃하시겠습니까?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('취소'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('로그아웃'),
                      ),
                    ],
                  ),
                );

                if (shouldLogout == true) {
                  await ref.read(authNotifierProvider.notifier).signOut();
                  if (context.mounted) {
                    context.go('/login');
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                '로그아웃',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
          ),
        ],
      ),
    );
  }

  /// 프로필 편집 다이얼로그
  void _showEditProfileDialog(BuildContext context, WidgetRef ref, UserStats stats) {
    final nicknameController = TextEditingController(text: stats.nickname);
    String selectedCharacter = stats.character;

    final characters = ['😀', '😎', '🥳', '🤓', '😇', '🤠', '🥷', '👨‍🎓', '👩‍💼', '👨‍💻', '🧙‍♂️', '🧝‍♀️'];

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('프로필 편집'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 닉네임 입력
                TextField(
                  controller: nicknameController,
                  decoration: const InputDecoration(
                    labelText: '닉네임',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 20,
                ),
                const SizedBox(height: 24),
                // 캐릭터 선택
                const Text(
                  '캐릭터',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: characters.map((char) {
                    final isSelected = char == selectedCharacter;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCharacter = char;
                        });
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryColor.withOpacity(0.1)
                              : Colors.grey[100],
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primaryColor
                                : Colors.grey[300]!,
                            width: isSelected ? 3 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            char,
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                final nickname = nicknameController.text.trim();
                if (nickname.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('닉네임을 입력해주세요')),
                  );
                  return;
                }

                try {
                  await ref.read(userStatsNotifierProvider.notifier).updateProfile(
                        nickname: nickname,
                        character: selectedCharacter,
                      );

                  if (context.mounted) {
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('프로필이 업데이트되었습니다')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('업데이트 실패: ${e.toString()}')),
                    );
                  }
                }
              },
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(QuestDifficulty difficulty) {
    switch (difficulty) {
      case QuestDifficulty.easy:
        return Colors.green;
      case QuestDifficulty.normal:
        return Colors.blue;
      case QuestDifficulty.hard:
        return Colors.orange;
      case QuestDifficulty.veryHard:
        return Colors.red;
    }
  }
}
