<script context='module'>

    import { writable } from "svelte/store"

    export const sigRefresh = writable(new Date())

    export function fireSigRefresh() {
        sigRefresh.set(new Date())
    }

</script>