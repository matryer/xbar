<script>
	import { createEventDispatcher } from 'svelte'
    import { refreshAllPlugins } from '../rpc.svelte'

    // dispatch handles the following events:
    // 		on:change - fired when the values change
    const dispatch = createEventDispatcher()

    import VariableInput from './VariableInput.svelte'

    export let variables = null
    export let values
    export let disabled = false

    let onChangeDebounceTimeout
    function onChange() {
        clearTimeout(onChangeDebounceTimeout)
        onChangeDebounceTimeout = setTimeout(fireOnChangeEvent, 300)
    }

    function fireOnChangeEvent() {
        dispatch('change')
    }

    function refresh() {
        dispatch('change')
        setTimeout(refreshAllPlugins, 100)
    }

</script>

{#if variables && variables.length && values}
    <div class='p-6 pb-0 bg-white/25 dark:bg-gray-700/50 border-t border-gray-100 dark:border-gray-600'>
        <table class='table-auto'>
            {#each variables as variable}
                <tr>
                    <td class='py-3 pr-6 text-sm'>
						<label for='{variable.name}'>
							<code>
								{variable.label}
							</code>
						</label>
                    </td>
                    <td class='py-3 pr-6'>
						<VariableInput 
                            on:change={onChange}
							values={values}
							variable={variable}
                            disabled={disabled}
						/>
                    </td>
                    <td class='py-3 pr-6 max-w-md text-sm text-gray-500 dark:text-gray-400'>
						{variable.desc}
                    </td>
                </tr>
            {/each}
        </table>
        <p class='pt-3 pb-6 opacity-75 text-sm'>
            <span class='bg-yellow-100 bg-opacity-50 dark:bg-transparent'>💡 You must <a href='#/refresh-all' class='underline' on:click|preventDefault={refresh}>refresh the plugin</a> for changes to take effect.</span>
        </p>
    </div>
{/if}
