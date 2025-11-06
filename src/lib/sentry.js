// Sentry Error Tracking Configuration
import * as Sentry from '@sentry/vue'

/**
 * Sentry 초기화
 * @param {Object} app - Vue 앱 인스턴스
 * @param {Object} router - Vue Router 인스턴스
 */
export function initSentry(app, router) {
  const sentryDsn = import.meta.env.VITE_SENTRY_DSN
  const environment = import.meta.env.MODE // 'development' | 'production'

  // Sentry DSN이 없으면 초기화하지 않음
  if (!sentryDsn) {
    console.warn('Sentry DSN not configured. Error tracking disabled.')
    return
  }

  Sentry.init({
    app,
    dsn: sentryDsn,
    environment,

    // Vue Router 통합 (페이지 전환 추적)
    integrations: [
      Sentry.browserTracingIntegration({ router }),
      Sentry.replayIntegration({
        // Session Replay 설정 (선택사항)
        maskAllText: true,
        blockAllMedia: true,
      }),
    ],

    // 성능 모니터링
    tracesSampleRate: environment === 'production' ? 0.1 : 1.0,

    // Session Replay 샘플링
    replaysSessionSampleRate: 0.1, // 10% 세션 녹화
    replaysOnErrorSampleRate: 1.0, // 에러 발생 시 100% 녹화

    // 개발 환경에서는 에러를 콘솔에도 출력
    beforeSend(event, hint) {
      if (environment === 'development') {
        console.error('[Sentry]', hint.originalException || hint.syntheticException)
      }
      return event
    },

    // 민감 정보 제거
    beforeBreadcrumb(breadcrumb) {
      // URL에서 쿼리 파라미터 제거
      if (breadcrumb.category === 'navigation' && breadcrumb.data?.to) {
        breadcrumb.data.to = breadcrumb.data.to.split('?')[0]
      }
      return breadcrumb
    },

    // 에러 필터링 (무시할 에러)
    ignoreErrors: [
      // 브라우저 확장 프로그램 에러
      'top.GLOBALS',
      'ResizeObserver loop limit exceeded',
      // 네트워크 에러 (사용자 오프라인 등)
      'NetworkError',
      'Failed to fetch',
    ],
  })
}

/**
 * 사용자 정보 설정 (로그인 후)
 * @param {Object} user - 사용자 정보
 */
export function setSentryUser(user) {
  if (user) {
    Sentry.setUser({
      id: user.id,
      email: user.email,
      username: user.user_metadata?.nickname || 'Unknown',
    })
  } else {
    Sentry.setUser(null)
  }
}

/**
 * 커스텀 에러 로깅
 * @param {Error} error - 에러 객체
 * @param {Object} context - 추가 컨텍스트 정보
 */
export function logError(error, context = {}) {
  Sentry.captureException(error, {
    contexts: {
      custom: context,
    },
  })
}

/**
 * 커스텀 메시지 로깅 (에러가 아닌 경우)
 * @param {string} message - 메시지
 * @param {string} level - 'info' | 'warning' | 'error'
 */
export function logMessage(message, level = 'info') {
  Sentry.captureMessage(message, level)
}

/**
 * 성능 트랜잭션 시작
 * @param {string} name - 트랜잭션 이름
 * @returns {Object} 트랜잭션 객체
 */
export function startTransaction(name) {
  return Sentry.startTransaction({ name })
}
