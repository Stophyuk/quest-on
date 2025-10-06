import { Haptics, ImpactStyle, NotificationType } from '@capacitor/haptics'

/**
 * 햅틱 피드백 유틸리티
 * Capacitor Haptics API를 사용하며, 웹 환경에서는 자동으로 폴백
 */

export const haptics = {
  // 가벼운 임팩트 (버튼 탭 등)
  async light() {
    try {
      await Haptics.impact({ style: ImpactStyle.Light })
    } catch (error) {
      // 폴백: 웹 환경
      if (navigator.vibrate) {
        navigator.vibrate(10)
      }
    }
  },

  // 중간 임팩트 (토글 스위치 등)
  async medium() {
    try {
      await Haptics.impact({ style: ImpactStyle.Medium })
    } catch (error) {
      if (navigator.vibrate) {
        navigator.vibrate(20)
      }
    }
  },

  // 강한 임팩트 (중요한 액션)
  async heavy() {
    try {
      await Haptics.impact({ style: ImpactStyle.Heavy })
    } catch (error) {
      if (navigator.vibrate) {
        navigator.vibrate(50)
      }
    }
  },

  // 성공 알림 (퀘스트 완료 등)
  async success() {
    try {
      await Haptics.notification({ type: NotificationType.Success })
    } catch (error) {
      if (navigator.vibrate) {
        navigator.vibrate([30, 50, 30])
      }
    }
  },

  // 경고 알림
  async warning() {
    try {
      await Haptics.notification({ type: NotificationType.Warning })
    } catch (error) {
      if (navigator.vibrate) {
        navigator.vibrate([50, 100, 50])
      }
    }
  },

  // 에러 알림
  async error() {
    try {
      await Haptics.notification({ type: NotificationType.Error })
    } catch (error) {
      if (navigator.vibrate) {
        navigator.vibrate([100, 50, 100])
      }
    }
  },

  // 선택 변경 (스크롤, 슬라이더 등)
  async selectionChanged() {
    try {
      await Haptics.selectionStart()
      await Haptics.selectionChanged()
      await Haptics.selectionEnd()
    } catch (error) {
      if (navigator.vibrate) {
        navigator.vibrate(5)
      }
    }
  }
}
