<script>

	import { Router } from 'svelte-hash-router'
	import { Events } from '@wails/runtime'
	import { 
			categories, selectedCategoryPath, selectCategory,
			installedPlugins, selectedInstalledPluginPath, selectInstalledPlugin,
	} from './pagedata.svelte'
	import { 
			refreshCategories, refreshInstalledPlugins, 
			openURL, refreshAllPlugins, clearCache,
	 } from './rpc.svelte'
	import A from './elements/A.svelte'
	import Button from './elements/Button.svelte'
	import Error from './elements/Error.svelte'
	import { globalWaiter, wait } from './waiters.svelte'
	import KeyboardShortcuts from './elements/KeyboardShortcuts.svelte'
    import { sigRefresh, fireSigRefresh, keyCombination } from './signals.svelte'

	let err

	$: installedPluginsEnabled = $installedPlugins ? $installedPlugins.filter(p => p.enabled) : []
	$: installedPluginsDisabled = $installedPlugins ? $installedPlugins.filter(p => !p.enabled) : []

	Events.On('xbar.browser.refresh', function(){
		fireSigRefresh()
	})

	Events.On('xbar.incomingURL.openPlugin', function(params){
		location.hash = `/plugin-details/${params.path}`
	})
	
	Events.On('xbar.browser.openInstalledPlugin', function(params){
		location.hash = `/installed-plugins/${params.path}`
	})
	

	$: if ($sigRefresh) {
		const done = wait()
		const done2 = wait()
		refreshCategories(categories)
			.catch(e => err = e)
			.finally(() => done())

		refreshInstalledPlugins(installedPlugins)
			.catch(e => err = e)
			.finally(() => done2())
	}

	function openSponsorPage() {
		openURL('https://github.com/sponsors/matryer')
			.catch(e => err = e)
	}
	
	function openBugPage() {
		openURL('https://github.com/matryer/xbar/issues')
			.catch(e => err = e)
	}

	function openPluginGuide(event) {
		event.preventDefault()
		openURL('https://github.com/matryer/xbar#writing-plugins')
			.catch(e => err = e)
	}

	// refresh will use fireSigRefresh to trigger refresh.
	// alt|cmd: will refresh all plugins too.
	//  +shift: will clear cache as well
	function onRefreshClick(keyCombination) {
		if (keyCombination.altKey || keyCombination.metaKey) {
			if (keyCombination.shiftKey) {
				// clear cache
				clearCache()
					.finally(() => {
						refreshAllPlugins()
						.finally(() => {
							fireSigRefresh()
						})
					})
				return
			} 
			// send refresh callr
			refreshAllPlugins()
				.finally(() => {
					fireSigRefresh()
				})
			return
		}
		fireSigRefresh()
	}

</script>

<style global>
	@import './styles.css';
	.top-bar {
		height: 50px;
	}
	.side-bar {
		width: 200px;
	}
</style>
<svelte:body 
	class='noselect'
></svelte:body>

<KeyboardShortcuts />

<Error err={err} />

<div class='flex h-full'>
	<div class='side-bar flex-shrink-0 flex flex-col h-full bg-opacity-25 bg-gray-400 text-gray-700 dark:text-gray-300'>
		<div 
			data-wails-drag 
			class='top-bar flex-shrink-0 flex justify-end p-4'
		>
			<div class='text-gray-400 dark:text-gray-300'>
				BETA
			</div>
		</div>
		<div class='p-3 pt-0 overflow-scroll'>
			{#if $installedPlugins}
				{#if installedPluginsEnabled.length}
					<h2 class='text-sm text-gray-500 dark:text-gray-400 text-bold mb-1'>
						Plugins
					</h2>
					<div class='mb-4'>
						{#each installedPluginsEnabled as installedPlugin}
							<a
								class='truncate block px-3 py-1 rounded text-gray-600 dark:text-gray-200 bg-opacity-25'
								class:bg-gray-400={$selectedInstalledPluginPath==installedPlugin.path}
								href='#/installed-plugins/{installedPlugin.path}'
								on:click|preventDefault='{ () => selectInstalledPlugin(installedPlugin.path) }'
							>
								{installedPlugin.name}
							</a>
						{/each}
					</div>
				{/if}
				{#if installedPluginsDisabled.length}
					<h2 class='text-sm text-gray-500 dark:text-gray-400 text-bold mb-1'>
						Disabled plugins
					</h2>
					<div class='mb-4'>
						{#each installedPluginsDisabled as installedPlugin}
							<a
								class='opacity-75 truncate block px-3 py-1 rounded text-gray-600 dark:text-gray-200 bg-opacity-25'
								class:bg-gray-400={$selectedInstalledPluginPath==installedPlugin.path}
								href='#/installed-plugins/{installedPlugin.path}'
								on:click|preventDefault='{ () => selectInstalledPlugin(installedPlugin.path) }'
							>
								{installedPlugin.name}
							</a>
						{/each}
					</div>
				{/if}
			{/if}
			{#if $categories}
				<h2 class='text-sm text-gray-500 dark:text-gray-400 text-bold mb-1'>
					Categories
				</h2>	
				{#each $categories as category}
					<a
						class='truncate block px-3 py-1 rounded text-gray-600 dark:text-gray-200 bg-opacity-25'
						class:bg-gray-400={$selectedCategoryPath==category.path}
						href='#/plugins/{category.path}'
						on:click|preventDefault='{ () => selectCategory(category.path) }'
					>
						{category.text}
					</a>
				{/each}
			{:else}
				&hellip;
			{/if}
			<p class='p-3 mt-8'>
				<strong>Got an idea of your own?</strong>
				Read our handy <A underline={true} on:click={ openPluginGuide }>Plugin guide</A>.
			</p>
		</div>
	</div>
	<div class='flex-grow h-full flex flex-col bg-opacity-25 bg-gray-200 text-gray-700 dark:text-gray-300'>
		<div class='top-bar flex-shrink-0 px-6 py-3 flex items-center space-x-5' data-wails-drag>
			<div>
				<Button 
					waiter={$globalWaiter}
					on:click='{ () => onRefreshClick($keyCombination) }'
					cssclass='py-1 opacity-75'
					style='{ $keyCombination.altKey ? 'primary' : 'default' }'
				>↺</Button>
				<!-- {#if $keyCombination.altKey || $keyCombination.metaKey}
					{#if $keyCombination.shiftKey}
						<span class='text-gray-800 dark:text-white ml-3'>
							Clear cache
						</span>
					{:else}
						<span class='text-gray-800 dark:text-white ml-3'>
							Refresh plugins
						</span>
					{/if}
				{/if} -->
			</div>
			<div class='flex-grow' ></div>
			<div>
				<Button on:click='{ openBugPage }'>
					Report bug
				</Button>
			</div>
			<div>
				<Button on:click='{ openSponsorPage }'>
					♥ Sponsor
				</Button>
			</div>
		</div>
		<div class='flex-1 overflow-scroll'>
			<Router />
		</div>
	</div>
</div>
