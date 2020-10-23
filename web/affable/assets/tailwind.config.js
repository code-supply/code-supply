module.exports = {
  purge: [
    '../lib/affable_web/**/*/*.html.*',
    '../lib/affable_web/**/*.html.*',
  ],
  theme: {
    extend: {},
  },
  variants: {},
  plugins: [],
  future: {
    purgeLayersByDefault: true,
    removeDeprecatedGapUtilities: true,
  },
}
