/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./assets/templates/**/*.{html,template}",
    "./assets/css/**/*.css"
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: '#045BDB',
          dark: '#0B234A',
        },
        accent: {
          red: '#FF5F56',
          yellow: '#FFBD2E',
          green: '#27C93F',
        },
        theme: {
          bg: {
            DEFAULT: '#FFFFFF',
            dark: '#0E1A2F'
          },
          card: {
            DEFAULT: '#F8F9FA',
            dark: '#0B234A'
          },
          border: {
            DEFAULT: '#C5D1E3',
            dark: '#273B59'
          },
          text: {
            DEFAULT: '#0E1A2F',
            secondary: '#273B59',
            dark: '#FFFFFF',
            'secondary-dark': '#C5D1E3'
          }
        }
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', '-apple-system', 'sans-serif'],
        mono: ['JetBrains Mono', 'Menlo', 'Monaco', 'monospace'],
      },
      fontSize: {
        'hero': ['clamp(2.5rem, 5vw, 4.5rem)', { lineHeight: '1.1', letterSpacing: '-0.03em', fontWeight: '700' }],
        'display': ['clamp(2rem, 4vw, 3rem)', { lineHeight: '1.2', letterSpacing: '-0.02em', fontWeight: '600' }],
        'title': ['clamp(1.5rem, 3vw, 2rem)', { lineHeight: '1.3', letterSpacing: '-0.01em', fontWeight: '600' }],
      },
      animation: {
        'fade-in': 'fadeIn 0.6s ease-out',
        'slide-up': 'slideUp 0.6s ease-out',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' }
        },
        slideUp: {
          '0%': { opacity: '0', transform: 'translateY(20px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' }
        },
      }
    },
  },
  plugins: [
    require('@tailwindcss/typography'),
  ],
}
