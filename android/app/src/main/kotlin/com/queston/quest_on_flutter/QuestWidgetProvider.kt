package com.queston.quest_on_flutter

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import java.text.SimpleDateFormat
import java.util.*

class QuestWidgetProvider : AppWidgetProvider() {

    companion object {
        private const val WIDGET_KEY_QUEST_COUNT = "quest_count"
        private const val WIDGET_KEY_COMPLETED_COUNT = "completed_count"
        private const val WIDGET_KEY_QUEST_LIST = "quest_list"
        private const val WIDGET_KEY_LAST_UPDATE = "last_update"
        private const val MAX_QUEST_DISPLAY = 5
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        appWidgetIds.forEach { appWidgetId ->
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val widgetData = HomeWidgetPlugin.getData(context)
        val views = RemoteViews(context.packageName, R.layout.quest_widget)

        // Get widget data
        val questCount = widgetData.getInt(WIDGET_KEY_QUEST_COUNT, 0)
        val completedCount = widgetData.getInt(WIDGET_KEY_COMPLETED_COUNT, 0)
        val questListData = widgetData.getString(WIDGET_KEY_QUEST_LIST) ?: ""
        val lastUpdate = widgetData.getString(WIDGET_KEY_LAST_UPDATE) ?: ""

        // Update count text
        views.setTextViewText(
            R.id.quest_count_text,
            "$completedCount / $questCount"
        )

        // Update quest list
        val questListText = buildQuestListText(questListData)
        views.setTextViewText(
            R.id.quest_list_text,
            questListText
        )

        // Update last update time
        val formattedTime = formatLastUpdateTime(lastUpdate)
        views.setTextViewText(
            R.id.last_update_text,
            "최근 업데이트: $formattedTime"
        )

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    private fun buildQuestListText(questListData: String): String {
        if (questListData.isEmpty()) {
            return "퀘스트가 없습니다.\n앱에서 퀘스트를 추가해보세요!"
        }

        val quests = questListData.split(";")
        val questTexts = mutableListOf<String>()

        for (quest in quests.take(MAX_QUEST_DISPLAY)) {
            val parts = quest.split("|")
            if (parts.size == 3) {
                val title = parts[0]
                val category = parts[1]
                val progress = parts[2]
                questTexts.add("$category $title ($progress%)")
            }
        }

        return if (questTexts.isEmpty()) {
            "퀘스트를 불러오는 중..."
        } else {
            questTexts.joinToString("\n")
        }
    }

    private fun formatLastUpdateTime(isoTime: String): String {
        if (isoTime.isEmpty()) {
            return "--"
        }

        return try {
            val isoFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault())
            val displayFormat = SimpleDateFormat("HH:mm", Locale.getDefault())
            val date = isoFormat.parse(isoTime)
            date?.let { displayFormat.format(it) } ?: "--"
        } catch (e: Exception) {
            "--"
        }
    }
}
