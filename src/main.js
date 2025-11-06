import { createApp } from 'vue'
import './style.css'
import App from './App.vue'
import router from './router'
import pinia from './stores'
import { initSentry } from './lib/sentry'

const app = createApp(App)

// Sentry 초기화 (프로덕션 환경에서만 활성화 권장)
initSentry(app, router)

app.use(router)
app.use(pinia)

app.mount('#app')
