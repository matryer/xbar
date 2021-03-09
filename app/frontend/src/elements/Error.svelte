<script>
	import { slide } from 'svelte/transition'
	import { openURL } from '../rpc.svelte'
	import { fireSigRefresh } from '../signals.svelte'
	import Button from './Button.svelte'
	export let err = null

	function reportError(err) {
		openURL('https://github.com/matryer/xbar/issues/new?title=' + encodeURIComponent(err))
	}

	function hideError() {
		err = null
	}

    // isNotFoundError returns true if the error is a 'not found'
    // error.
    export function isNotFoundError(err) {
        if (!err) {
            return false
        }
        const errStr = err.toString()
        if (errStr === '') {
            return false
        }
        return errStr.includes('no such file or directory')
    }

	let refreshing = false
	function onRefreshClicked() {
		refreshing = true
		window.setTimeout(() => {
			fireSigRefresh()
			refreshing = false
		}, 300)
	}

</script>
{#if err}
	{#if isNotFoundError(err)}
		<div class='px-8 py-4 bg-white bg-opacity-50 dark:bg-black dark:bg-opacity-25'>
			<code>404</code> Not found
			<Button cssclass='ml-4' on:click={ onRefreshClicked }>
				{#if refreshing}Refreshing&hellip;{:else}Refresh{/if}
			</Button>
		</div>
		<p class='p-8 py-4'>
			← Use the navigation to 
			find your way back.
		</p>
	{:else}
		<div transition:slide class='flex px-8 py-4 bg-yellow-200 bg-opacity-50'>
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
{/if}
