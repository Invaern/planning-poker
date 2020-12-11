const colors = require('tailwindcss/colors')

module.exports = {
  purge: [],
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
      minHeight: {
        '3/4-screen': '75vh'
      }
    },
  },
  variants: {
    extend: {},
  },
  plugins: [],
}
