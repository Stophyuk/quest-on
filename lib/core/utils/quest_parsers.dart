import '../../domain/entities/quest.dart';

/// Quest 관련 파싱 유틸리티
///
/// Agent-Full.md 원칙:
/// - DRY (Don't Repeat Yourself): 중복 코드 제거
/// - 단일 책임 원칙: 각 함수는 하나의 파싱만 담당
class QuestParsers {
  QuestParsers._(); // Private constructor to prevent instantiation

  /// 한글 카테고리명을 QuestCategory enum으로 변환
  ///
  /// 지원 카테고리:
  /// - '생산성', '업무' → QuestCategory.work
  /// - '학습', '공부' → QuestCategory.study
  /// - '건강' → QuestCategory.health
  /// - '관계' → QuestCategory.relationship
  /// - '취미' → QuestCategory.hobby
  /// - '성장' → QuestCategory.growth
  ///
  /// 기본값: QuestCategory.other
  static QuestCategory parseCategory(String category) {
    switch (category.trim()) {
      case '생산성':
      case '업무':
        return QuestCategory.work;
      case '학습':
      case '공부':
        return QuestCategory.study;
      case '건강':
        return QuestCategory.health;
      case '관계':
        return QuestCategory.relationship;
      case '취미':
        return QuestCategory.hobby;
      case '성장':
        return QuestCategory.growth;
      default:
        return QuestCategory.other;
    }
  }

  /// 난이도 문자열을 QuestDifficulty enum으로 변환
  ///
  /// 지원 난이도:
  /// - 'easy' → QuestDifficulty.easy
  /// - 'normal' → QuestDifficulty.normal
  /// - 'hard' → QuestDifficulty.hard
  /// - 'veryhard', 'very_hard' → QuestDifficulty.veryHard
  ///
  /// 기본값: QuestDifficulty.normal
  /// 대소문자 구분 없음
  static QuestDifficulty parseDifficulty(String difficulty) {
    switch (difficulty.toLowerCase().trim()) {
      case 'easy':
        return QuestDifficulty.easy;
      case 'normal':
        return QuestDifficulty.normal;
      case 'hard':
        return QuestDifficulty.hard;
      case 'veryhard':
      case 'very_hard':
        return QuestDifficulty.veryHard;
      default:
        return QuestDifficulty.normal;
    }
  }

  /// QuestCategory를 한글 문자열로 변환
  static String categoryToString(QuestCategory category) {
    switch (category) {
      case QuestCategory.work:
        return '생산성';
      case QuestCategory.study:
        return '학습';
      case QuestCategory.health:
        return '건강';
      case QuestCategory.relationship:
        return '관계';
      case QuestCategory.hobby:
        return '취미';
      case QuestCategory.growth:
        return '성장';
      case QuestCategory.other:
        return '기타';
    }
  }

  /// QuestDifficulty를 표시용 문자열로 변환
  static String difficultyToString(QuestDifficulty difficulty) {
    switch (difficulty) {
      case QuestDifficulty.easy:
        return '쉬움';
      case QuestDifficulty.normal:
        return '보통';
      case QuestDifficulty.hard:
        return '어려움';
      case QuestDifficulty.veryHard:
        return '매우 어려움';
    }
  }
}
