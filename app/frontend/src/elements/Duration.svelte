<script>
	import { createEventDispatcher } from 'svelte'
	const dispatch = createEventDispatcher()
    import Spinner from './Spinner.svelte'

    export let value = {
        n: 0,
        unit: 'seconds',
    }
    export let disabled = false

    let spinnerVisible = false
    let timeout
    function onChange() {
        spinnerVisible = true
        clearTimeout(timeout)
        timeout = setTimeout(() => {
            dispatch('change')
            spinnerVisible = false
        }, 300)
    }

</script>

<style>
    .val {
        width: 35px;
        text-align: right;
    }
</style>

<input 
    class='val border bg-gray-100 active:bg-gray-300 dark:text-gray-400 dark:bg-gray-700 border-gray-300 dark:border-gray-600 dark:bg-opacity-50' 
    type='number' 
    bind:value={value.n}
    on:change={ onChange }
    disabled={disabled}
>
<select 
    class='mr-1 bg-gray-100 active:bg-gray-300 dark:text-gray-400 dark:bg-gray-700 border-gray-300 dark:border-gray-600 dark:bg-opacity-50'
    bind:value={value.unit}
    on:change={ onChange }
    disabled={disabled}
>
    <option>seconds</option>
    <option>minutes</option>
    <option>hours</option>
    <option>days</option>
</select>
<Spinner 
    visible={spinnerVisible} 
    width='16' height='16'
/>
