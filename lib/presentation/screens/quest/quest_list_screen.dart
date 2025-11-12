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
import 'package:quest_on/presentation/providers/vision_provider.dart';
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
  // Agent-Quick.md: Magic String 제거
  static const String _defaultWeekGoal = '이번 주 목표 달성하기';

  bool _hasLoadedQuests = false;
  bool _isLoadingAiSuggestions = false;
  final AiRemoteDataSource _aiDataSource = AiRemoteDataSource();

  // AI 추천 캐싱
  List<Map<String, dynamic>>? _cachedSuggestions; // 캐시된 추천 목록
  Set<String> _addedQuestTitles = {}; // 이미 추가한 퀘스트 제목들

  @override
  void initState() {
    super.initState();
    // 퀘스트 로드는 build에서 authState를 listen하여 처리
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
          '앗, 잠시 문제가 생겼어요. 다시 시도해주세요 🙏',
        );
      }
    }
  }

  /// 현재 주차 목표 가져오기 (Profile에서)
  /// Agent-Quick.md: 동사로 시작, Early Return 패턴
  String _getCurrentWeekGoal() {
    final user = ref.read(authStateProvider).value;
    if (user == null) return _defaultWeekGoal;

    // profileProvider.family 사용
    final profileAsync = ref.read(profileProvider(user.id));
    return profileAsync.when(
      data: (profile) => profile?.goal ?? _defaultWeekGoal,
      loading: () => _defaultWeekGoal,
      error: (_, __) => _defaultWeekGoal,
    );
  }

  Future<void> _onAiSuggestTap() async {
    // 캐시가 있고 이미 추가하지 않은 항목이 있으면 캐시 사용
    if (_cachedSuggestions != null) {
      final availableSuggestions = _cachedSuggestions!
          .where((s) => !_addedQuestTitles.contains(s['title']))
          .toList();

      if (availableSuggestions.isNotEmpty) {
        await _showSuggestionsModal(availableSuggestions);
        return;
      }
    }

    // 캐시가 없거나 모두 추가된 경우 새로 요청
    await _fetchNewSuggestions();
  }

  /// AI로부터 새로운 추천 받기
  Future<void> _fetchNewSuggestions() async {
    setState(() => _isLoadingAiSuggestions = true);

    try {
      final currentGoal = _getCurrentWeekGoal();
      final result = await _aiDataSource.getSuggestedQuests(
        currentWeekGoal: currentGoal,
      );

      if (!mounted) return;

      final suggestions = result['suggestions'] as List<dynamic>?;
      if (suggestions == null || suggestions.isEmpty) {
        throw Exception('AI 추천 결과가 없습니다');
      }

      // 캐시 저장 및 추가된 퀘스트 초기화
      _cachedSuggestions = suggestions.cast<Map<String, dynamic>>();
      _addedQuestTitles.clear();

      await _showSuggestionsModal(_cachedSuggestions!);
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

  /// 추천 모달 표시
  Future<void> _showSuggestionsModal(List<Map<String, dynamic>> suggestions) async {
    await AiQuestSuggestionsModal.show(
      context: context,
      suggestions: suggestions,
      onQuestsSelect: (selectedSuggestions) async {
        // 선택된 퀘스트들 추가
        try {
          final user = ref.read(authStateProvider).value;
          if (user == null) return;

          int successCount = 0;
          for (final suggestion in selectedSuggestions) {
            try {
              await ref.read(questNotifierProvider.notifier).createQuest(
                    userId: user.id,
                    title: suggestion['title'] ?? '',
                    category: QuestParsers.parseCategory(suggestion['category'] ?? '생산성'),
                    difficulty: QuestParsers.parseDifficulty(suggestion['difficulty'] ?? 'normal'),
                    targetCount: 1,
                    description: suggestion['reason'],
                  );

              // 추가한 퀘스트 제목 기록
              _addedQuestTitles.add(suggestion['title'] ?? '');
              successCount++;
            } catch (e) {
              print('퀘스트 추가 실패: ${suggestion['title']}, 에러: $e');
            }
          }

          if (mounted) {
            if (successCount > 0) {
              UiHelpers.showSuccessSnackBar(
                context,
                '$successCount개의 퀘스트가 추가되었습니다',
              );
            } else {
              UiHelpers.showErrorSnackBar(
                context,
                '퀘스트 추가 중 오류가 발생했습니다',
              );
            }
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
      onRefresh: () async {
        // 다시 추천받기
        Navigator.of(context).pop(); // 모달 닫기
        await _fetchNewSuggestions();
      },
    );
  }

  /// 퀘스트 옵션 표시 (편집/삭제)
  void _showQuestOptions(Quest quest) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: AppTheme.primaryColor),
              title: const Text('퀘스트 편집'),
              onTap: () {
                Navigator.pop(context);
                _onQuestEdit(quest);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppTheme.errorColor),
              title: const Text('퀘스트 삭제'),
              onTap: () {
                Navigator.pop(context);
                _onQuestDelete(quest);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 퀘스트 편집
  Future<void> _onQuestEdit(Quest quest) async {
    await context.push('/quest/add', extra: quest);
  }

  /// 퀘스트 삭제
  Future<void> _onQuestDelete(Quest quest) async {
    final confirmed = await UiHelpers.showConfirmDialog(
      context,
      title: '퀘스트 삭제',
      message: '"${quest.title}" 퀘스트를 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.',
      confirmText: '삭제',
      cancelText: '취소',
    );

    if (confirmed == true) {
      try {
        await ref.read(questNotifierProvider.notifier).deleteQuest(quest.id);
        if (mounted) {
          UiHelpers.showSuccessSnackBar(context, '다음 기회에 도전해요! 💪');
        }
      } catch (e) {
        if (mounted) {
          UiHelpers.showErrorSnackBar(context, '앗, 잠시 문제가 생겼어요. 다시 시도해주세요 🙏');
        }
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
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing * 2,
        vertical: AppConstants.spacing,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isLoadingAiSuggestions
              ? [Colors.grey, Colors.grey.shade400]
              : [AppTheme.primaryColor, AppTheme.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: _isLoadingAiSuggestions
            ? []
            : [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoadingAiSuggestions ? null : _onAiSuggestTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoadingAiSuggestions)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 24,
                  ),
                const SizedBox(width: 12),
                Text(
                  _isLoadingAiSuggestions ? 'AI 분석 중...' : 'AI 퀘스트 추천받기',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
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
        onLongPress: () => _showQuestOptions(quest),
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
