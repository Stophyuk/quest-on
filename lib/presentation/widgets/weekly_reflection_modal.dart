import 'package:flutter/material.dart';
import 'package:quest_on/core/theme/app_theme.dart';

/// 주간 회고 모달
class WeeklyReflectionModal extends StatelessWidget {
  final int completedQuests;
  final int totalExp;
  final double completionRate;

  const WeeklyReflectionModal({
    super.key,
    required this.completedQuests,
    required this.totalExp,
    required this.completionRate,
  });

  /// 모달 표시
  static Future<void> show({
    required BuildContext context,
    required int completedQuests,
    required int totalExp,
    required double completionRate,
  }) {
    return showDialog(
      context: context,
      builder: (context) => WeeklyReflectionModal(
        completedQuests: completedQuests,
        totalExp: totalExp,
        completionRate: completionRate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 헤더
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.calendar_today,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      '주간 회고',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 통계 카드
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.secondaryColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // 완료한 퀘스트
                    _buildStatRow(
                      icon: Icons.check_circle,
                      label: '완료한 퀘스트',
                      value: '$completedQuests개',
                    ),
                    const SizedBox(height: 16),

                    // 획득한 경험치
                    _buildStatRow(
                      icon: Icons.star,
                      label: '획득한 경험치',
                      value: '+$totalExp XP',
                    ),
                    const SizedBox(height: 16),

                    // 달성률
                    _buildStatRow(
                      icon: Icons.trending_up,
                      label: '달성률',
                      value: '${(completionRate * 100).toStringAsFixed(1)}%',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 메시지
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getEncouragementMessage(),
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),

              // 확인 버튼
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '다음 주도 화이팅!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _getEncouragementMessage() {
    if (completionRate >= 0.8) {
      return '정말 멋져요! 이번 주도 목표를 잘 달성했습니다. 다음 주에도 이 기세를 이어가보세요!';
    } else if (completionRate >= 0.5) {
      return '좋아요! 꾸준히 노력하고 있네요. 다음 주에는 조금 더 도전해볼까요?';
    } else if (completionRate >= 0.3) {
      return '괜찮아요. 시작이 반이에요. 다음 주에는 작은 목표부터 하나씩 달성해보세요!';
    } else {
      return '힘든 한 주였나요? 완벽하지 않아도 괜찮아요. 다음 주에는 달성 가능한 작은 목표부터 시작해보세요!';
    }
  }
}
