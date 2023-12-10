
const colors = require('tailwindcss/colors')

module.exports = {
	purge: [
		'./src/**/*.html',
		'./src/**/*.js',
		'./src/**/*.svelte',
	],
	theme: {
		colors: {
			transparent: 'transparent',

			gray: colors.neutral,
			blue: colors.blue,
			black: colors.black,
			white: colors.white,
			yellow: colors.yellow,
		},
	},
	plugins: [],
}
