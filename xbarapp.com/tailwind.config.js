module.exports = {
  purge: {
    enabled: true,
    content: [
      "./public/**/*.html",
      "../tools/sitegen/templates/*.html"
    ],
    options: {
      keyframes: true,
    },
  },
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {},
  },
  variants: {
    extend: {},
  },
  plugins: [],
}
