<script>

	/*
	
		Usage:

			<PluginDetails plugin={plugin}>
				<div slot='action'>
					Actions like switches etc
					Goes in the top right.
				</div>
				<div slot='footer'>
					Additional detials in the footer of the
					card.
				</div>
			</PluginDetails>

	*/

	import Button from './Button.svelte'

	export let plugin

	function gotoPerson(githubUsername) {
		location.hash = `/people/${githubUsername}`
	}

</script>

<style>
	.plugin-desc {
		min-width: 200px;
	}
</style>

{#if plugin}
	<div class='flex flex-col bg-white dark:bg-black bg-opacity-25 mt-0 mb-6 rounded shadow-lg dark:shadow-none'>

		{#if $$slots.action}
			<div class='pt-4 px-4 flex'>
				<h1 class='flex-grow font-bold text-lg'>
					{plugin.title || plugin.filename}
				</h1>
				<slot name='action' />
			</div>
		{:else}
			<h1 class='p-4 pb-1 font-bold text-lg'>
				{plugin.title || plugin.filename}
			</h1>
		{/if}

		<p class='px-4 text-gray-500 dark:text-gray-400'>
			by 
			{#if plugin.authors}
				{#each plugin.authors as author}
					<span class='mr-2'>
						{author.name || author.githubUsername}
						{#if author.githubUsername}
							<Button on:click={() => gotoPerson(author.githubUsername)}>
								@{author.githubUsername}
							</Button>
						{/if}
					</span>
				{/each}
			{:else}
				Anon.
			{/if}
		</p>
		<div class='flex-grow p-4 plugin-desc break-word max-w-md mt-2 text-lg overflow-scroll'>
			<p>
				{plugin.desc}
			</p>
		</div>
		{#if $$slots.footer}
			<slot name='footer' />
		{/if}
	</div>
{/if}
