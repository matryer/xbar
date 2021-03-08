<script>

	import { params } from 'svelte-hash-router'
	import { installedPlugins } from './pagedata.svelte'
	import { getPlugin, openURL, installPlugin, refreshInstalledPlugins } from './rpc.svelte'
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

	function gotoOpenPluginIssue(plugin) {
		let body = `re: ${plugin.title}`
		const githubUsernamesList = plugin.authors
			.map(author => author.githubUsername)
			.filter(githubUsername => githubUsername && githubUsername != '')
			.join(', ')
		if (plugin.authors.length > 0) {
			body = `fao @${githubUsernamesList} - ${body}`
		}
		body = `${body}

` // line feeds
		const path = `https://github.com/matryer/xbar-plugins/issues/new?body=${encodeURIComponent(body)}&title=${encodeURIComponent(plugin.path)}:%20`
		openURL(path)
			.catch(e => err = e)
	}
	
</script>

<style>
	.plugin-image {
		max-width: 300px;
	}
</style>

<Error err={err} />

<Breadcrumbs categoryPathSegments={plugin ? plugin.categoryPathSegments : null}>
	<strong>{plugin ? plugin.filename : ''}</strong>
</Breadcrumbs>

{#if plugin}
	<div class='flex flex-col h-full max-w-full'>
		<div class='p-6 flex flex-wrap space-x-8'>
			<div>
				<PluginDetails plugin={plugin} />
				<p class='p-3'>
					<Button
						style='primary'
						on:click={() => install(plugin)}
					>
						Install
					</Button>
					<Button on:click={ () => gotoOpenPluginIssue(plugin) }>
						Open issue&hellip;
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
