import { LocalNotifications } from '@capacitor/local-notifications'
import { Capacitor } from '@capacitor/core'

const isNativePlatform = Capacitor.isNativePlatform()

/**
 * 로컬 알림 유틸리티
 * Capacitor LocalNotifications API 사용
 */

export const notifications = {
  // 권한 요청
  async requestPermission() {
    if (!isNativePlatform) {
      console.log('[Notifications] Running on web, using browser notifications')
      if ('Notification' in window) {
        return await Notification.requestPermission()
      }
      return 'denied'
    }

    try {
      const permission = await LocalNotifications.requestPermissions()
      return permission.display
    } catch (error) {
      console.error('[Notifications] Permission request failed:', error)
      return 'denied'
    }
  },

  // 권한 확인
  async checkPermission() {
    if (!isNativePlatform) {
      if ('Notification' in window) {
        return Notification.permission
      }
      return 'denied'
    }

    try {
      const permission = await LocalNotifications.checkPermissions()
      return permission.display
    } catch (error) {
      console.error('[Notifications] Permission check failed:', error)
      return 'denied'
    }
  },

  // 알림 예약
  async schedule(notification) {
    const permission = await this.checkPermission()
    if (permission !== 'granted') {
      console.warn('[Notifications] Permission not granted')
      return false
    }

    try {
      if (!isNativePlatform) {
        // 웹 환경: Notification API 사용
        if ('Notification' in window && Notification.permission === 'granted') {
          new Notification(notification.title, {
            body: notification.body,
            icon: notification.largeIcon || '/icon.png'
          })
        }
        return true
      }

      // 네이티브 환경: Capacitor LocalNotifications 사용
      await LocalNotifications.schedule({
        notifications: [
          {
            id: notification.id || Date.now(),
            title: notification.title,
            body: notification.body,
            schedule: notification.schedule || {},
            sound: notification.sound || null,
            attachments: notification.attachments || [],
            actionTypeId: notification.actionTypeId || '',
            extra: notification.extra || {}
          }
        ]
      })
      return true
    } catch (error) {
      console.error('[Notifications] Schedule failed:', error)
      return false
    }
  },

  // 퀘스트 알림 예약
  async scheduleQuestNotification(quest, questMeta) {
    if (!questMeta.hasNotification) return false

    const notificationTime = questMeta.notificationTime || '09:00'
    const [hours, minutes] = notificationTime.split(':').map(Number)

    const notificationDate = new Date()

    // 스케줄된 날짜가 있으면 그 날짜 사용
    if (questMeta.scheduledDate) {
      const [year, month, day] = questMeta.scheduledDate.split('-').map(Number)
      notificationDate.setFullYear(year, month - 1, day)
    }

    notificationDate.setHours(hours, minutes, 0, 0)

    // 사전 알림 시간 빼기
    if (questMeta.notificationMinutesBefore) {
      notificationDate.setMinutes(notificationDate.getMinutes() - questMeta.notificationMinutesBefore)
    }

    // 과거 시간이면 내일로 설정
    if (notificationDate < new Date()) {
      notificationDate.setDate(notificationDate.getDate() + 1)
    }

    return await this.schedule({
      id: quest.id,
      title: '🎯 Quest ON',
      body: `${quest.title} 시작할 시간이에요!`,
      schedule: {
        at: notificationDate
      },
      extra: {
        questId: quest.id
      }
    })
  },

  // 반복 퀘스트 알림 예약 (주기적)
  async scheduleRecurringQuestNotification(quest, questMeta) {
    if (!questMeta.hasNotification || !questMeta.isRecurring) return false

    const notificationTime = questMeta.recurrenceTime || '09:00'
    const [hours, minutes] = notificationTime.split(':').map(Number)

    const schedule = {
      on: {
        hour: hours,
        minute: minutes
      }
    }

    // 요일 설정
    if (questMeta.recurrenceDays && questMeta.recurrenceDays.length > 0) {
      // Capacitor는 1-7 (일-토), Date.getDay()는 0-6 (일-토)
      schedule.on.weekday = questMeta.recurrenceDays.map(d => d === 0 ? 7 : d)
    }

    return await this.schedule({
      id: quest.id,
      title: '🎯 Quest ON',
      body: `${quest.title} 반복 퀘스트 시작!`,
      schedule,
      extra: {
        questId: quest.id,
        recurring: true
      }
    })
  },

  // 알림 취소
  async cancel(notificationIds) {
    if (!isNativePlatform) {
      console.log('[Notifications] Cannot cancel web notifications')
      return
    }

    try {
      await LocalNotifications.cancel({
        notifications: Array.isArray(notificationIds)
          ? notificationIds.map(id => ({ id }))
          : [{ id: notificationIds }]
      })
    } catch (error) {
      console.error('[Notifications] Cancel failed:', error)
    }
  },

  // 모든 알림 취소
  async cancelAll() {
    if (!isNativePlatform) {
      console.log('[Notifications] Cannot cancel web notifications')
      return
    }

    try {
      await LocalNotifications.getPending().then(async pending => {
        const ids = pending.notifications.map(n => ({ id: n.id }))
        await LocalNotifications.cancel({ notifications: ids })
      })
    } catch (error) {
      console.error('[Notifications] Cancel all failed:', error)
    }
  },

  // 예정된 알림 목록
  async getPending() {
    if (!isNativePlatform) return []

    try {
      const result = await LocalNotifications.getPending()
      return result.notifications
    } catch (error) {
      console.error('[Notifications] Get pending failed:', error)
      return []
    }
  }
}
