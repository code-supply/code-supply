module.exports = {
  mode: "jit",
  purge: {
    content: [
      "../lib/affable_web/templates/*/*.html.*",
      "../lib/affable_web/live/*.html.*",
      "../lib/affable_web/views/*.ex",
      "../lib/affable_web/live/*.ex",
      "./js/*.js",
      "./css/*.css",
    ]
  },
  theme: {
    extend: {},
  },
  variants: {},
  plugins: [require('@tailwindcss/forms')],
}
