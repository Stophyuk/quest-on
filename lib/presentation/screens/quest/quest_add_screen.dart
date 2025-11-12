import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quest_on/core/theme/app_theme.dart';
import 'package:quest_on/core/constants/app_constants.dart';
import 'package:quest_on/core/utils/ui_helpers.dart';
import 'package:quest_on/domain/entities/quest.dart';
import 'package:quest_on/presentation/providers/auth_provider.dart';
import 'package:quest_on/presentation/providers/quest_provider.dart';

/// 퀘스트 추가/편집 화면
class QuestAddScreen extends ConsumerStatefulWidget {
  final Quest? quest; // null이면 추가 모드, 값이 있으면 편집 모드

  const QuestAddScreen({super.key, this.quest});

  @override
  ConsumerState<QuestAddScreen> createState() => _QuestAddScreenState();
}

class _QuestAddScreenState extends ConsumerState<QuestAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetCountController = TextEditingController(text: '5');

  QuestCategory _selectedCategory = QuestCategory.health;
  QuestDifficulty _selectedDifficulty = QuestDifficulty.normal;

  bool _isLoading = false;

  bool get _isEditMode => widget.quest != null;

  @override
  void initState() {
    super.initState();
    // 편집 모드일 경우 초기값 설정
    if (_isEditMode) {
      final quest = widget.quest!;
      _titleController.text = quest.title;
      _descriptionController.text = quest.description ?? '';
      _targetCountController.text = quest.targetCount.toString();
      _selectedCategory = quest.category;
      _selectedDifficulty = quest.difficulty;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetCountController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = ref.read(authStateProvider).value;
    if (user == null) {
      UiHelpers.showErrorSnackBar(context, '로그인이 필요합니다');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final targetCount = int.parse(_targetCountController.text);

      if (_isEditMode) {
        // 편집 모드: 기존 퀘스트 업데이트
        final updatedQuest = widget.quest!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          category: _selectedCategory,
          difficulty: _selectedDifficulty,
          targetCount: targetCount,
        );

        await ref.read(questNotifierProvider.notifier).updateQuest(updatedQuest);

        if (mounted) {
          UiHelpers.showSuccessSnackBar(context, '퀘스트를 업데이트했어요! 💫');
          context.pop();
        }
      } else {
        // 추가 모드: 새 퀘스트 생성
        await ref.read(questNotifierProvider.notifier).createQuest(
              userId: user.id,
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
              category: _selectedCategory,
              difficulty: _selectedDifficulty,
              targetCount: targetCount,
            );

        if (mounted) {
          UiHelpers.showSuccessSnackBar(context, '새 모험이 시작되었어요! ✨');
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        final action = _isEditMode ? '수정' : '추가';
        UiHelpers.showErrorSnackBar(context, '앗, 잠시 문제가 생겼어요. 다시 시도해주세요 🙏');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 예상 경험치 계산
    final targetCount = int.tryParse(_targetCountController.text) ?? 5;
    final expectedExp = _selectedDifficulty.calculateExp(targetCount);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? '퀘스트 편집' : '퀘스트 추가'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppConstants.spacing * 2),
            children: [
              // 제목
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '퀘스트 제목 *',
                  hintText: '예: 아침 조깅하기',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '제목을 입력해주세요';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),

              // 설명 (선택)
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '설명 (선택)',
                  hintText: '예: 30분 이상 조깅하기',
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 24),

              // 카테고리 선택
              Text(
                '카테고리',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: QuestCategory.values.map((category) {
                  final isSelected = _selectedCategory == category;
                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(category.emoji),
                        const SizedBox(width: 4),
                        Text(category.label),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      }
                    },
                    selectedColor: AppTheme.primaryColor.withValues(alpha: AppTheme.opacityMedium),
                    checkmarkColor: AppTheme.primaryColor,
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // 난이도 선택
              Text(
                '난이도',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: QuestDifficulty.values.map((difficulty) {
                  final isSelected = _selectedDifficulty == difficulty;
                  return ChoiceChip(
                    label: Text(difficulty.label),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedDifficulty = difficulty;
                        });
                      }
                    },
                    selectedColor: AppTheme.primaryColor.withValues(alpha: AppTheme.opacityMedium),
                    checkmarkColor: AppTheme.primaryColor,
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // 목표 횟수
              TextFormField(
                controller: _targetCountController,
                decoration: const InputDecoration(
                  labelText: '목표 횟수 *',
                  hintText: '예: 5',
                  prefixIcon: Icon(Icons.flag),
                  suffixText: '회',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '목표 횟수를 입력해주세요';
                  }
                  final count = int.tryParse(value);
                  if (count == null || count <= 0) {
                    return '1 이상의 숫자를 입력해주세요';
                  }
                  return null;
                },
                onChanged: (value) {
                  // 경험치 계산을 위해 setState 호출
                  setState(() {});
                },
              ),
              const SizedBox(height: 32),

              // 예상 보상 표시
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor.withValues(alpha: AppTheme.opacityLight),
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  border: Border.all(
                    color: AppTheme.secondaryColor.withValues(alpha: AppTheme.opacityMedium),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: AppTheme.secondaryColor,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '예상 경험치 보상',
                            style:
                                Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '+$expectedExp EXP',
                            style:
                                Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: AppTheme.secondaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 제출 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _onSubmit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          _isEditMode ? '퀘스트 수정' : '퀘스트 추가',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
