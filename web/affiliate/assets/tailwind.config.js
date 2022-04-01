module.exports = {
  purge: {
    content: [
      './js/**/*.js',
      '../lib/*_web.ex',
      '../lib/*_web/**/*.*ex'
    ],
  },
  theme: {
    extend: {},
  },
  variants: {},
  plugins: [],
}
