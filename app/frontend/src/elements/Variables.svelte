<script>
	import { createEventDispatcher } from 'svelte'

    // dispatch handles the following events:
    // 		on:change - fired when the values change
    const dispatch = createEventDispatcher()

    import VariableInput from './VariableInput.svelte'

    export let variables = null
    export let values
    export let debounce = 1000
    export let disabled = false

    let _debounceTimer
    function valueDidChange() {
        clearTimeout(_debounceTimer)
        _debounceTimer = setTimeout(() => {
            dispatch('change')
        }, debounce)
    }

</script>

{#if variables && variables.length && values}
    <div class='p-6 bg-white dark:bg-gray-700 dark:bg-opacity-25 bg-opacity-50 border-t border-gray-100 dark:border-gray-600'>
        <table class='table-auto'>
            {#each variables as variable}
                <tr>
                    <td class='py-3 pr-6'>
						<label for='{variable.name}'>
							<code>
								{variable.name}
							</code>
						</label>
                    </td>
                    <td class='py-3 pr-6'>
						<VariableInput 
							on:change={valueDidChange}
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
    </div>
{/if}
