<script>
	export let style = 'default'

	const classes = {
		'default': 'text-sm rounded shadow-sm px-4 border bg-gray-100 active:bg-gray-300 dark:text-gray-400 dark:bg-gray-700 border-gray-300 dark:border-gray-600 dark:bg-opacity-50 hover:bg-opacity-75',
		'primary': 'bg-blue-900 active:bg-blue-800 text-sm text-white rounded shadow-sm px-4 border border-blue-900 dark:bg-opacity-50',
	}

	$: cssClass = classes[style]

</script>
<button 
	on:click
	class='{cssClass}'
>
	<slot />
</button>
