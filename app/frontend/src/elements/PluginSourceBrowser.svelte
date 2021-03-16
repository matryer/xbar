<script>

    import { createEventDispatcher } from 'svelte'
    import Button from './Button.svelte'

    const dispatch = createEventDispatcher()
    
    export let showEditButton = false
    export let files

    function editFile(file) {
        dispatch('openEditor', {file})
    }
</script>
{#if files && files.length > 0}
    {#each files as file}
        <div class='flex'>
            <h2 class='flex-grow uppercase text-sm text-gray-500 mb-4'>
                Source code
            </h2>
            {#if showEditButton}
                <div class='pr-3'>
                    <Button
                        on:click={ () => editFile(file) }
                    >Open in external editor</Button>
                </div>
            {/if}
        </div>
        <pre class='whitespace-pre-wrap nice-wrapping text-sm pb-8'>
            <code>
                {file.content}
            </code>
        </pre>
    {/each}
{/if}
