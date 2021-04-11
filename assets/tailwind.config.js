const colors = require('tailwindcss/colors')

module.exports = {
  purge: [
    './css/**/*.scss',
    '../lib/planning_poker_web/**/*',
],
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {
      colors: {
        teal: colors.teal,
        lime: colors.lime,
        amber: colors.amber,
        orange: colors.orange,
        green: colors.green,
        lightBlue: colors.lightBlue,
      },
      spacing: {
        '30': '7.5rem'
      },
      animation: {
        'fade-in': 'fadeIn 0.5s ease-in-out both',
        'fade-out': 'fadeOut 0.5s ease-in-out both',
        'open-participants': 'openParticipants 0.5s ease-in-out both'
      },
      keyframes: {
        'fadeIn': {
          '0%': {opacity: 0, visibility: 'hidden'},
          '100%': {opacity: 1, visibility: 'visible'},
        },
        'fadeOut': {
          '0%': {opacity: 1, visibility: 'visible'},
          '100%': {opacity: 0, visibility: 'hidden'},
        },
        'openParticipants': {
          '0%': {transform: 'translateX(100%)'},
          '100%': {transform: 'translateX(0%)'}
        }
      },
      height: {
        '85-screen': '85vh'
      },
      maxWidth: {
        '24': '6rem'
      }
    },
  },
  variants: {
    extend: {},
  },
  plugins: [],
}
