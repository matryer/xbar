<script>
	export let style = 'default'

	const classes = {
		'default': 'text-sm rounded shadow-sm dark:shadow-none px-4 border bg-gray-100 active:bg-gray-300 dark:text-gray-400 dark:bg-gray-900 border-gray-300 dark:border-gray-600 dark:bg-opacity-50 hover:bg-opacity-75',
		'primary': 'bg-blue-900 active:bg-blue-800 text-sm text-white rounded shadow-sm dark:shadow-none px-4 border border-blue-900 dark:bg-black dark:border-black dark:bg-opacity-50 hover:bg-opacity-75',
	}

	$: cssClass = classes[style]

</script>
<button 
	on:click
	class='{cssClass}'
>
	<slot />
</button>
