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
