<script context='module'>

	export function openURL(url) {
		return backend.main.CommandService.OpenURL(url)
	}

	export function openFile(path) {
		return backend.main.CommandService.OpenFile(path)
	}

	export function refreshCategories(categories) {
		return backend.main.CategoriesService.GetCategories()
			.then(result => categories.set(result))
	}

	export function getPlugins(categoryPath) {
		return backend.main.PluginsService.GetPlugins(categoryPath)
	}

	export function getPlugin(pluginPath) {
		return backend.main.PluginsService.GetPlugin(pluginPath)
	}

	export function getFeaturedPlugins() {
		return backend.main.PluginsService.GetFeaturedPlugins()
	}

	export function getPersonDetails(githubUsername) {
		return backend.main.PersonService.GetPersonDetails(githubUsername)
	}

	export function installPlugin(plugin) {
		const pluginInfo = {
			title: plugin.title,
			path: plugin.path,
		}
		return backend.main.PluginsService.InstallPlugin(pluginInfo)
	}

	export function uninstallPlugin(plugin) {
		const pluginInfo = {
			title: plugin.title,
			path: plugin.path,
		}
		return backend.main.PluginsService.UninstallPlugin(pluginInfo)
	}

	export function refreshInstalledPlugins(installedPlugins) {
		return backend.main.PluginsService.GetInstalledPlugins()
			.then(result => installedPlugins.set(result))
	}

	export function getInstalledPluginMetadata(installedPluginPath) {
		return backend.main.PluginsService.GetInstalledPluginMetadata(installedPluginPath)
	}

	export function loadVariableValues(installedPluginPath) {
		return backend.main.PluginsService.LoadVariableValues(installedPluginPath)
	}
	
	export function saveVariableValues(installedPluginPath, values) {
		return backend.main.PluginsService.SaveVariableValues(installedPluginPath, values)
	}

	export function setEnabled(installedPluginPath, enabled) {
		return backend.main.PluginsService.SetEnabled(installedPluginPath, enabled)
	}

	export function setRefreshInterval(installedPluginPath, refreshInterval) {
		return backend.main.PluginsService.SetRefreshInterval(installedPluginPath, refreshInterval)
	}

	export function refreshAllPlugins() {
		return backend.main.CommandService.RefreshAllPlugins()
	}

	export function clearCache() {
		return backend.main.CommandService.ClearCache()
	}

	// getCategoryByPath gets a cateogry by path.
	// Pass in categories, imported from this file.
	// getCategoryByPath($categories, categoryPath)
	export function getCategoryByPath(categories, categoryPath) {
		for (let i = 0; i < categories.length; i++) {
			if (categories[i].path === categoryPath) {
				return categories[i]
			}
			const foundInChildren = getCategoryByPath(categories[i].children, categoryPath)
			if (foundInChildren) {
				return foundInChildren
			}
		}
		return null // not found
	}

</script>
