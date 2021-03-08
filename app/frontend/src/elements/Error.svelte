<script>
	import { slide } from 'svelte/transition'
	import { openURL } from '../rpc.svelte'
	export let err = null

	function reportError(err) {
		openURL('https://github.com/matryer/xbar/issues/new?title=' + encodeURIComponent(err))
	}

	function hideError() {
		err = null
	}
</script>
{#if err}
	<div transition:slide class='flex px-8 py-4 bg-yellow-200 bg-opacity-75'>
		<div class='flex-grow'>
			<strong>Something went wrong, this:</strong> {err}
			<a class='ml-4 underline' href='#/report-error' on:click|preventDefault='{ () => { reportError(err) } }'>Open issue</a>
		</div>
		<div>
			<a 
				href='/close'
				on:click|preventDefault={ hideError }
			>×</a>
		</div>
	</div>
{/if}
