<script>

	import { params } from 'svelte-hash-router'
	import { 
		uninstallPlugin,
		refreshInstalledPlugins,
		getInstalledPluginMetadata, 
		loadVariableValues, saveVariableValues,
		setEnabled,
		setRefreshInterval,
		openURL, openFile,
	} from './rpc.svelte'
	import { installedPlugins, selectedInstalledPluginPath, clearNav } from './pagedata.svelte'
	import { wait } from './waiters.svelte'
	import Breadcrumbs from './elements/Breadcrumbs.svelte'
	import PluginDetails from './elements/PluginDetails.svelte'
	import Variables from './elements/Variables.svelte'
	import PluginSourceBrowser from './elements/PluginSourceBrowser.svelte'
	import Button from './elements/Button.svelte'
	import Error from './elements/Error.svelte'
	import Switch from './elements/Switch.svelte'
	import Spinner from './elements/Spinner.svelte'
	import Duration from './elements/Duration.svelte'
	import { sigRefresh } from './signals.svelte'

	let err

	let installedPlugin = null
	let refreshInterval
	let variableValues = null

	$: if ($sigRefresh && $params._) {
		loadPluginMetadata($params._)
	}

	function loadPluginMetadata(installedPluginPath) {
		if (!installedPluginPath) { return }
		err = null
		const done1 = wait()
		const done2 = wait()
		getInstalledPluginMetadata(installedPluginPath)
			.then(result => {
				installedPlugin = result.plugin
				installedPlugin.enabled = result.enabled
				refreshInterval = result.refreshInterval
			})
			.catch(e => err = e)
			.finally(() => done1())
		loadVariableValues(installedPluginPath)
			.then(result => variableValues = result)
			.catch(e => err = e)
			.finally(() => done2())
	}

	$: updateValues(installedPlugin ? installedPlugin.vars : null, variableValues)

	function updateValues(variables, values) {
		if (!variables || !values) return // wait for both
		variables.forEach(v => {
			if (typeof values[v.name] !== 'undefined') {
				return
			}
			switch (v.type) {
			case 'string':
			case 'list':
				values[v.name] = v.default
				break
			case 'boolean':
				const def = v.default || ""
				values[v.name] = def.toUpperCase() == 'TRUE'
				break
			case 'number':
				values[v.name] = parseFloat(v.default) || 0
				break
			default:
				console.warn(`Variables: ${v.name} has unsupported type ${v.type} (skipping)`)
			}
		})
	}

	function onValuesChanged() {
		saveVariableValues(installedPlugin.path, variableValues)
	}

	let pluginEnableToggleWaiter = 0
	function toggleEnabled() {
		pluginEnableToggleWaiter++
		installedPlugin.enabled = !installedPlugin.enabled
		setEnabled(installedPlugin.path, installedPlugin.enabled) 
			.then(updatedPath => {
				// redirect to new place
				selectedInstalledPluginPath.set(updatedPath)
				location.hash = `/installed-plugins/${updatedPath}`
				refreshInstalledPlugins(installedPlugins)
			})
			.catch(e => err = e)
			.finally(() => pluginEnableToggleWaiter--)
	}

	function onDurationChanged() {
		const done = wait()
		setRefreshInterval(installedPlugin.path, refreshInterval)
			.then(result => {
				// redirect to new place
				selectedInstalledPluginPath.set(result.installedPluginPath)
				location.hash = `/installed-plugins/${result.installedPluginPath}`
				refreshInstalledPlugins(installedPlugins)
			})
			.catch(e => err = e)
			.finally(() => done())
	}

	function onUninstallClick() {
		const done = wait()
		uninstallPlugin(installedPlugin)
			.then((result) => {
				if (result === false) {
					// canceled
					return 
				}
				clearNav()
				location.hash = ''
				refreshInstalledPlugins(installedPlugins)
			})
			.catch(e => err = e)
			.finally(() => done())
	}

	function gotoOpenPluginIssue(plugin) {
		let body = ``
		if (plugin.authors) {
			const githubUsernamesList = plugin.authors
				.map(author => author.githubUsername)
				.filter(githubUsername => githubUsername && githubUsername != '')
				.join(', ')
			if (plugin.authors.length > 0) {
				body = `fao @${githubUsernamesList} - ${body}`
			}
		}
		if (body != '') {
			body = `${body}

` // line feeds
		}
		const path = `https://github.com/matryer/xbar-plugins/issues/new?body=${encodeURIComponent(body)}&title=${encodeURIComponent(plugin.path+": ")}`
		openURL(path)
			.catch(e => err = e)
	}

	function openEditor(e) {
		openFile(installedPlugin.path)
			.catch(e => err = e)
	}

</script>

<style>
	.plugin-image {
		max-width: 300px;
	}
	.flex-fix {
		flex: none;
	}
</style>

<Error err={err} />

{#if !err}
	<Breadcrumbs>
		{#if installedPlugin}
			<strong>
				{installedPlugin.title || installedPlugin.filename}
			</strong>
		{/if}
	</Breadcrumbs>

	<div class='flex flex-col h-full max-w-full'>
		<div class='flex p-6 flex-wrap space-x-8 flex-fix'>
			<div>
				<PluginDetails plugin={installedPlugin}>
					<div slot='action' class='pl-3'>
						<Spinner 
							width=16 
							height=16
							waiter={ pluginEnableToggleWaiter } 
						/>
						<Switch 
							on={ installedPlugin.enabled } 
							loading={ pluginEnableToggleWaiter>0 }
							on:click={ toggleEnabled }
						/>
					</div>
					<div slot='footer'>
						{#if refreshInterval}
							<div class='p-4 text-right'>
								<span class='mr-1'>Refresh every:</span>
								<Duration 
									value={refreshInterval} 
									on:change={ onDurationChanged }
									disabled={ !installedPlugin.enabled }
								/>
							</div>
						{/if}
					</div>
				</PluginDetails>
				{#if installedPlugin}
					<div class='p-3 flex space-x-5'>
						<Button on:click={ () => gotoOpenPluginIssue(installedPlugin) }>
							Open issue&hellip;
						</Button>
						<Button on:click={ onUninstallClick }>
							Uninstall this plugin
						</Button>
					</div>
				{/if}
			</div>
			{#if installedPlugin && installedPlugin.imageURL}
				<div class='flex-shrink mb-8'>
					<img 
						alt='Screenshot of {installedPlugin.title}' 
						src={installedPlugin.imageURL} 
						onerror='this.style.display="none"'
						class='plugin-image max-h-64'
					/>
				</div>
			{/if}
		</div>
		{#if installedPlugin && installedPlugin.vars && installedPlugin.enabled}
			<div class='shadow-lg dark:shadow-none'>
				<Variables 
					on:change={onValuesChanged}
					variables={installedPlugin.vars} 
					values={variableValues}
					disabled={ !installedPlugin.enabled }
				/>
			</div>
		{/if}
		{#if installedPlugin}
			<div class='flex-grow bg-white dark:bg-gray-700 p-3 border-t border-gray-200 dark:border-gray-600 bg-opacity-75'>
				<PluginSourceBrowser 
					showEditButton={true}
					on:openEditor={ openEditor }
					files={installedPlugin.files} 
				/>
			</div>
		{/if}
	</div>
{/if}
