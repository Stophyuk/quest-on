/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        // Primary Colors - Calming & Growth
        primary: {
          50: '#f0fdf4',
          100: '#dcfce7', 
          200: '#bbf7d0',
          300: '#86efac',
          400: '#4ade80',
          500: '#10b981',
          600: '#059669',
          700: '#047857',
          800: '#065f46',
          900: '#064e3b',
        },
        // Mood Colors - Emotional States
        mood: {
          good: '#34d399',     // 좋음 - 밝은 에메랄드
          normal: '#60a5fa',   // 보통 - 부드러운 블루  
          tired: '#f472b6',    // 힘듦 - 따뜻한 핑크
        },
        // Neutral Colors - Modern Minimalism
        neutral: {
          50: '#fafafa',
          100: '#f5f5f5',
          200: '#e5e5e5',
          300: '#d4d4d4',
          400: '#a3a3a3',
          500: '#737373',
          600: '#525252',
          700: '#404040',
          800: '#262626',
          900: '#171717',
        },
        // Accent Colors - Gamification
        gold: '#fbbf24',
        purple: '#8b5cf6',
        success: '#22c55e',
        warning: '#f59e0b',
        error: '#ef4444',
      },
      fontFamily: {
        sans: ['GmarketSans', 'ui-sans-serif', 'system-ui'],
        pixel: ['Cafe24PROUP', 'monospace'],
        gmarket: ['GmarketSans', 'ui-sans-serif', 'system-ui'],
      },
      backgroundImage: {
        'gradient-primary': 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
        'gradient-mood': 'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)',
        'gradient-calm': 'linear-gradient(135deg, #a8edea 0%, #fed6e3 100%)',
        'gradient-growth': 'linear-gradient(135deg, #d299c2 0%, #fef9d7 100%)',
      },
      boxShadow: {
        'soft': '0 2px 8px rgba(0, 0, 0, 0.06)',
        'card': '0 4px 16px rgba(0, 0, 0, 0.08)',
        'mood-good': '0 4px 20px rgba(52, 211, 153, 0.15)',
        'mood-normal': '0 4px 20px rgba(96, 165, 250, 0.15)',
        'mood-tired': '0 4px 20px rgba(244, 114, 182, 0.15)',
      },
      animation: {
        'bounce-gentle': 'bounce 2s infinite',
        'pulse-soft': 'pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite',
        'fade-in': 'fadeIn 0.5s ease-in-out',
        'slide-up': 'slideUp 0.3s ease-out',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0', transform: 'translateY(10px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
        slideUp: {
          '0%': { transform: 'translateY(20px)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' },
        },
      },
      minHeight: {
        'touch': '44px',
      },
      spacing: {
        'safe-top': 'env(safe-area-inset-top)',
        'safe-bottom': 'env(safe-area-inset-bottom)',
      },
    },
  },
  plugins: [],
}