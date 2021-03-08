<script>

	import { params } from 'svelte-hash-router'
	import { getPersonDetails, openURL } from './rpc.svelte'
	import { wait } from './waiters.svelte'
	import Error from './elements/Error.svelte'
	import Button from './elements/Button.svelte'
	import Breadcrumbs from './elements/Breadcrumbs.svelte'
	import PluginCollection from './elements/PluginCollection.svelte'
	import { clearNav } from './pagedata.svelte'

	let err

	$: loadPersonDetails($params.username)
	let personDetails = null

	function loadPersonDetails(githubUsername) {
		clearNav()
		const done = wait()
		getPersonDetails(githubUsername)
			.then(details => personDetails = details)
			.catch(e => err = e)
			.finally(() => done())
	}

	function viewOnGitHub() {
		openURL(`https://github.com/${personDetails.person.githubUsername}`)
			.catch(e => err = e)
	}

</script>

<Error err={err} />

<Breadcrumbs>
	<span>
		Contributors
	</span>
	<span>﹥</span>
	<strong>
		<code>@{personDetails ? personDetails.person.githubUsername : ''}</code>
	</strong>
</Breadcrumbs>

{#if personDetails}
	<div class='flex space-x-4 max-w-2xl p-6'>
		<div>
			<img 
				alt='Profile pic for {personDetails.person.name}'
				src='{personDetails.person.imageURL}' 
			/>
		</div>
		<div>
			<h1 class='text-lg'>
				{#if personDetails.person.githubUsername != personDetails.person.name}
					<strong>{personDetails.person.name}</strong>
				{/if}
				<span class='text-gray-500 dark:text-gray-400'>
					@{personDetails.person.githubUsername}
				</span>
			</h1>
			{#if personDetails.person.bio}
				<p>
					{personDetails.person.bio}
				</p>
			{/if}
			<p class='mt-3'>
				<Button on:click={ viewOnGitHub }>View on GitHub</Button>
			</p>
		</div>
	</div>
	<div class='pt-6'>
		<PluginCollection plugins={personDetails.plugins} />
	</div>
{/if}
