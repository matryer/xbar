<script>

	import { onMount } from 'svelte'
	import { getFeaturedPlugins, openURL } from './rpc.svelte'
	import A from './elements/A.svelte'
	import Error from './elements/Error.svelte'
	import PluginCollection from './elements/PluginCollection.svelte'
	import { wait } from './waiters.svelte'
	import { installedPlugins, clearNav } from './pagedata.svelte'
	
	let featuredPlugins
	let err
	onMount(() => {
		clearNav()
		const done = wait()
		getFeaturedPlugins()
			.then(plugins => featuredPlugins = plugins)
			.catch(e => err = e)
			.finally(() => done())
	})

	function openGetInTouchWindow() {
		openURL('https://xbarapp.com/#featured-plugins')
			.catch(e => err = e)
	}

</script>
<Error err={err} />
<div class='px-6 py-3'>
	<h2 class='uppercase text-sm text-gray-500 dark:text-gray-300'>
		Featured plugins
	</h2>
</div>
<PluginCollection plugins={featuredPlugins} />
<div class='p-6 pt-0 text-right'>
	<strong>
		Get featured:
	</strong>
	<A cssclass='underline' on:click={ () => openGetInTouchWindow() }>
		Get in touch
	</A>
</div>
