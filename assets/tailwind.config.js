module.exports = {
  future: {
    removeDeprecatedGapUtilities: true,
    purgeLayersByDefault: true,
  },
  theme: {
    extend: {
      colors: {
        'gameboy-green': {
          darkest: '#0f380f',
          DEFAULT: '#306230',
          light: '#8bac0f',
          lightest: '#9bbc0f',
        },
      },
      fontFamily: {
        display: ['"8bitoperatorregular"'],
      },
    },
  }
}
