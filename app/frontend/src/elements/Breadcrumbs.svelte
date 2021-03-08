<script>
    
    import A from './A.svelte'

    // categoryPathSegments are the segments to show in the
    // breadcrumbs.
    export let categoryPathSegments = null

    // hideLast will hide the last segment.
    // Used to avoid repeating it when it is represented
    // in the slot.
    export let hideLast = false

    $: segments = (hideLast && categoryPathSegments) ? categoryPathSegments.filter(seg => !seg.isLast) : categoryPathSegments

</script>

<style>
    .breadcrumbs {
        background: rgb(243,244,246);
        background: linear-gradient(90deg, rgba(243,244,246,0.75) 0%, rgba(243,244,246,0) 100%);
    }
    @media (prefers-color-scheme: dark) {
        .breadcrumbs {
            background: rgb(55,65,81);
            background: linear-gradient(90deg, rgba(0,0,0,0.2) 0%, rgba(0,0,0,0) 100%);
        }
        input:focus, select:focus {
            outline: rgba(0,0,0,0.5) auto 1px;
            outline-color: rgba(0,0,0,0.5);
            outline-style: auto;
            outline-width: 2px;
        }
    }
</style>

<div>
    <div class='w-full'>
        <div class='breadcrumbs flex space-x-1 text-sm px-3 py-1'>
            <A href='#/'>Home</A>
            <span>﹥</span>
            {#if segments}
                {#each segments as categoryPathSegment}
                    <A href='#/plugins/{categoryPathSegment.path}'>
                        {categoryPathSegment.text}
                    </A>
                    <span>﹥</span>
                {/each}
            {/if}
            <span>
                <slot />
                &nbsp;
            </span>
        </div>
    </div>
</div>
