<script>
    
    import { fireSigRefresh } from '../signals.svelte'

    function handleKeydown(e) {
        if (e.key === 'r' && e.metaKey && !e.shiftKey) {
            e.preventDefault()
            fireSigRefresh()
        }
    }
    
</script>
<svelte:window 
    on:keydown={handleKeydown}
/>
