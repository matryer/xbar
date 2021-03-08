<script>

	import { params } from 'svelte-hash-router'
	import Error from './elements/Error.svelte'
	import Breadcrumbs from './elements/Breadcrumbs.svelte'
	import PluginCollection from './elements/PluginCollection.svelte'
	import { categories } from './pagedata.svelte'
	import { getCategoryByPath, getPlugins } from './rpc.svelte'
	import { wait } from './waiters.svelte'
	
	$: loadPlugins($categories, $params._)

	let category = null
	let plugins = null
	let err = ''

	function loadPlugins(categories, path) {
		if (categories == null) { return }
		category = getCategoryByPath(categories, path)
		const done = wait()
		plugins = null
		getPlugins(path)
			.then(response => {
				plugins = response
			})
			.catch(e => err = e)
			.finally(() => done())
	}

</script>

<Error err={err} />

<Breadcrumbs 
	hideLast={true}
	categoryPathSegments={category ? category.categoryPathSegments : null}
>
	<strong>{category ? category.text : ''}</strong>
</Breadcrumbs>

<div class='pt-6'>
	<PluginCollection plugins={plugins} />
</div>
