import App from './App.svelte'
import { ready } from '@wails/runtime'
import { routes } from 'svelte-hash-router'
import Homepage from './Homepage.svelte'
import PluginsList from './PluginsList.svelte'
import PluginView from './PluginView.svelte'
import PeopleView from './PersonView.svelte'
import InstalledPluginView from './InstalledPluginView.svelte'

let app;

routes.set({
	'/': Homepage,
	'/plugins/*': PluginsList,
	'/installed-plugins/*': InstalledPluginView,
	'/plugin-details/*': PluginView,
	'/people/:username': PeopleView,
})

ready(() => {
	app = new App({
		target: document.body,
	});
});

export default app;
