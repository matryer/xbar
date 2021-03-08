<script>
    import { categories, installedPlugins } from '../pagedata.svelte'
    import { refreshCategories, refreshInstalledPlugins } from '../rpc.svelte'
    import { wait } from '../waiters.svelte'
    function handleKeydown(e) {
        console.info(e)
        if (e.key === 'r' && e.metaKey && !e.shiftKey) {
            e.preventDefault()
            const done1 = wait()
            refreshCategories(categories)
                .finally(() => done1())
            const done2 = wait()
            refreshInstalledPlugins(installedPlugins)
                .finally(() => done2())
        }
    }
</script>
<svelte:window 
    on:keydown={handleKeydown}
/>
