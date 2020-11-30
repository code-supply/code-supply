module.exports = {
  purge: {
    content: [
      "../lib/**/*.html.*",
      "../lib/**/views/**/*.ex",
      "../lib/**/live/**/*.ex",
      "./js/**/*.js",
      "./css/*.css",
    ]
  },
  theme: {
    extend: {},
  },
  variants: {},
  plugins: [require('@tailwindcss/forms')],
}
