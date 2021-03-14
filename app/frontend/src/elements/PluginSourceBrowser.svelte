<script>
    import { openFile } from '../rpc.svelte'
    import Error from './Error.svelte'
    import Button from './Button.svelte'
    export let files

    let errEdit
    function editFile(file) {
        openFile(file.path)
            .catch(e => errEdit = e)
    }
</script>
{#if files && files.length > 0}
    {#if errEdit}
        <div class='mb-3'>
            <Error err={errEdit} />
        </div>
    {/if}
    {#each files as file}
        <div class='flex'>
            <h2 class='flex-grow uppercase text-sm text-gray-500 mb-4'>
                Source code
            </h2>
            <div class='pr-3'>
                <Button
                    on:click={ () => editFile(file) }
                >Edit</Button>
            </div>
        </div>
        <pre class='whitespace-pre-wrap nice-wrapping text-sm pb-8'>
            <code>
                {file.content}
            </code>
        </pre>
    {/each}
{/if}
