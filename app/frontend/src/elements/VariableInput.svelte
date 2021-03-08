<script>

	import { createEventDispatcher } from 'svelte'

    // dispatch handles the following events:
    // 		on:change - fired when the values change
    const dispatch = createEventDispatcher()

    // variable is the variable to represent.
    export let variable

    // values is a map of values which will be
    // set by the inputs.
    export let values = {}

    // disabled is whether this input is disabled or not.
    export let disabled = false

    // fire on change whenever values change
    $: valueDidChange(values)
	function valueDidChange(values) {
        dispatch('change')
	}

</script>

{#if variable}
    {#if variable.type === 'string'}
        <input 
            id='{variable.name}'
            class='border px-2 bg-gray-100 active:bg-gray-300 dark:text-gray-400 dark:bg-gray-700 border-gray-300 dark:border-gray-600 dark:bg-opacity-50'
            type='text' 
            bind:value='{ values[variable.name] }'
            disabled={disabled}
        />
    {:else if variable.type === 'boolean'}
        <label class='flex items-center'>
            <input 
                id='{variable.name}'
                class='border px-2 bg-gray-100 active:bg-gray-300 dark:text-gray-400 dark:bg-gray-700 border-gray-300 dark:border-gray-600 dark:bg-opacity-50'
                type='checkbox' 
                bind:checked='{ values[variable.name] }'
                disabled={disabled}
            />
            {#if values[variable.name]}
                <code class='ml-3'>TRUE</code>
            {:else}
                <code class='ml-3'>FALSE</code>
            {/if}
        </label>
    {:else if variable.type === 'number'}
        <input 
            id='{variable.name}'
            class='border px-2 bg-gray-100 active:bg-gray-300 dark:text-gray-400 dark:bg-gray-700 border-gray-300 dark:border-gray-600 dark:bg-opacity-50'
            type='number' 
            bind:value='{ values[variable.name] }'
            disabled={disabled}
        />
    {:else if variable.type === 'list'}
        <select 
            id='{variable.name}'
            class='border px-2 bg-gray-100 active:bg-gray-300 dark:text-gray-400 dark:bg-gray-700 border-gray-300 dark:border-gray-600 dark:bg-opacity-50'
            bind:value='{ values[variable.name] }'
            disabled={disabled}
        >
            {#each variable.options as option}
                <option 
                    value='{option}'
                >{option}</option>
            {/each}
        </select>
    {/if}
{/if}
