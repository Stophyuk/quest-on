// 데이터 지속성을 위한 localStorage 유틸리티
export class StorageManager {
  constructor() {
    this.STORAGE_KEYS = {
      QUEST_DATA: 'quest-on-data',
      USER_PROFILE: 'quest-on-profile',
      MOOD_HISTORY: 'quest-on-mood-history',
      SETTINGS: 'quest-on-settings'
    }
  }

  // 퀘스트 데이터 저장
  saveQuestData(data) {
    try {
      // localStorage 가용성 확인
      if (typeof Storage === 'undefined') {
        console.warn('LocalStorage is not supported')
        return false
      }
      
      const serializedData = {
        ...data,
        lastSaved: new Date().toISOString(),
        version: '1.0'
      }
      
      const jsonString = JSON.stringify(serializedData)
      localStorage.setItem(this.STORAGE_KEYS.QUEST_DATA, jsonString)
      return true
    } catch (error) {
      if (error.name === 'QuotaExceededError') {
        console.error('Storage quota exceeded. Try clearing some data.')
      } else {
        console.error('Failed to save quest data:', error)
      }
      return false
    }
  }

  // 퀘스트 데이터 불러오기
  loadQuestData() {
    try {
      const stored = localStorage.getItem(this.STORAGE_KEYS.QUEST_DATA)
      if (!stored) return null
      
      const data = JSON.parse(stored)
      
      // 데이터 유효성 검사
      if (!data.version) return null
      
      // 하루가 지났으면 일일 퀘스트 초기화
      if (this.shouldResetDailyQuests(data.lastSaved)) {
        return this.resetDailyProgress(data)
      }
      
      return data
    } catch (error) {
      console.error('Failed to load quest data:', error)
      return null
    }
  }

  // 하루가 지났는지 확인 (20시간 grace period)
  shouldResetDailyQuests(lastSaved) {
    if (!lastSaved) return false

    const lastDate = new Date(lastSaved)
    const now = new Date()

    // 20시간 (72000000ms) 이상 지났는지 확인
    // 자정 직전/직후 초기화 방지
    const hoursPassed = (now - lastDate) / (1000 * 60 * 60)

    if (hoursPassed < 20) {
      return false
    }

    // 20시간 이상 지났고, 날짜가 다르면 리셋
    return lastDate.toDateString() !== now.toDateString()
  }

  // 일일 진행도 초기화 (레벨, 경험치는 유지)
  resetDailyProgress(data) {
    return {
      ...data,
      currentCondition: '😊',
      quests: data.quests.map(quest => ({
        ...quest,
        completed: false,
        progress: 0
      })),
      dailyCompletionRate: 0,
      lastSaved: new Date().toISOString()
    }
  }

  // 사용자 프로필 저장
  saveUserProfile(profile) {
    try {
      localStorage.setItem(this.STORAGE_KEYS.USER_PROFILE, JSON.stringify(profile))
      return true
    } catch (error) {
      console.error('Failed to save user profile:', error)
      return false
    }
  }

  // 사용자 프로필 불러오기
  loadUserProfile() {
    try {
      const stored = localStorage.getItem(this.STORAGE_KEYS.USER_PROFILE)
      return stored ? JSON.parse(stored) : null
    } catch (error) {
      console.error('Failed to load user profile:', error)
      return null
    }
  }

  // 기분 히스토리 저장
  saveMoodHistory(moodData) {
    try {
      const existing = this.loadMoodHistory() || []
      const today = new Date().toDateString()
      
      // 오늘 기록이 있으면 업데이트, 없으면 추가
      const todayIndex = existing.findIndex(entry => 
        new Date(entry.date).toDateString() === today
      )
      
      const newEntry = {
        date: new Date().toISOString(),
        mood: moodData.mood,
        completionRate: moodData.completionRate,
        questsCompleted: moodData.questsCompleted
      }
      
      if (todayIndex >= 0) {
        existing[todayIndex] = newEntry
      } else {
        existing.push(newEntry)
      }
      
      // 최근 30일만 유지
      const recent = existing.slice(-30)
      
      localStorage.setItem(this.STORAGE_KEYS.MOOD_HISTORY, JSON.stringify(recent))
      return true
    } catch (error) {
      console.error('Failed to save mood history:', error)
      return false
    }
  }

  // 기분 히스토리 불러오기
  loadMoodHistory() {
    try {
      const stored = localStorage.getItem(this.STORAGE_KEYS.MOOD_HISTORY)
      return stored ? JSON.parse(stored) : []
    } catch (error) {
      console.error('Failed to load mood history:', error)
      return []
    }
  }

  // 설정 저장
  saveSettings(settings) {
    try {
      localStorage.setItem(this.STORAGE_KEYS.SETTINGS, JSON.stringify(settings))
      return true
    } catch (error) {
      console.error('Failed to save settings:', error)
      return false
    }
  }

  // 설정 불러오기
  loadSettings() {
    try {
      const stored = localStorage.getItem(this.STORAGE_KEYS.SETTINGS)
      return stored ? JSON.parse(stored) : this.getDefaultSettings()
    } catch (error) {
      console.error('Failed to load settings:', error)
      return this.getDefaultSettings()
    }
  }

  // 기본 설정
  getDefaultSettings() {
    return {
      notifications: true,
      soundEffects: true,
      vibration: true,
      theme: 'auto',
      language: 'ko',
      firstTime: true
    }
  }

  // 모든 데이터 내보내기 (백업용)
  exportAllData() {
    try {
      const allData = {
        questData: this.loadQuestData(),
        userProfile: this.loadUserProfile(),
        moodHistory: this.loadMoodHistory(),
        settings: this.loadSettings(),
        exportDate: new Date().toISOString(),
        version: '1.0'
      }
      return JSON.stringify(allData, null, 2)
    } catch (error) {
      console.error('Failed to export data:', error)
      return null
    }
  }

  // 데이터 가져오기 (복원용)
  importAllData(dataString) {
    try {
      const data = JSON.parse(dataString)
      
      if (!data.version) {
        throw new Error('Invalid data format')
      }
      
      // 각 데이터 복원
      if (data.questData) {
        this.saveQuestData(data.questData)
      }
      if (data.userProfile) {
        this.saveUserProfile(data.userProfile)
      }
      if (data.moodHistory) {
        localStorage.setItem(this.STORAGE_KEYS.MOOD_HISTORY, JSON.stringify(data.moodHistory))
      }
      if (data.settings) {
        this.saveSettings(data.settings)
      }
      
      return true
    } catch (error) {
      console.error('Failed to import data:', error)
      return false
    }
  }

  // 모든 데이터 삭제 (초기화용)
  clearAllData() {
    try {
      Object.values(this.STORAGE_KEYS).forEach(key => {
        localStorage.removeItem(key)
      })
      return true
    } catch (error) {
      console.error('Failed to clear data:', error)
      return false
    }
  }

  // 스토리지 용량 체크
  getStorageInfo() {
    try {
      let totalSize = 0
      Object.values(this.STORAGE_KEYS).forEach(key => {
        const data = localStorage.getItem(key)
        if (data) {
          totalSize += data.length
        }
      })

      // 일반적인 localStorage 한계: 5MB (5242880 bytes)
      const STORAGE_LIMIT = 5242880
      const usagePercent = (totalSize / STORAGE_LIMIT) * 100

      return {
        usedBytes: totalSize,
        usedKB: Math.round(totalSize / 1024 * 100) / 100,
        usedMB: Math.round(totalSize / (1024 * 1024) * 100) / 100,
        itemCount: Object.keys(localStorage).length,
        usagePercent: Math.round(usagePercent * 100) / 100,
        isNearLimit: usagePercent >= 90,
        warningLevel: usagePercent >= 90 ? 'critical' : usagePercent >= 70 ? 'warning' : 'normal'
      }
    } catch (error) {
      console.error('Failed to get storage info:', error)
      return null
    }
  }

  // 저장 전 용량 체크
  checkStorageBeforeSave() {
    const info = this.getStorageInfo()
    if (!info) return true

    if (info.isNearLimit) {
      console.warn('⚠️ localStorage 용량 90% 초과:', info)
      return false
    }

    return true
  }
}

// 싱글톤 인스턴스 생성
export const storageManager = new StorageManager()