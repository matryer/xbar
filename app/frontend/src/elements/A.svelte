<script>
    export let href = ''
    export let underline = false
    export let cssclass = ''
</script>
<a 
    on:click
    {href}
    class='hover:underline {cssclass}'
    class:underline={underline}
><slot /></a>
