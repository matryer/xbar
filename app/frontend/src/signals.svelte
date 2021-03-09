<script context='module'>

    import { writable } from "svelte/store"

    export const sigRefresh = writable(new Date())
    export const keyCombination = writable({
        altKey: false,
        shiftKey: false,
        metaKey: false,
    })

    export function fireSigRefresh() {
        sigRefresh.set(new Date())
    }

</script>
