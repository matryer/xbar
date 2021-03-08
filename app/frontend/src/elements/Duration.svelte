<script>
	import { createEventDispatcher } from 'svelte'
	const dispatch = createEventDispatcher()
    import Spinner from './Spinner.svelte'

    export let value = {
        n: 0,
        unit: 'seconds',
    }

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
    class='val border dark:text-gray-800' 
    type='number' 
    bind:value={value.n}
    on:change={ onChange }
>
<select 
    class='mr-1 dark:text-gray-800'
    bind:value={value.unit}
    on:change={ onChange }
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
