<script context='module'>

    import { writable } from "svelte/store"

    export const categories = writable(null)
    export const installedPlugins = writable(null)

    export const selectedCategoryPath = writable(null)
    export const selectedInstalledPluginPath = writable(null)

    export function selectCategory(categoryPath) {
        selectedInstalledPluginPath.set(null)
        selectedCategoryPath.set(categoryPath)
        location.hash = `/plugins/${categoryPath}`
    }

    export function selectInstalledPlugin(installedPluginPath) {
        selectedCategoryPath.set(null)
        selectedInstalledPluginPath.set(installedPluginPath)
        location.hash = `/installed-plugins/${installedPluginPath}`
    }

    export function clearNav() {
        selectedCategoryPath.set(null)
        selectedInstalledPluginPath.set(null)
    }

</script>
