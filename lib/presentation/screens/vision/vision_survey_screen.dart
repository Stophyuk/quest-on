import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quest_on/core/theme/app_theme.dart';
import 'package:quest_on/core/constants/app_constants.dart';
import 'package:quest_on/presentation/providers/auth_provider.dart';
import 'package:quest_on/presentation/providers/vision_provider.dart';

/// 비전 설문 화면 (4단계)
class VisionSurveyScreen extends ConsumerStatefulWidget {
  const VisionSurveyScreen({super.key});

  @override
  ConsumerState<VisionSurveyScreen> createState() =>
      _VisionSurveyScreenState();
}

class _VisionSurveyScreenState extends ConsumerState<VisionSurveyScreen> {
  final _pageController = PageController();
  int _currentStep = 0;

  // 설문 데이터
  String _name = '';
  final List<String> _selectedValues = [];
  String _customValue = '';
  bool _showCustomValue = false;
  String _goal = '';
  final List<String> _selectedReasons = [];
  String _customReason = '';
  bool _showCustomReason = false;

  // 가치관 선택지
  final List<String> _valueOptions = [
    '성장',
    '관계',
    '건강',
    '자유',
    '성취',
    '안정',
    '창의성',
    '기여',
  ];

  // 이유 선택지
  final List<String> _reasonOptions = [
    '자기계발',
    '경력 발전',
    '건강 개선',
    '관계 개선',
    '재정 안정',
    '행복 추구',
    '사회 기여',
    '자아실현',
  ];

  bool get _canProceedFromStep0 => _name.trim().isNotEmpty;

  bool get _canProceedFromStep1 {
    if (_showCustomValue) {
      return _customValue.trim().isNotEmpty;
    }
    return _selectedValues.isNotEmpty;
  }

  bool get _canProceedFromStep2 => _goal.trim().isNotEmpty;

  bool get _canProceedFromStep3 {
    if (_showCustomReason) {
      return _customReason.trim().isNotEmpty;
    }
    return _selectedReasons.isNotEmpty;
  }

  void _nextStep() {
    if (_currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    } else {
      _submitSurvey();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    }
  }

  Future<void> _submitSurvey() async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    // 최종 가치관 리스트 (기타 포함)
    final finalValues = _showCustomValue
        ? [_customValue.trim()]
        : List<String>.from(_selectedValues);

    // 최종 이유 리스트 (기타 포함)
    final finalReasons = _showCustomReason
        ? [_customReason.trim()]
        : List<String>.from(_selectedReasons);

    try {
      await ref.read(visionNotifierProvider.notifier).createProfile(
            userId: user.id,
            name: _name.trim(),
            values: finalValues,
            goal: _goal.trim(),
            reasons: finalReasons,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('설문이 완료되었습니다!'),
            backgroundColor: AppTheme.successColor,
          ),
        );

        // AI 코칭 생성 화면으로 이동
        Navigator.of(context).pushReplacementNamed('/vision/coaching');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('비전 설문 (${_currentStep + 1}/4)'),
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousStep,
              )
            : null,
      ),
      body: Column(
        children: [
          // 진행 표시기
          LinearProgressIndicator(
            value: (_currentStep + 1) / 4,
            backgroundColor: AppTheme.backgroundColor,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppTheme.primaryColor,
            ),
          ),

          // 설문 페이지
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1(), // 이름
                _buildStep2(), // 가치관
                _buildStep3(), // 목표
                _buildStep4(), // 이유
              ],
            ),
          ),

          // 다음 버튼
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacing * 2),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canProceed() ? _nextStep : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    _currentStep == 3 ? '완료' : '다음',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _canProceedFromStep0;
      case 1:
        return _canProceedFromStep1;
      case 2:
        return _canProceedFromStep2;
      case 3:
        return _canProceedFromStep3;
      default:
        return false;
    }
  }

  // Step 1: 이름 입력
  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacing * 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            '당신의 이름을 알려주세요',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            '개인화된 코칭을 제공하기 위해 필요합니다',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 32),
          TextField(
            autofocus: true,
            decoration: const InputDecoration(
              labelText: '이름',
              hintText: '홍길동',
              prefixIcon: Icon(Icons.person_outline),
            ),
            onChanged: (value) {
              setState(() => _name = value);
            },
          ),
        ],
      ),
    );
  }

  // Step 2: 가치관 선택
  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacing * 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            '당신이 중요하게 생각하는 가치는?',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            '최대 3개까지 선택할 수 있습니다',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 32),

          // 가치관 선택지
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _valueOptions.map((value) {
              final isSelected = _selectedValues.contains(value);
              return ChoiceChip(
                label: Text(value),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected && _selectedValues.length < 3) {
                      _selectedValues.add(value);
                      _showCustomValue = false;
                    } else if (!selected) {
                      _selectedValues.remove(value);
                    }
                  });
                },
                selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                checkmarkColor: AppTheme.primaryColor,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // 기타 입력
          CheckboxListTile(
            value: _showCustomValue,
            onChanged: (value) {
              setState(() {
                _showCustomValue = value ?? false;
                if (_showCustomValue) {
                  _selectedValues.clear();
                }
              });
            },
            title: const Text('기타 (직접 입력)'),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          if (_showCustomValue) ...[
            const SizedBox(height: 8),
            TextField(
              autofocus: true,
              maxLength: 10,
              decoration: const InputDecoration(
                labelText: '가치관',
                hintText: '예: 배움',
                counterText: '',
              ),
              onChanged: (value) {
                setState(() => _customValue = value);
              },
            ),
            const SizedBox(height: 4),
            Text(
              '${_customValue.length}/10',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  // Step 3: 목표 입력
  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacing * 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            '어떤 목표를 이루고 싶으신가요?',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            '구체적으로 작성할수록 좋습니다',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 32),
          TextField(
            autofocus: true,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: '목표',
              hintText: '예: 6개월 안에 건강한 생활습관 만들기',
              alignLabelWithHint: true,
            ),
            onChanged: (value) {
              setState(() => _goal = value);
            },
          ),
        ],
      ),
    );
  }

  // Step 4: 이유 선택
  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacing * 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            '이 목표를 달성하려는 이유는?',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            '최대 3개까지 선택할 수 있습니다',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 32),

          // 이유 선택지
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _reasonOptions.map((reason) {
              final isSelected = _selectedReasons.contains(reason);
              return ChoiceChip(
                label: Text(reason),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected && _selectedReasons.length < 3) {
                      _selectedReasons.add(reason);
                      _showCustomReason = false;
                    } else if (!selected) {
                      _selectedReasons.remove(reason);
                    }
                  });
                },
                selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                checkmarkColor: AppTheme.primaryColor,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // 기타 입력
          CheckboxListTile(
            value: _showCustomReason,
            onChanged: (value) {
              setState(() {
                _showCustomReason = value ?? false;
                if (_showCustomReason) {
                  _selectedReasons.clear();
                }
              });
            },
            title: const Text('기타 (직접 입력)'),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          if (_showCustomReason) ...[
            const SizedBox(height: 8),
            TextField(
              autofocus: true,
              maxLength: 20,
              decoration: const InputDecoration(
                labelText: '이유',
                hintText: '예: 더 나은 삶을 위해',
                counterText: '',
              ),
              onChanged: (value) {
                setState(() => _customReason = value);
              },
            ),
            const SizedBox(height: 4),
            Text(
              '${_customReason.length}/20',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}
