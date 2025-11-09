import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quest_on/core/theme/app_theme.dart';
import 'package:quest_on/core/constants/app_constants.dart';
import 'package:quest_on/core/utils/quest_parsers.dart';
import 'package:quest_on/core/utils/ui_helpers.dart';
import 'package:quest_on/domain/entities/quest.dart';
import 'package:quest_on/presentation/providers/auth_provider.dart';
import 'package:quest_on/presentation/providers/quest_provider.dart';
import 'package:quest_on/presentation/providers/user_stats_provider.dart';
import 'package:quest_on/presentation/widgets/player_card.dart';
import 'package:quest_on/presentation/widgets/error_view.dart';
import 'package:quest_on/presentation/widgets/loading_view.dart';
import 'package:quest_on/presentation/widgets/ai_quest_suggestions_modal.dart';
import 'package:quest_on/data/datasources/remote/ai_remote_datasource.dart';

/// 퀘스트 목록 화면 (홈 화면)
class QuestListScreen extends ConsumerStatefulWidget {
  const QuestListScreen({super.key});

  @override
  ConsumerState<QuestListScreen> createState() => _QuestListScreenState();
}

class _QuestListScreenState extends ConsumerState<QuestListScreen> {
  QuestCondition _selectedCondition = QuestCondition.normal;
  bool _hasLoadedQuests = false;
  bool _isLoadingAiSuggestions = false;
  final AiRemoteDataSource _aiDataSource = AiRemoteDataSource();

  @override
  void initState() {
    super.initState();
    // 퀘스트 로드는 build에서 authState를 listen하여 처리
  }

  Future<void> _onConditionChanged(QuestCondition newCondition) async {
    setState(() {
      _selectedCondition = newCondition;
    });

    try {
      await ref
          .read(questNotifierProvider.notifier)
          .adjustAllQuestsTarget(newCondition);

      if (mounted) {
        UiHelpers.showSuccessSnackBar(
          context,
          '컨디션이 "${newCondition.label}"로 변경되었습니다',
        );
      }
    } catch (e) {
      if (mounted) {
        UiHelpers.showErrorSnackBar(
          context,
          '목표 조정 중 오류가 발생했습니다: $e',
        );
      }
    }
  }

  Future<void> _onQuestTap(Quest quest) async {
    try {
      final updatedQuest = await ref
          .read(questNotifierProvider.notifier)
          .incrementQuestProgress(quest.id);

      if (mounted) {
        if (updatedQuest.isCompleted) {
          UiHelpers.showSuccessSnackBar(
            context,
            '🎉 "${updatedQuest.title}" 완료! +${updatedQuest.expReward} EXP',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        UiHelpers.showErrorSnackBar(
          context,
          '진행 업데이트 중 오류가 발생했습니다: $e',
        );
      }
    }
  }

  Future<void> _onAiSuggestTap() async {
    setState(() => _isLoadingAiSuggestions = true);

    try {
      // AI 추천 받기
      final result = await _aiDataSource.getSuggestedQuests(
        currentWeekGoal: '이번 주 목표 달성하기',  // TODO: 실제 주차 목표 가져오기
        condition: _selectedCondition.label,
      );

      if (!mounted) return;

      final suggestions = result['suggestions'] as List<dynamic>?;
      if (suggestions == null || suggestions.isEmpty) {
        throw Exception('AI 추천 결과가 없습니다');
      }

      // 모달로 결과 표시
      await AiQuestSuggestionsModal.show(
        context: context,
        suggestions: suggestions.cast<Map<String, dynamic>>(),
        onQuestSelect: (suggestion) async {
          // 퀘스트 추가
          try {
            final user = ref.read(authStateProvider).value;
            if (user == null) return;

            await ref.read(questNotifierProvider.notifier).createQuest(
                  userId: user.id,
                  title: suggestion['title'] ?? '',
                  category: QuestParsers.parseCategory(suggestion['category'] ?? '생산성'),
                  difficulty: QuestParsers.parseDifficulty(suggestion['difficulty'] ?? 'normal'),
                  targetCondition: _selectedCondition,
                  targetCount: 1,
                  description: suggestion['reason'],
                );

            if (mounted) {
              UiHelpers.showSuccessSnackBar(
                context,
                '퀘스트가 추가되었습니다',
              );
            }
          } catch (e) {
            if (mounted) {
              UiHelpers.showErrorSnackBar(
                context,
                ErrorView.getFriendlyMessage(e),
              );
            }
          }
        },
      );
    } catch (e) {
      if (mounted) {
        UiHelpers.showErrorSnackBar(
          context,
          ErrorView.getFriendlyMessage(e),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingAiSuggestions = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final authStateAsync = ref.watch(authStateProvider);
    final questsAsync = ref.watch(questNotifierProvider);

    return authStateAsync.when(
        data: (user) {
          if (user == null) {
            return const ErrorView(
              message: '로그인이 필요합니다',
              icon: Icons.lock_outline,
            );
          }

          // 퀘스트 로드 (한 번만)
          if (!_hasLoadedQuests && mounted) {
            _hasLoadedQuests = true;
            Future.microtask(() {
              if (mounted) {
                ref.read(questNotifierProvider.notifier).loadQuests(user.id);
              }
            });
          }

          return Column(
            children: [
              // 플레이어 카드
              Padding(
                padding: const EdgeInsets.all(AppConstants.spacing * 2),
                child: const PlayerCard(),
              ),

              // 컨디션 선택기
              _buildConditionSelector(),

              // 오늘 완료 통계
              _buildTodayStats(user.id),

              // AI 추천 버튼
              _buildAiSuggestionButton(),

              // 퀘스트 목록
              Expanded(
                child: questsAsync.when(
                  data: (quests) {
                    if (quests.isEmpty) {
                      return _buildEmptyState();
                    }
                    return _buildQuestList(quests);
                  },
                  loading: () => const SkeletonList(itemCount: 3),
                  error: (error, stack) => ErrorView(
                    message: ErrorView.getFriendlyMessage(error),
                    onRetry: () {
                      if (user != null) {
                        ref.read(questNotifierProvider.notifier).loadQuests(user.id);
                      }
                    },
                  ),
                ),
              ),
            ],
          );
        },
      loading: () => const LoadingView(message: '사용자 정보 확인 중...'),
      error: (error, stack) => ErrorView(
        message: ErrorView.getFriendlyMessage(error),
        onRetry: () {
          ref.invalidate(authStateProvider);
        },
      ),
    );
  }

  /// 컨디션 선택기
  Widget _buildConditionSelector() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing * 2),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '오늘의 컨디션',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: QuestCondition.values.map((condition) {
              final isSelected = _selectedCondition == condition;
              return ChoiceChip(
                label: Text(condition.label),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    _onConditionChanged(condition);
                  }
                },
                selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                checkmarkColor: AppTheme.primaryColor,
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Text(
            '컨디션에 따라 목표가 자동 조정됩니다',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  /// 오늘 완료 통계
  Widget _buildTodayStats(String userId) {
    final todayCountAsync = ref.watch(todayCompletedCountProvider(userId));

    return todayCountAsync.when(
      data: (count) {
        return Container(
          padding: const EdgeInsets.all(AppConstants.spacing * 2),
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                '오늘 완료: $count개',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  /// AI 추천 버튼
  Widget _buildAiSuggestionButton() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing * 2,
        vertical: AppConstants.spacing,
      ),
      child: ElevatedButton.icon(
        onPressed: _isLoadingAiSuggestions ? null : _onAiSuggestTap,
        icon: _isLoadingAiSuggestions
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.auto_awesome),
        label: Text(_isLoadingAiSuggestions ? 'AI 분석 중...' : 'AI 퀘스트 추천'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          backgroundColor: AppTheme.secondaryColor,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  /// 퀘스트 목록
  Widget _buildQuestList(List<Quest> quests) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppConstants.spacing * 2),
      itemCount: quests.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final quest = quests[index];
        return _buildQuestCard(quest);
      },
    );
  }

  /// 퀘스트 카드
  Widget _buildQuestCard(Quest quest) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _onQuestTap(quest),
        onLongPress: () {
          // TODO: 편집/삭제 옵션 표시
        },
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 카테고리 + 제목
              Row(
                children: [
                  Text(
                    quest.category.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      quest.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  // 난이도 표시
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(quest.difficulty)
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      quest.difficulty.label,
                      style: TextStyle(
                        fontSize: 12,
                        color: _getDifficultyColor(quest.difficulty),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              if (quest.description != null && quest.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  quest.description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],

              const SizedBox(height: 12),

              // 진행률 표시
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${quest.currentCount} / ${quest.targetCount}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              '${quest.progressPercent}%',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: quest.progress,
                          backgroundColor: AppTheme.backgroundColor,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getProgressColor(quest.progress),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 경험치 표시
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: AppTheme.secondaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${quest.expReward}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.secondaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 빈 상태 UI
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.task_alt,
            size: 80,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: 24),
          Text(
            '아직 퀘스트가 없습니다',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '+ 버튼을 눌러 첫 퀘스트를 만들어보세요!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  /// 난이도 색상
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

  /// 진행률 색상
  Color _getProgressColor(double progress) {
    if (progress < 0.3) {
      return Colors.red;
    } else if (progress < 0.7) {
      return Colors.orange;
    } else {
      return AppTheme.successColor;
    }
  }
}
