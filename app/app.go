package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"time"

	"github.com/gregjones/httpcache"
	"github.com/gregjones/httpcache/diskcache"
	"github.com/wailsapp/wails/v2/pkg/options/dialog"

	"github.com/matryer/xbar/pkg/plugins"
	"github.com/matryer/xbar/pkg/update"
	wails "github.com/wailsapp/wails/v2"
	"github.com/wailsapp/wails/v2/pkg/menu"
	"github.com/wailsapp/wails/v2/pkg/menu/keys"
)

var (
	pluginDirectory = filepath.Join(os.Getenv("HOME"), "Library", "Application Support", "xbar", "plugins")
	cacheDirectory  = filepath.Join(os.Getenv("HOME"), "Library", "Application Support", "xbar", "cache")
)

type app struct {
	runtime *wails.Runtime

	// appMenu isn't visible - it's used for key shortcuts.
	appMenu         *menu.Menu
	defaultTrayMenu *menu.TrayMenu
	plugins         plugins.Plugins
	pluginTrays     map[string]*menu.TrayMenu
	menuParser      *MenuParser

	CategoriesService *CategoriesService
	PluginsService    *PluginsService
	PersonService     *PersonService
	CommandService    *CommandService

	// menuUpdateLock protects menu items when RefreshAll
	// is called.
	// Also protects stopPluginsFunc, pluginsStoppedSignal and menuIsOpen.
	menuUpdateLock  sync.Mutex
	stopPluginsFunc context.CancelFunc
	// menuIsOpen keeps track of whether menus are open or not.
	// If they're open, they will not be updated.
	menuIsOpen bool
	// pluginsStoppedSignal is closed when plugins have stopped running.
	pluginsStoppedSignal  chan (struct{})
	defaultTrayMenuActive bool
}

// newApp makes a new app.
func newApp() *app {
	app := &app{
		menuParser: NewMenuParser(),
	}
	app.appMenu = menu.NewMenuFromItems(
		menu.AppMenu(),
		menu.EditMenu(),
		menu.WindowMenu(),
		&menu.MenuItem{
			Type:  menu.SubmenuType,
			Label: "Browser",
			SubMenu: menu.NewMenuFromItems(
				menu.Text("Refresh", keys.CmdOrCtrl("r"), app.onBrowserRefreshMenuClicked),
				menu.Text("Clear cache and refresh", keys.Combo("r", keys.CmdOrCtrlKey, keys.ShiftKey), app.onBrowserHardRefreshMenuClicked),
			),
		},
	)

	// client-side caching to cacheDirectory
	tp := httpcache.NewTransport(diskcache.New(cacheDirectory))
	client := &http.Client{
		Transport: tp,
		Timeout:   3 * time.Minute,
	}

	app.CategoriesService = NewCategoriesService(client)
	app.PersonService = NewPersonService(client)
	app.CommandService = NewCommandService()
	app.PluginsService = NewPluginsService(client, "https://xbarapp.com/docs/plugins/")

	app.PluginsService.OnRefresh = app.RefreshAll
	app.createDefaultMenus()
	return app
}

func (a *app) RefreshAll() {
	a.menuUpdateLock.Lock()
	defer a.menuUpdateLock.Unlock()
	if a.stopPluginsFunc != nil {
		// plugins are already running - let's stop them
		// and wait for them to stop
		a.stopPluginsFunc()
		<-a.pluginsStoppedSignal
	}
	// remove plugins
	if len(a.plugins) == 0 && a.defaultTrayMenuActive {
		a.runtime.Menu.DeleteTrayMenu(a.defaultTrayMenu)
		a.defaultTrayMenuActive = false
	}
	for _, plugin := range a.plugins {
		menu, ok := a.pluginTrays[plugin.Command]
		if !ok {
			log.Println("weird: no menu for", plugin.Command)
			continue
		}
		a.runtime.Menu.DeleteTrayMenu(menu)
	}
	var err error
	a.plugins, err = plugins.Dir(pluginDirectory)
	if err != nil {
		a.onErr(err.Error())
		return
	}
	a.pluginTrays = make(map[string]*menu.TrayMenu)
	if len(a.plugins) == 0 {
		// no plugins - use default
		a.runtime.Menu.SetTrayMenu(a.defaultTrayMenu)
		a.defaultTrayMenuActive = true
		return
	}
	for _, plugin := range a.plugins {
		// Setup plugin
		plugin.OnCycle = a.onCycle
		plugin.OnRefresh = a.onRefresh
		plugin.Stdout = os.Stdout
		plugin.Stderr = os.Stderr
		plugin.Debugf = plugins.DebugfLog
		a.pluginTrays[plugin.Command] = &menu.TrayMenu{
			Label:   " ",
			Menu:    a.generatePreferencesMenu(plugin),
			OnOpen:  a.onMenuWillOpen,
			OnClose: a.onMenuDidClose,
		}
		a.runtime.Menu.SetTrayMenu(a.pluginTrays[plugin.Command])
	}
	a.pluginsStoppedSignal = make(chan struct{})
	var ctx context.Context
	ctx, a.stopPluginsFunc = context.WithCancel(context.Background())
	go func() {
		// use stopPluginsFunc to allow the context to
		// be canceled - which will kill all running plugin subprocesses.
		a.plugins.Run(ctx)
		close(a.pluginsStoppedSignal)
	}()
}

func (a *app) Start(runtime *wails.Runtime) {
	a.runtime = runtime
	a.PluginsService.runtime = runtime
	a.CommandService.runtime = runtime
	a.createDefaultMenus()
	// ensure the plugin directory is there
	if err := os.MkdirAll(pluginDirectory, 0777); err != nil {
		log.Println("failed to create plugin directory:", err)
	}
	a.RefreshAll()
	go a.checkForUpdates(true)
}

// CheckForUpdates proactively checks for updates.
func (a *app) CheckForUpdates() {
	a.checkForUpdates(false)
}

func (a *app) onMenuWillOpen() {
	a.menuUpdateLock.Lock()
	defer a.menuUpdateLock.Unlock()
	a.menuIsOpen = true
}

func (a *app) onMenuDidClose() {
	a.menuUpdateLock.Lock()
	defer a.menuUpdateLock.Unlock()
	a.menuIsOpen = false
}

// onErr adds a single menu showing the specified error
// string.
func (a *app) onErr(err string) {
	if a.defaultTrayMenuActive {
		a.runtime.Menu.DeleteTrayMenu(a.defaultTrayMenu)
		a.defaultTrayMenuActive = false
	}
	errorMenu := &menu.Menu{}
	errorMenu.Append(menu.Text(err, nil, nil))
	errorMenu.Append(menu.Separator())
	errorMenu.Merge(a.generatePreferencesMenu(nil))
	a.defaultTrayMenu = &menu.TrayMenu{
		Label: "⚠️ xbar",
		Menu:  errorMenu,
	}
	a.runtime.Menu.SetTrayMenu(a.defaultTrayMenu)
	a.defaultTrayMenuActive = true
}

// Shutdown shuts down the app.
func (a *app) Shutdown() {
	if a.stopPluginsFunc != nil {
		// it's possible this gets called _before_ the stop
		// func is set. In which case, we'll just ignore it.
		a.stopPluginsFunc()
	}
}

func (a *app) generatePreferencesMenu(plugin *plugins.Plugin) *menu.Menu {
	var items []*menu.MenuItem
	items = append(items, &menu.MenuItem{
		Type:        menu.TextType,
		Label:       "Refresh all",
		Accelerator: keys.Combo("r", keys.CmdOrCtrlKey, keys.ShiftKey),
		Click:       a.onPluginsRefreshMenuClicked,
	})
	items = append(items, menu.Separator())
	if plugin != nil {
		items = append(items, &menu.MenuItem{
			Type:        menu.TextType,
			Label:       "Open plugin…",
			Accelerator: keys.CmdOrCtrl("e"),
			Click: func(_ *menu.CallbackData) {
				a.runtime.Window.Show()
				rel, err := filepath.Rel(pluginDirectory, plugin.Command)
				if err != nil {
					log.Println(err)
					return
				}
				a.runtime.Events.Emit("xbar.browser.openInstalledPlugin", map[string]string{
					"path": rel,
				})
			},
		})
	}
	items = append(items, &menu.MenuItem{
		Type:        menu.TextType,
		Label:       "Plugin browser…",
		Accelerator: keys.CmdOrCtrl("p"),
		Click:       a.onPluginsMenuClicked,
	})
	items = append(items, &menu.MenuItem{
		Type:  menu.TextType,
		Label: "Open plugin folder…",
		Click: a.onOpenPluginsFolderClicked,
	})
	items = append(items, menu.Separator())
	items = append(items, &menu.MenuItem{
		Type:     menu.TextType,
		Label:    fmt.Sprintf("xbar (%s)", version),
		Disabled: true,
	})
	items = append(items, &menu.MenuItem{
		Type:  menu.TextType,
		Label: "Check for updates…",
		Click: a.onCheckForUpdatesMenuClick,
	})
	items = append(items, &menu.MenuItem{
		// todo: remove this item once cmd+R is working #refresh
		Type:  menu.TextType,
		Label: "Clear cache",
		Click: a.onClearCacheMenuClicked,
	})
	items = append(items, menu.Separator())
	items = append(items, &menu.MenuItem{
		Type:        menu.TextType,
		Label:       "Quit xbar",
		Accelerator: keys.CmdOrCtrl("q"),
		Click:       a.onQuitMenuClicked,
	})
	return menu.NewMenuFromItems(
		menu.SubMenu("Preferences", &menu.Menu{
			Items: items,
		}),
	)
}

func (a *app) createDefaultMenus() {
	a.defaultTrayMenu = &menu.TrayMenu{
		Label: "xbar",
		Menu:  a.generatePreferencesMenu(nil),
	}
}

func (a *app) onPluginsMenuClicked(_ *menu.CallbackData) {
	a.runtime.Window.Show()
}

func (a *app) onOpenPluginsFolderClicked(_ *menu.CallbackData) {
	a.CommandService.OpenPath(pluginDirectory)
}

func (a *app) onQuitMenuClicked(_ *menu.CallbackData) {
	a.runtime.Quit()
}

func (a *app) onPluginsRefreshMenuClicked(_ *menu.CallbackData) {
	a.RefreshAll()
}

func (a *app) onBrowserRefreshMenuClicked(_ *menu.CallbackData) {
	a.runtime.Events.Emit("xbar.browser.refresh")
}

func (a *app) onBrowserHardRefreshMenuClicked(ctx *menu.CallbackData) {
	a.clearCache(true)
	a.runtime.Events.Emit("xbar.browser.refresh")
}

func (a *app) onCheckForUpdatesMenuClick(_ *menu.CallbackData) {
	a.CheckForUpdates()
}

func (a *app) onClearCacheMenuClicked(_ *menu.CallbackData) {
	a.clearCache(false)
}

func (a *app) clearCache(passive bool) {
	// bit cheeky - but use the oslock in PluginsService to protect
	// against this from being run concurrently.
	a.PluginsService.osLock.Lock()
	defer a.PluginsService.osLock.Unlock()
	err := os.RemoveAll(cacheDirectory)
	if err != nil {
		if passive {
			return
		}
		a.runtime.Dialog.Message(&dialog.MessageDialog{
			Type:         dialog.ErrorDialog,
			Title:        "Clear cache failed",
			Message:      err.Error(),
			Buttons:      []string{"OK"},
			CancelButton: "OK",
		})
		return
	}
	if passive {
		return
	}
	a.runtime.Dialog.Message(&dialog.MessageDialog{
		Type:         dialog.InfoDialog,
		Title:        "Cache cleared",
		Message:      "The local cache was successfully cleared.",
		Buttons:      []string{"OK"},
		CancelButton: "OK",
	})
}

func (a *app) handleIncomingURL(url string) {
	incomingURL, err := parseIncomingURL(url)
	if err != nil {
		a.runtime.Dialog.Message(&dialog.MessageDialog{
			Type:         dialog.ErrorDialog,
			Title:        "Invalid URL",
			Message:      err.Error(),
			Buttons:      []string{"OK"},
			CancelButton: "OK",
		})
		return
	}
	switch incomingURL.Action {
	case "openPlugin":
		a.runtime.Window.Show()
		a.runtime.Events.Emit("xbar.incomingURL.openPlugin", map[string]string{
			"path": incomingURL.Params.Get("path"),
		})
	case "refreshPlugin":
		// todo: refresh only the specified plugin
		a.RefreshAll()
	}
}

func (a *app) onRefresh(ctx context.Context, p *plugins.Plugin, _ error) {
	a.menuUpdateLock.Lock()
	defer a.menuUpdateLock.Unlock()
	if a.menuIsOpen {
		// don't update while the menu is open
		// as this can cause a crash
		return
	}
	tray, ok := a.pluginTrays[p.Command]
	if !ok {
		log.Println("todo: no item - probably refreshing", tray.Label)
		return
	}
	a.updateLabel(tray, p)
	pluginMenu := a.menuParser.ParseItems(ctx, p.Items.ExpandedItems)
	if pluginMenu == nil {
		pluginMenu = a.generatePreferencesMenu(p)
	} else {
		pluginMenu.Append(menu.Separator())
		pluginMenu.Merge(a.generatePreferencesMenu(p))
	}
	tray.Menu = pluginMenu
	a.runtime.Menu.SetTrayMenu(tray)
}

func (a *app) onCycle(_ context.Context, p *plugins.Plugin) {
	a.menuUpdateLock.Lock()
	defer a.menuUpdateLock.Unlock()
	if a.menuIsOpen {
		// don't update while the menu is open
		// as this can cause a crash
		return
	}
	tray, ok := a.pluginTrays[p.Command]
	if !ok {
		// no tray item - it's probably refreshing
		// so we'll just skip silently.
		return
	}
	if a.updateLabel(tray, p) {
		a.runtime.Menu.UpdateTrayMenuLabel(tray)
	}
}

func (a *app) updateLabel(tray *menu.TrayMenu, p *plugins.Plugin) bool {
	cycleItem := p.CurrentCycleItem()
	if cycleItem == nil {
		return false
	}
	if tray.Label == cycleItem.String() {
		return false // no change
	}
	tray.Label = cycleItem.DisplayText()
	tray.Icon = cycleItem.Params.Image
	return true
}

// checkForUpdates looks to see if there's a newer version of xbar,
// downloads it and installs it.
// If passive is true, it won't complain if it fails.
func (a *app) checkForUpdates(passive bool) {
	if version == "dev" {
		log.Println("dev: skipping update check")
		if !passive {
			a.runtime.Dialog.Message(&dialog.MessageDialog{
				Type:         dialog.ErrorDialog,
				Title:        "Update check failed",
				Message:      "Cannot check for updates with a dev build. Build for production and try again.",
				Buttons:      []string{"OK"},
				CancelButton: "OK",
			})
		}
		return
	}
	u := update.Updater{
		CurrentVersion: version,
		//LatestReleaseGitHubEndpoint: "https://api.github.com/repos/matryer/xbar/releases/latest",
		LatestReleaseGitHubEndpoint: "https://api.github.com/repos/matryer/xbar/releases/latest",
		Client:                      &http.Client{Timeout: 10 * time.Minute},
		SelectAsset: func(release update.Release, asset update.Asset) bool {
			// get the .tar.gz file
			return strings.HasSuffix(asset.Name, ".tar.gz")
		},
		DownloadBytesLimit: 10_741_824, // 10MB
	}
	latest, hasUpdate, err := u.HasUpdate()
	if err != nil {
		log.Println("failed to check for updates:", err)
		if !passive {
			a.runtime.Dialog.Message(&dialog.MessageDialog{
				Type:         dialog.ErrorDialog,
				Title:        "Update check failed",
				Message:      err.Error(),
				Buttons:      []string{"OK"},
				CancelButton: "OK",
			})
		}
		return
	}
	if !hasUpdate {
		// they are using the latest version
		if !passive {
			a.runtime.Dialog.Message(&dialog.MessageDialog{
				Type:         dialog.InfoDialog,
				Title:        "You're up to date",
				Message:      fmt.Sprintf("%s is the latest version.", latest.TagName),
				Buttons:      []string{"OK"},
				CancelButton: "OK",
			})
		}
		return
	}
	switch a.runtime.Dialog.Message(&dialog.MessageDialog{
		Type:          dialog.QuestionDialog,
		Title:         "Update xbar?",
		Message:       fmt.Sprintf("xbar %s is now available (you have %s).\n\nWould you like to update?", latest.TagName, u.CurrentVersion),
		Buttons:       []string{"Update", "Later"},
		DefaultButton: "Update",
		CancelButton:  "Later",
	}) {
	case "Update":
		// continue
	case "Later":
		return
	}
	_, err = u.Update()
	if err != nil {
		a.runtime.Dialog.Message(&dialog.MessageDialog{
			Type:         dialog.ErrorDialog,
			Title:        "Update failed",
			Message:      err.Error(),
			Buttons:      []string{"OK"},
			CancelButton: "OK",
		})
		return
	}
	err = u.Restart()
	if err != nil {
		a.runtime.Dialog.Message(&dialog.MessageDialog{
			Type:         dialog.InfoDialog,
			Title:        "Update successful",
			Message:      "Please restart xbar for the changes to take effect.",
			Buttons:      []string{"OK"},
			CancelButton: "OK",
		})
		return
	}
}

// tickOS waits a beat after some os changes to give the system
// time to reflect those changes.
func tickOS() {
	time.Sleep(500 * time.Millisecond)
}
