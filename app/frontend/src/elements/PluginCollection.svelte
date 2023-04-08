<script>
	import Button from './Button.svelte'
	import A from './A.svelte'
	import { installedPlugins, selectInstalledPlugin } from '../pagedata.svelte'
	import { installPlugin, refreshInstalledPlugins } from '../rpc.svelte'
	import { wait } from '../waiters.svelte'

	export let plugins = null

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
    
	function gotoPerson(githubUsername) {
        location.hash = `/people/${githubUsername}`
    }

</script>

<style>

	.author-pic {
		width: 25px;
		height: 25px;
	}
	.plugin-pic {
		max-width: 64px;
		max-height: 64px;
	}
	.plugin-desc {
		max-height: 7em;
		white-space: normal;
		text-overflow: ellipsis;
		overflow: hidden;
	}

</style>

{#if plugins}
	<div class='flex flex-wrap p-3'>
		{#each plugins as plugin}
			<div
				class='flex flex-col bg-white/25 dark:bg-black/25 m-3 mt-0 mb-6 w-80 rounded shadow-lg dark:shadow-none'
			>
				<div class='flex-grow'>
					<h2 class='text-black flex-grow dark:text-white text-lg p-4 pb-0'>
						<a href='#/plugin-details/{plugin.path}'>
							{plugin.title}
						</a>
					</h2>
					<div class='flex'>
						{#if plugin.imageURL}
						<a href='#/plugin-details/{plugin.path}'>
							<img 
								class='plugin-pic float-left m-4 mr-0'
								alt='Photo for {plugin.title}' 
								src='{plugin.imageURL}'
								onerror='this.style.display="none"'
							>
						</a>
						{/if}
						<p class='plugin-desc mb-2 p-4 test-gray break-words'>
							{plugin.desc}
						</p>
					</div>
				</div>
				{#if plugin.authors && plugin.authors.length}
					<div class='flex items-center space-x-2 p-4'>
						<img 
							class='author-pic rounded-full'
							src='{plugin.authors[0].imageURL}'
							alt='Profile picture for {plugin.authors[0].name}'
							onerror='this.style.display="none"'
							on:click={ gotoPerson(plugin.authors[0].githubUsername) }
						/>
						<p 
							class='ml-2 overflow-hidden overflow-ellipsis flex-initial'
						>
							<A href='#/people/{plugin.authors[0].githubUsername}'>@{plugin.authors[0].githubUsername}</A>
						</p>
						<div class='flex-grow'></div>
						<div class='flex-shrink-0'>
							<Button
								style='primary'
								on:click={() => install(plugin)}
							>
								Install
							</Button>
						</div>
					</div>
				{/if}
			</div>
		{/each}
	</div>
{/if}
