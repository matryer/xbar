<script>

	import { onMount, createEventDispatcher } from 'svelte'
	const dispatch = createEventDispatcher()

	export let on = false
	export let loading = false
	export let theme = 'blue'

	function click() {
		if (loading) { return }
		dispatch('click')
	}

	let animate = false
	onMount(() => {
		// start animating after a short period
		window.setTimeout(() => animate = true, 300)
	})
	
</script>

<style>
	.switch-container {
		display: inline-block;
		padding: 5px;
		vertical-align: middle;
		overflow: hidden;
	}
	.switch {
		display: flex;
		align-items: center;
		width: 32px;
		height: 18px;
		border-radius: 20px;
		background-color: #bbb;
		padding: 2px 4px;

		-moz-user-select: none;
		-khtml-user-select: none;
		-webkit-user-select: none;
		-ms-user-select: none;
		user-select: none;
	}
	.switch:hover {
		background-color: #aaa;
	}
	.switch .toggle {
		display: flex;
		align-items: center;
		justify-content: center;
		background-color: white;
		width: 12px;
		height: 12px;

		border-radius: 50%;
		line-height: 0.75em;
	}
	.switch.on {
	}
	.switch.on:hover {
		background-color: #43649f;
	}
	.switch.on .toggle {
		margin-left: 13px;
	}
	.disabled .toggle {
		background-color: transparent;
	}
	.animate {
		transition: 0.25s;
		transition-property: margin-left;
	}
	.switch.on.theme-blue {
		background-color: #4286d6;
	}
	.switch.on.theme-blue:hover {
		background-color: #43649f;
	}
	.switch.on.theme-bright {
		background-color: rgb(84, 146, 99);
	}
	.switch.on.theme-bright:hover {
		background-color: rgb(67, 117, 79);
	}
</style>

<a 
	class='switch-container'
	on:click|preventDefault|stopPropagation={click}
>
	<span 
		class='switch theme-{theme}'
		class:on={on}
	>
		<span 
			class='toggle'
			class:animate={animate}
			class:disabled={loading}
		>
		</span>
	</span>
</a>
