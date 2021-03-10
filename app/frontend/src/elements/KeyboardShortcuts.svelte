<script>
    
    import { fireSigRefresh } from '../signals.svelte'

    function handleKeydown(e) {
        if (e.key === 'r' && e.metaKey && !e.shiftKey) {
            e.preventDefault()
            fireSigRefresh()
            return
        }
        if (e.key === 'w' && e.metaKey && !e.shiftKey) {
            e.preventDefault()
            backend.main.CommandService.WindowHide()
            return
        }
        if (e.key === 'm' && e.metaKey && !e.shiftKey) {
            e.preventDefault()
            backend.main.CommandService.WindowMinimise()
            return
        }
    }
    
</script>
<svelte:window 
    on:keydown={handleKeydown}
/>
