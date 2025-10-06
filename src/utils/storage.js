import { Preferences } from '@capacitor/preferences'
import { Capacitor } from '@capacitor/core'

// 플랫폼 확인
const isNativePlatform = Capacitor.isNativePlatform()

/**
 * 통합 스토리지 API
 * 웹: localStorage
 * Native: Capacitor Preferences
 */
export const storage = {
  async get(key) {
    try {
      if (isNativePlatform) {
        const { value } = await Preferences.get({ key })
        return value
      } else {
        return localStorage.getItem(key)
      }
    } catch (error) {
      console.error(`Storage get error for key "${key}":`, error)
      return null
    }
  },

  async set(key, value) {
    try {
      if (isNativePlatform) {
        await Preferences.set({ key, value })
      } else {
        localStorage.setItem(key, value)
      }
    } catch (error) {
      console.error(`Storage set error for key "${key}":`, error)
    }
  },

  async remove(key) {
    try {
      if (isNativePlatform) {
        await Preferences.remove({ key })
      } else {
        localStorage.removeItem(key)
      }
    } catch (error) {
      console.error(`Storage remove error for key "${key}":`, error)
    }
  },

  async clear() {
    try {
      if (isNativePlatform) {
        await Preferences.clear()
      } else {
        localStorage.clear()
      }
    } catch (error) {
      console.error('Storage clear error:', error)
    }
  },

  async keys() {
    try {
      if (isNativePlatform) {
        const { keys } = await Preferences.keys()
        return keys
      } else {
        return Object.keys(localStorage)
      }
    } catch (error) {
      console.error('Storage keys error:', error)
      return []
    }
  },

  // JSON 전용 메서드
  async getJSON(key) {
    const value = await this.get(key)
    if (!value) return null
    try {
      return JSON.parse(value)
    } catch (error) {
      console.error(`Failed to parse JSON for key "${key}":`, error)
      return null
    }
  },

  async setJSON(key, data) {
    try {
      const value = JSON.stringify(data)
      await this.set(key, value)
    } catch (error) {
      console.error(`Failed to stringify JSON for key "${key}":`, error)
    }
  }
}

/**
 * localStorage에서 Capacitor Preferences로 데이터 마이그레이션
 * 앱 시작 시 한 번만 실행
 */
export async function migrateToCapacitorPreferences() {
  if (!isNativePlatform) {
    console.log('[Storage Migration] Running on web, no migration needed')
    return
  }

  const migrationKey = 'storage-migration-completed'
  const migrationCompleted = await storage.get(migrationKey)

  if (migrationCompleted === 'true') {
    console.log('[Storage Migration] Already completed')
    return
  }

  console.log('[Storage Migration] Starting migration...')

  try {
    // localStorage의 모든 키 마이그레이션
    const keys = Object.keys(localStorage)
    let migratedCount = 0

    for (const key of keys) {
      const value = localStorage.getItem(key)
      if (value !== null) {
        await Preferences.set({ key, value })
        migratedCount++
      }
    }

    // 마이그레이션 완료 표시
    await Preferences.set({ key: migrationKey, value: 'true' })

    console.log(`[Storage Migration] Completed: ${migratedCount} items migrated`)
  } catch (error) {
    console.error('[Storage Migration] Failed:', error)
  }
}
