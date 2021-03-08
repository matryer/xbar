<script context='module'>

    /*
    
        The globalWaiter drives the app spinner.

        Whenever you're going to perform a blocking network operation,
        like loading data, call wait(). wait() returns a done function,
        which you should call when it's finished.

        const done = wait()
        operation()
            .then(() => {})
            .catch(() => {})
            .finally(() => done())

        The Spinner is driven by this value, and includes a slight delay
        in case the operation completes within a short period.

    */

    import { writable } from "svelte/store"

    // globalWaiter is a counter used to keep track
    // of network activity.
    export const globalWaiter = writable(0)

    export function wait() {
        globalWaiter.update(v => v + 1)
        return function() {
            globalWaiter.update(v => v - 1)
        }
    }

</script>
