import 'package:flutter/material.dart';
import 'package:quest_on/core/theme/app_theme.dart';
import 'package:quest_on/core/utils/quest_parsers.dart';
import 'package:quest_on/domain/entities/quest.dart';

/// AI 퀘스트 추천 결과 모달
class AiQuestSuggestionsModal extends StatefulWidget {
  final List<Map<String, dynamic>> suggestions;
  final Function(List<Map<String, dynamic>>) onQuestsSelect;
  final Function()? onRefresh;

  const AiQuestSuggestionsModal({
    super.key,
    required this.suggestions,
    required this.onQuestsSelect,
    this.onRefresh,
  });

  static Future<void> show({
    required BuildContext context,
    required List<Map<String, dynamic>> suggestions,
    required Function(List<Map<String, dynamic>>) onQuestsSelect,
    Function()? onRefresh,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AiQuestSuggestionsModal(
        suggestions: suggestions,
        onQuestsSelect: onQuestsSelect,
        onRefresh: onRefresh,
      ),
    );
  }

  @override
  State<AiQuestSuggestionsModal> createState() => _AiQuestSuggestionsModalState();
}

class _AiQuestSuggestionsModalState extends State<AiQuestSuggestionsModal> {
  final Set<int> _selectedIndices = {};

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // 핸들
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // 헤더
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryColor.withValues(alpha: 0.08),
                      AppTheme.secondaryColor.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor,
                            AppTheme.secondaryColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI 퀘스트 추천',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '원하는 퀘스트를 선택하세요',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close, size: 24),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ),

              // 추천 목록
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: widget.suggestions.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final suggestion = widget.suggestions[index];
                    final isSelected = _selectedIndices.contains(index);
                    return _buildSuggestionCard(context, suggestion, index, isSelected);
                  },
                ),
              ),

              // 하단 추가 버튼
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_selectedIndices.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            '${_selectedIndices.length}개 선택됨',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _selectedIndices.isEmpty
                              ? null
                              : () {
                                  final selectedQuests = _selectedIndices
                                      .map((index) => widget.suggestions[index])
                                      .toList();
                                  widget.onQuestsSelect(selectedQuests);
                                  Navigator.of(context).pop();
                                },
                          icon: const Icon(Icons.add_task),
                          label: Text(
                            _selectedIndices.isEmpty
                                ? '퀘스트를 선택하세요'
                                : '선택한 퀘스트 추가 (${_selectedIndices.length}개)',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: _selectedIndices.isEmpty
                                ? Colors.grey
                                : AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      // 다시 추천받기 버튼
                      if (widget.onRefresh != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: SizedBox(
                            width: double.infinity,
                            child: TextButton.icon(
                              onPressed: widget.onRefresh,
                              icon: const Icon(
                                Icons.refresh,
                                size: 20,
                              ),
                              label: const Text(
                                '다시 추천받기',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                foregroundColor: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSuggestionCard(
    BuildContext context,
    Map<String, dynamic> suggestion,
    int index,
    bool isSelected,
  ) {
    final difficulty = QuestParsers.parseDifficulty(suggestion['difficulty'] ?? 'normal');
    final category = QuestParsers.parseCategory(suggestion['category'] ?? '생산성');

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.5)
              : AppTheme.primaryColor.withValues(alpha: 0.1),
          width: isSelected ? 2 : 1.5,
        ),
      ),
      color: isSelected
          ? AppTheme.primaryColor.withValues(alpha: 0.05)
          : Colors.white,
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedIndices.remove(index);
            } else {
              _selectedIndices.add(index);
            }
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목 + 난이도 + 카테고리 + 체크박스
              Row(
                children: [
                  // 체크박스
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryColor : Colors.grey,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    category.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      suggestion['title'] ?? '',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(difficulty).withValues(alpha: AppTheme.opacityMedium),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      difficulty.label,
                      style: TextStyle(
                        fontSize: 12,
                        color: _getDifficultyColor(difficulty),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              // 예상 시간
              if (suggestion['estimatedTime'] != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '약 ${suggestion['estimatedTime']}분',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],

              // 추천 이유
              if (suggestion['reason'] != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            size: 16,
                            color: AppTheme.primaryColor,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '추천 이유',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        suggestion['reason'] ?? '',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Stacking Tip
              if (suggestion['stackingTip'] != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.link,
                      size: 14,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        suggestion['stackingTip'] ?? '',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
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
