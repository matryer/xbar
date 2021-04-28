<script>

	import { params } from 'svelte-hash-router'
	import { installedPlugins } from './pagedata.svelte'
	import { getPlugin, installPlugin, refreshInstalledPlugins } from './rpc.svelte'
	import { wait } from './waiters.svelte'
	import Error from './elements/Error.svelte'
	import Button from './elements/Button.svelte'
	import Breadcrumbs from './elements/Breadcrumbs.svelte'
	import PluginDetails from './elements/PluginDetails.svelte'
	import PluginSourceBrowser from './elements/PluginSourceBrowser.svelte'

	$: loadPlugin($params._)
	let err

	let plugin = null

	function loadPlugin(pluginPath) {
		if (pluginPath == '') { return}
		const done = wait()
		getPlugin(pluginPath)
			.then(p => plugin = p)
			.catch(e => err = e)
			.finally(() => done())
	}

	function install(plugin) {
		const done = wait()
		let installedPluginPath = ""
		installPlugin(plugin)
			.then(path => {
				installedPluginPath = path
				return refreshInstalledPlugins(installedPlugins)
			})
			.then(() => {
				if (installedPluginPath === '') { return }
				selectInstalledPlugin(installedPluginPath)
			})
			.finally(() => done())
	}

</script>

<style>
	.plugin-image {
		max-width: 300px;
	}

	.min-height-m-c {
		min-height: min-content;
	}
</style>

<Error err={err} />

<Breadcrumbs categoryPathSegments={plugin ? plugin.categoryPathSegments : null}>
	<strong>{plugin ? plugin.filename : ''}</strong>
</Breadcrumbs>

{#if plugin}
	<div class='flex flex-col h-full max-w-full'>
		<div class='p-6 flex flex-wrap space-x-8 min-height-m-c'>
			<div>
				<PluginDetails plugin={plugin} />
				<p class='p-3'>
					<Button
						style='primary'
						on:click={() => install(plugin)}
					>
						Install
					</Button>
				</p>
			</div>
			{#if plugin.imageURL}
				<div class='flex-shrink mb-8'>
					<img 
						alt='Screenshot of {plugin.title}' 
						src={plugin.imageURL} 
						onerror='this.style.display="none"'
						class='plugin-image max-h-64'
					/>
				</div>
			{/if}
		</div>
		<div class='flex-grow bg-white dark:bg-gray-700 p-3 border-t border-gray-200 dark:border-gray-900 bg-opacity-75'>
			<PluginSourceBrowser files={plugin.files} />
		</div>
	</div>
{/if}
