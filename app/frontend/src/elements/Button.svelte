<script>
	export let style = 'default'

	const classes = {
		'default': 'bg-gray-100 active:bg-gray-300 text-sm dark:text-gray-800 rounded shadow-sm px-4 border border-gray-300 dark:opacity-75',
		'primary': 'bg-purple-800 active:bg-purple-700 text-sm text-white rounded shadow-sm px-4 border border-purple-900',
	}

	$: cssClass = classes[style]

</script>
<button 
	on:click
	class='{cssClass}'
>
	<slot />
</button>
