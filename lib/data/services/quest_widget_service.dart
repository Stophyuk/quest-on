import 'package:home_widget/home_widget.dart';
import 'package:quest_on/domain/entities/quest.dart';

/// 퀘스트 홈 위젯 서비스
/// 홈 스크린 위젯에 퀘스트 데이터를 업데이트하는 서비스
class QuestWidgetService {
  QuestWidgetService._(); // Private constructor for singleton

  // Widget keys
  static const String widgetKeyQuestCount = 'quest_count';
  static const String widgetKeyCompletedCount = 'completed_count';
  static const String widgetKeyQuestList = 'quest_list';
  static const String widgetKeyLastUpdate = 'last_update';

  // Widget configuration
  static const int maxQuestsInWidget = 5;
  static const String widgetNameAndroid = 'QuestWidgetProvider';

  /// 오늘의 퀘스트를 위젯에 업데이트
  ///
  /// [quests] 오늘의 활성 퀘스트 목록
  static Future<void> updateTodayQuests(List<Quest> quests) async {
    // Early return if no quests
    if (quests.isEmpty) {
      await _clearWidgetData();
      return;
    }

    // Filter active quests and limit to maxQuestsInWidget
    final activeQuests = quests
        .where((quest) => quest.isActive)
        .take(maxQuestsInWidget)
        .toList();

    // Calculate statistics
    final totalCount = activeQuests.length;
    final completedCount = activeQuests.where((q) => q.isCompleted).length;

    // Prepare quest list data for widget
    final questListData = _buildQuestListData(activeQuests);

    // Update widget data
    await HomeWidget.saveWidgetData<int>(widgetKeyQuestCount, totalCount);
    await HomeWidget.saveWidgetData<int>(widgetKeyCompletedCount, completedCount);
    await HomeWidget.saveWidgetData<String>(widgetKeyQuestList, questListData);
    await HomeWidget.saveWidgetData<String>(
      widgetKeyLastUpdate,
      DateTime.now().toIso8601String(),
    );

    // Update widget UI
    await HomeWidget.updateWidget(
      androidName: widgetNameAndroid,
    );
  }

  /// 퀘스트 목록을 위젯용 문자열로 변환
  ///
  /// Format: "title1|category1|progress1;title2|category2|progress2;..."
  static String _buildQuestListData(List<Quest> quests) {
    return quests.map((quest) {
      final title = quest.title;
      final category = quest.category.emoji;
      final progress = quest.progressPercent;
      return '$title|$category|$progress';
    }).join(';');
  }

  /// 위젯 데이터 초기화
  static Future<void> _clearWidgetData() async {
    await HomeWidget.saveWidgetData<int>(widgetKeyQuestCount, 0);
    await HomeWidget.saveWidgetData<int>(widgetKeyCompletedCount, 0);
    await HomeWidget.saveWidgetData<String>(widgetKeyQuestList, '');
    await HomeWidget.saveWidgetData<String>(
      widgetKeyLastUpdate,
      DateTime.now().toIso8601String(),
    );

    await HomeWidget.updateWidget(
      androidName: widgetNameAndroid,
    );
  }

  /// 위젯 초기화 (앱 시작 시 호출)
  static Future<void> initialize() async {
    await HomeWidget.setAppGroupId('group.quest_on');
  }
}
