<script>

	import Spinner from './Spinner.svelte'

	// style is the style of button.
	// default or primary, see classes below.
	export let style = 'default'

	// cssclass appends per-element css classes.
	export let cssclass = ''

	// waiter will show a spinner inside the button
	// if > 0.
	export let waiter = 0

	// classes are the css classes to use for each style of button
	const classes = {
		'default': 'text-sm rounded shadow-sm dark:shadow-none px-4 py-1 border bg-gray-100 dark:text-gray-300 dark:bg-gray-900 border-gray-300 dark:border-gray-600 dark:bg-opacity-50 hover:bg-opacity-75',
		'primary': 'bg-blue-900 text-sm text-white rounded shadow-sm dark:shadow-none px-4 py-1 border border-blue-900 dark:bg-black dark:border-black dark:bg-opacity-50 hover:bg-opacity-75',
	}

	// css is the final css string to inject into the element.
	$: css = classes[style] + ' ' + cssclass

</script>
<button 
	on:click
	class='{css}'
>
	<div class:animate-spin={waiter}>
		<slot />
	</div>
</button>
