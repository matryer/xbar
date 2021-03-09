
const colors = require('tailwindcss/colors')

module.exports = {
	purge: [
		'./src/**/*.html',
		'./src/**/*.js',
		'./src/**/*.svelte',
	],
	darkMode: 'media',
	theme: {
		colors: {
			gray: colors.trueGray,
			blue: colors.blue,
			black: colors.black,
			white: colors.white,
			yellow: colors.yellow,
		},
	},
	variants: {
		extend: {},
	},
	plugins: [],
}
