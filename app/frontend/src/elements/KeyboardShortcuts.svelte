<script>
    
    import { fireSigRefresh, keyCombination } from '../signals.svelte'

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
        let combo = {
            altKey: e.altKey,
            shiftKey: e.shiftKey,
            metaKey: e.metaKey,
        }
        keyCombination.set(combo)
    }

    function handleKeyUp(e) {
        keyCombination.set({
            altKey: false,
            shiftKey: false,
            metaKey: false,
        })
    }
    
</script>
<svelte:window 
    on:keydown={handleKeydown}
    on:keyup={handleKeyUp}
/>
