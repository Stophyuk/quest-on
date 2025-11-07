import 'package:flutter/material.dart';
import 'package:quest_on/core/theme/app_theme.dart';

/// 에러 표시 위젯 (재시도 기능 포함)
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  /// 에러 객체로부터 사용자 친화적인 메시지 생성
  static String getFriendlyMessage(Object error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') || errorString.contains('connection')) {
      return '인터넷 연결을 확인해주세요';
    } else if (errorString.contains('timeout')) {
      return '요청 시간이 초과되었습니다';
    } else if (errorString.contains('auth') || errorString.contains('unauthorized')) {
      return '인증에 실패했습니다. 다시 로그인해주세요';
    } else if (errorString.contains('not found') || errorString.contains('404')) {
      return '데이터를 찾을 수 없습니다';
    } else if (errorString.contains('server') || errorString.contains('500')) {
      return '서버 오류가 발생했습니다';
    } else {
      return '오류가 발생했습니다';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 에러 아이콘
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: AppTheme.errorColor,
              ),
            ),
            const SizedBox(height: 24),

            // 에러 메시지
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textPrimary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // 재시도 버튼
            if (onRetry != null)
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('다시 시도'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 간단한 에러 카드 위젯
class ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorCard({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.errorColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: AppTheme.errorColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: AppTheme.errorColor),
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.refresh),
                color: AppTheme.errorColor,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
