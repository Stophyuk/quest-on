import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// UI 관련 헬퍼 함수 모음
///
/// Agent-Full.md 원칙:
/// - DRY: 반복되는 UI 패턴을 재사용 가능한 함수로 추출
/// - 단일 책임: 각 함수는 하나의 UI 작업만 수행
class UiHelpers {
  UiHelpers._(); // Private constructor to prevent instantiation

  /// 성공 메시지 SnackBar 표시
  ///
  /// 녹색 배경의 SnackBar를 표시합니다.
  ///
  /// Example:
  /// ```dart
  /// UiHelpers.showSuccessSnackBar(context, '저장되었습니다');
  /// ```
  static void showSuccessSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 에러 메시지 SnackBar 표시
  ///
  /// 빨간색 배경의 SnackBar를 표시합니다.
  ///
  /// Example:
  /// ```dart
  /// UiHelpers.showErrorSnackBar(context, '오류가 발생했습니다');
  /// ```
  static void showErrorSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 정보 메시지 SnackBar 표시
  ///
  /// 파란색 배경의 SnackBar를 표시합니다.
  ///
  /// Example:
  /// ```dart
  /// UiHelpers.showInfoSnackBar(context, '알림: 새로운 퀘스트가 있습니다');
  /// ```
  static void showInfoSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue.shade700,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 경고 메시지 SnackBar 표시
  ///
  /// 주황색 배경의 SnackBar를 표시합니다.
  ///
  /// Example:
  /// ```dart
  /// UiHelpers.showWarningSnackBar(context, '경고: 저장되지 않은 변경사항이 있습니다');
  /// ```
  static void showWarningSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange.shade700,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 커스텀 SnackBar 표시
  ///
  /// 색상과 지속시간을 직접 지정할 수 있습니다.
  ///
  /// Example:
  /// ```dart
  /// UiHelpers.showCustomSnackBar(
  ///   context,
  ///   '커스텀 메시지',
  ///   backgroundColor: Colors.purple,
  ///   duration: Duration(seconds: 5),
  /// );
  /// ```
  static void showCustomSnackBar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration? duration,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor ?? Colors.grey.shade800,
        duration: duration ?? const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 로딩 다이얼로그 표시
  ///
  /// 닫을 때는 Navigator.pop(context) 사용
  ///
  /// Example:
  /// ```dart
  /// UiHelpers.showLoadingDialog(context, message: '처리 중...');
  /// // 작업 수행
  /// Navigator.pop(context);
  /// ```
  static void showLoadingDialog(
    BuildContext context, {
    String message = '처리 중...',
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      ),
    );
  }

  /// 확인 다이얼로그 표시
  ///
  /// 사용자의 확인을 받습니다.
  /// 반환값: true = 확인, false/null = 취소
  ///
  /// Example:
  /// ```dart
  /// final confirmed = await UiHelpers.showConfirmDialog(
  ///   context,
  ///   title: '삭제 확인',
  ///   message: '정말 삭제하시겠습니까?',
  /// );
  /// if (confirmed == true) {
  ///   // 삭제 로직
  /// }
  /// ```
  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = '확인',
    String cancelText = '취소',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}
