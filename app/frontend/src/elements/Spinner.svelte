<script>
    export let waiter = 0
    export let visible = false
    
    $: waiterUpdated(waiter)

    export let width = 24
    export let height = 24

    let timeout = null
    function waiterUpdated(v) {
        if (v == 0) {
            clearTimeout(timeout)
            visible = false
        }
        if (v == 1) {
            timeout = setTimeout(() => {
                if (waiter > 0) {
                    visible = true
                }
            }, 300)
        }
    }

</script>
<!-- By Sam Herbert (@sherb), for everyone. More @ http://goo.gl/7AJzbL -->
<svg class='inline-block' class:invisible='{!visible}' width="{width}" height="{height}" viewBox="0 0 38 38" xmlns="http://www.w3.org/2000/svg">
    <defs>
        <linearGradient x1="8.042%" y1="0%" x2="65.682%" y2="23.865%" id="a">
            <stop stop-color="#888" stop-opacity="0" offset="0%"/>
            <stop stop-color="#888" stop-opacity=".631" offset="63.146%"/>
            <stop stop-color="#888" offset="100%"/>
        </linearGradient>
    </defs>
    <g fill="none" fill-rule="evenodd">
        <g transform="translate(1 1)">
            <path d="M36 18c0-9.94-8.06-18-18-18" id="Oval-2" stroke="url(#a)" stroke-width="3">
                <animateTransform
                    attributeName="transform"
                    type="rotate"
                    from="0 18 18"
                    to="360 18 18"
                    dur="0.7s"
                    repeatCount="indefinite" />
            </path>
            <circle fill="#888" cx="36" cy="18" r="1">
                <animateTransform
                    attributeName="transform"
                    type="rotate"
                    from="0 18 18"
                    to="360 18 18"
                    dur="0.7s"
                    repeatCount="indefinite" />
            </circle>
        </g>
    </g>
</svg>