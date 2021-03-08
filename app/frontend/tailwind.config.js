module.exports = {
	purge: [
		'./src/**/*.html',
		'./src/**/*.js',
		'./src/**/*.svelte',
	],
	darkMode: 'media',
	theme: {
		fill: theme => ({
			gray: theme('colors.warmGray')
		})
	},
	variants: {
		extend: {},
	},
	plugins: [],
}
