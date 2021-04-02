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

	"github.com/pkg/errors"
	"github.com/wailsapp/wails/v2/pkg/mac"

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
	configFilename  = filepath.Join(os.Getenv("HOME"), "Library", "Application Support", "xbar", "xbar.config.json")

	// concurrentIncomingURLs is the number of concurrent incoming URLs to handle at
	// the same time.
	concurrentIncomingURLs int = 1

	// apiRequestTimeout is the timeout for making API calls.
	apiRequestTimeout = 30 * time.Second
)

type app struct {
	runtime *wails.Runtime

	settings *settings

	// appMenu isn't visible - it's used for key shortcuts.
	appMenu           *menu.Menu
	contextMenus      []*menu.ContextMenu
	defaultTrayMenu   *menu.TrayMenu
	plugins           plugins.Plugins
	pluginTrays       map[string]*menu.TrayMenu
	menuParser        *MenuParser
	startsAtLoginMenu *menu.MenuItem
	autoupdateMenu    *menu.MenuItem
	appUpdatesMenu    *menu.MenuItem

	// Verbose gets whether verbose output will be printed
	// or not.
	Verbose bool

	CategoriesService *CategoriesService
	PluginsService    *PluginsService
	PersonService     *PersonService
	CommandService    *CommandService

	// incomingURLSemaphore is a buffered channel that keeps the
	// number of incoming URLs being parsed to one at a time.
	incomingURLSemaphore chan struct{}

	// lock protects menu items when RefreshAll
	// is called.
	// Also protects stopPluginsFunc, pluginsStoppedSignal,
	// menuIsOpen and isDarkMode.
	lock            sync.Mutex
	stopPluginsFunc context.CancelFunc
	// menuIsOpen keeps track of whether menus are open or not.
	// If they're open, they will not be updated.
	menuIsOpen bool
	// pluginsStoppedSignal is closed when plugins have stopped running.
	pluginsStoppedSignal  chan struct{}
	defaultTrayMenuActive bool
	// isDarkMode indicates whether the system is running
	// in dark mode or not.
	isDarkMode bool
}

// newApp makes a new app.
func newApp() (*app, error) {
	settings, err := loadSettings(configFilename)
	if err != nil {
		return nil, errors.Wrap(err, "loadSettings")
	}
	app := &app{
		settings:             settings,
		Verbose:              true,
		menuParser:           NewMenuParser(),
		incomingURLSemaphore: make(chan struct{}, concurrentIncomingURLs),
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
	app.contextMenus = []*menu.ContextMenu{
		menu.NewContextMenu("refreshContextMenu", menu.NewMenuFromItems(
			menu.Text("Refresh page data", nil, app.onBrowserHardRefreshMenuClicked),
			menu.Text("Refresh plugins", nil, app.onPluginsRefreshAllMenuClicked),
			menu.Text("Clear Cache", nil, app.onClearCacheMenuClicked),
		)),
	}

	app.appUpdatesMenu = &menu.MenuItem{
		Type:  menu.TextType,
		Label: "Check for updates…",
		Click: app.onCheckForUpdatesMenuClick,
	}

	app.autoupdateMenu = &menu.MenuItem{
		Label:   "Update automatically",
		Type:    menu.CheckboxType,
		Checked: app.settings.AutoUpdate,
		Click:   app.updateAutoupdate,
	}

	app.startsAtLoginMenu = &menu.MenuItem{
		Label:   "Start at Login",
		Type:    menu.CheckboxType,
		Checked: false,
		Click:   app.updateStartOnLogin,
	}
	startsAtLogin, err := mac.StartsAtLogin()
	if err != nil {
		if app.Verbose {
			log.Println("start at login:", err)
		}
		app.startsAtLoginMenu.Label = "Start at Login"
		app.startsAtLoginMenu.Disabled = true
	} else {
		app.startsAtLoginMenu.Checked = startsAtLogin
	}

	// client-side caching to cacheDirectory
	tp := httpcache.NewTransport(diskcache.New(cacheDirectory))
	client := &http.Client{
		Transport: tp,
		Timeout:   apiRequestTimeout,
	}
	app.CategoriesService = NewCategoriesService(client)
	app.PersonService = NewPersonService(client)
	app.CommandService = NewCommandService(app.RefreshAll)
	app.PluginsService = NewPluginsService(client, "https://xbarapp.com/docs/plugins/")
	app.PluginsService.OnRefresh = app.RefreshAll
	app.defaultTrayMenu = &menu.TrayMenu{
		Label: "xbar",
		Menu:  app.newXbarMenu(nil, false),
	}
	return app, nil
}

func (app *app) Start(runtime *wails.Runtime) {
	app.setDarkMode(runtime.System.IsDarkMode())
	runtime.Events.OnThemeChange(func(darkMode bool) {
		// keep track of dark mode changing, and refresh all
		// plugins if it does.
		app.setDarkMode(darkMode)
		app.RefreshAll()
	})
	app.runtime = runtime
	app.PluginsService.runtime = runtime
	app.CommandService.runtime = runtime
	app.CommandService.clearCache = app.clearCache
	// ensure the plugin directory is there
	if err := os.MkdirAll(pluginDirectory, 0777); err != nil {
		log.Println("failed to create plugin directory:", err)
	}
	app.RefreshAll()
	go func() {
		// wait before checking for updates
		time.Sleep(10 * time.Second)
		for {
			app.checkForUpdates(true)
			// check again in twelve hours
			time.Sleep(12 * time.Hour)
		}
	}()
}

func (app *app) RefreshAll() {
	app.lock.Lock()
	defer app.lock.Unlock()
	if app.stopPluginsFunc != nil {
		// plugins are already running - let's stop them
		// and wait for them to stop
		app.stopPluginsFunc()
		<-app.pluginsStoppedSignal
	}
	// remove plugins
	if app.defaultTrayMenuActive {
		// only default menu - remove it
		app.runtime.Menu.DeleteTrayMenu(app.defaultTrayMenu)
		app.defaultTrayMenuActive = false
	}
	for _, plugin := range app.plugins {
		m, ok := app.pluginTrays[plugin.Command]
		if !ok {
			continue
		}
		app.runtime.Menu.DeleteTrayMenu(m)
	}
	var err error
	app.plugins, err = plugins.Dir(pluginDirectory)
	if err != nil {
		app.onErr(err.Error())
		return
	}
	app.pluginTrays = make(map[string]*menu.TrayMenu)
	if len(app.plugins) == 0 {
		// no plugins - use default
		app.runtime.Menu.SetTrayMenu(app.defaultTrayMenu)
		app.defaultTrayMenuActive = true
		return
	}
	for _, plugin := range app.plugins {
		// Setup plugin
		plugin.OnCycle = app.onCycle
		plugin.OnRefresh = app.onRefresh
		if app.Verbose {
			//plugin.Stdout = os.Stdout
			plugin.Stderr = os.Stderr
			plugin.Debugf = plugins.DebugfPrefix(plugin.CleanFilename(), plugins.DebugfLog)
		}
		app.pluginTrays[plugin.Command] = &menu.TrayMenu{
			Label:   " ",
			Menu:    app.newXbarMenu(plugin, false),
			OnOpen:  app.onMenuWillOpen,
			OnClose: app.onMenuDidClose,
		}
		app.runtime.Menu.SetTrayMenu(app.pluginTrays[plugin.Command])
	}
	app.pluginsStoppedSignal = make(chan struct{})
	var ctx context.Context
	ctx, app.stopPluginsFunc = context.WithCancel(context.Background())
	go func() {
		// use stopPluginsFunc to allow the context to
		// be canceled - which will kill all running plugin subprocesses.
		app.plugins.Run(ctx)
		close(app.pluginsStoppedSignal)
	}()
}

// CheckForUpdates proactively checks for updates.
func (app *app) CheckForUpdates() {
	app.checkForUpdates(false)
}

func (app *app) onMenuWillOpen() {
	app.lock.Lock()
	defer app.lock.Unlock()
	app.menuIsOpen = true
}

func (app *app) onMenuDidClose() {
	app.lock.Lock()
	defer app.lock.Unlock()
	app.menuIsOpen = false
}

func (app *app) updateStartOnLogin(data *menu.CallbackData) {
	err := mac.StartAtLogin(data.MenuItem.Checked)
	if err != nil {
		app.startsAtLoginMenu.Label = "Start at Login unavailable"
		app.startsAtLoginMenu.Disabled = true
	}
	// We need to refresh all as the menuitem is used in multiple places.
	// If we don't refresh, only the menuitem clicked will toggle in the UI.
	app.refreshMenus()
}

func (app *app) updateAutoupdate(data *menu.CallbackData) {
	if data.MenuItem.Checked && app.settings.AutoUpdate {
		// nothing to do
		return
	}
	if !data.MenuItem.Checked && !app.settings.AutoUpdate {
		// nothing to do
		return
	}
	app.settings.AutoUpdate = data.MenuItem.Checked
	if err := app.settings.save(); err != nil {
		log.Println("err: updateAutoupdate:", err)
		return
	}
	if app.settings.AutoUpdate {
		go app.checkForUpdates(true)
	}
	// We need to refresh all as the menuitem is used in multiple places.
	// If we don't refresh, only the menuitem clicked will toggle in the UI.
	app.refreshMenus()
}

// onErr adds a single menu showing the specified error
// string.
func (app *app) onErr(err string) {
	if app.defaultTrayMenuActive {
		app.runtime.Menu.DeleteTrayMenu(app.defaultTrayMenu)
		app.defaultTrayMenuActive = false
	}
	errorMenu := &menu.Menu{}
	errorMenu.Append(menu.Text(err, nil, nil))
	errorMenu.Append(menu.Separator())
	errorMenu.Merge(app.newXbarMenu(nil, false))
	app.defaultTrayMenu = &menu.TrayMenu{
		Label: "⚠️ xbar",
		Menu:  errorMenu,
	}
	app.runtime.Menu.SetTrayMenu(app.defaultTrayMenu)
	app.defaultTrayMenuActive = true
}

// Shutdown shuts down the app.
func (app *app) Shutdown() {
	if app.stopPluginsFunc != nil {
		// it's possible this gets called _before_ the stop
		// func is set. In which case, we'll just ignore it.
		app.stopPluginsFunc()
	}
}

func (app *app) newXbarMenu(plugin *plugins.Plugin, asSubmenu bool) *menu.Menu {
	var items []*menu.MenuItem
	if plugin != nil {
		items = append(items, &menu.MenuItem{
			Type:        menu.TextType,
			Label:       "Refresh",
			Accelerator: keys.CmdOrCtrl("r"),
			Click: func(ctx *menu.CallbackData) {
				app.onPluginsRefreshMenuClicked(ctx, plugin)
			},
		})
	}
	items = append(items, &menu.MenuItem{
		Type:        menu.TextType,
		Label:       "Refresh all",
		Accelerator: keys.Combo("r", keys.CmdOrCtrlKey, keys.ShiftKey),
		Click:       app.onPluginsRefreshAllMenuClicked,
	})
	items = append(items, menu.Separator())
	if plugin != nil {
		items = append(items, &menu.MenuItem{
			Type:        menu.TextType,
			Label:       "Open plugin…",
			Accelerator: keys.CmdOrCtrl("e"),
			Click: func(_ *menu.CallbackData) {
				app.runtime.Window.Show()
				rel, err := filepath.Rel(pluginDirectory, plugin.Command)
				if err != nil {
					log.Println(err)
					return
				}
				app.runtime.Events.Emit("xbar.browser.openInstalledPlugin", map[string]string{
					"path": rel,
				})
			},
		})
	}
	items = append(items, &menu.MenuItem{
		Type:        menu.TextType,
		Label:       "Plugin browser…",
		Accelerator: keys.CmdOrCtrl("p"),
		Click:       app.onPluginsMenuClicked,
	})
	items = append(items, &menu.MenuItem{
		Type:  menu.TextType,
		Label: "Open plugin folder…",
		Click: app.onOpenPluginsFolderClicked,
	})
	items = append(items, menu.Separator())
	items = append(items, &menu.MenuItem{
		Type:     menu.TextType,
		Label:    fmt.Sprintf("xbar (%s)", version),
		Disabled: true,
	})
	items = append(items, app.appUpdatesMenu)
	items = append(items, app.autoupdateMenu)
	items = append(items, app.startsAtLoginMenu)
	items = append(items, menu.Separator())
	items = append(items, &menu.MenuItem{
		Type:        menu.TextType,
		Label:       "Quit xbar",
		Accelerator: keys.CmdOrCtrl("q"),
		Click:       app.onQuitMenuClicked,
	})
	if asSubmenu {
		m := menu.NewMenuFromItems(
			menu.SubMenu("xbar", &menu.Menu{
				Items: items,
			}),
		)
		return m
	}
	m := &menu.Menu{Items: items}
	return m
}

func (app *app) createDefaultMenus() {
	app.defaultTrayMenu = &menu.TrayMenu{
		Label: "xbar",
		Menu:  app.newXbarMenu(nil, false),
	}
}

func (app *app) onPluginsMenuClicked(_ *menu.CallbackData) {
	app.runtime.Window.Show()
}

func (app *app) onOpenPluginsFolderClicked(_ *menu.CallbackData) {
	_ = app.CommandService.OpenPath(pluginDirectory)
}

func (app *app) onQuitMenuClicked(_ *menu.CallbackData) {
	app.runtime.Quit()
}

func (app *app) onPluginsRefreshMenuClicked(_ *menu.CallbackData, p *plugins.Plugin) {
	p.TriggerRefresh()
}

func (app *app) onPluginsRefreshAllMenuClicked(_ *menu.CallbackData) {
	app.RefreshAll()
}

func (app *app) onBrowserRefreshMenuClicked(_ *menu.CallbackData) {
	app.runtime.Events.Emit("xbar.browser.refresh")
}

func (app *app) onBrowserHardRefreshMenuClicked(_ *menu.CallbackData) {
	app.clearCache(true)
	app.runtime.Events.Emit("xbar.browser.refresh")
}

func (app *app) onCheckForUpdatesMenuClick(_ *menu.CallbackData) {
	app.CheckForUpdates()
}

func (app *app) onClearCacheMenuClicked(_ *menu.CallbackData) {
	app.clearCache(false)
}

func (app *app) clearCache(passive bool) {
	// bit cheeky - but use the oslock in PluginsService to protect
	// against this from being run concurrently.
	app.PluginsService.osLock.Lock()
	defer app.PluginsService.osLock.Unlock()
	err := os.RemoveAll(cacheDirectory)
	if err != nil {
		if passive {
			return
		}
		app.runtime.Dialog.Message(&dialog.MessageDialog{
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
	app.runtime.Dialog.Message(&dialog.MessageDialog{
		Type:         dialog.InfoDialog,
		Title:        "Cache cleared",
		Message:      "The local cache was successfully cleared.",
		Buttons:      []string{"OK"},
		CancelButton: "OK",
	})
}

func (app *app) handleIncomingURL(url string) {
	// wait for a space
	app.incomingURLSemaphore <- struct{}{}
	defer func() {
		// free up this space
		<-app.incomingURLSemaphore
	}()
	log.Println("incoming URL: handleIncomingURL", url)
	incomingURL, err := parseIncomingURL(url)
	if err != nil {
		app.runtime.Dialog.Message(&dialog.MessageDialog{
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
		app.runtime.Window.Show()
		app.runtime.Events.Emit("xbar.incomingURL.openPlugin", map[string]string{
			"path": incomingURL.Params.Get("path"),
		})
	case "refreshPlugin":
		for _, plugin := range app.plugins {
			rel, err := filepath.Rel(pluginDirectory, plugin.Command)
			if err != nil {
				log.Println("incoming URL: rel for this failed", err)
				continue
			}
			if rel == incomingURL.Params.Get("path") {
				plugin.TriggerRefresh()
				return
			}
		}
	default:
		log.Printf("incoming URL: skipping, unknown action %q\n", incomingURL.Action)
	}
}

// onRefresh is fired when a plugin needs to refresh.
func (app *app) onRefresh(ctx context.Context, p *plugins.Plugin, _ error) {
	app.lock.Lock()
	defer app.lock.Unlock()
	if app.menuIsOpen {
		// don't update while the menu is open
		// as this can cause a crash
		return
	}
	tray, ok := app.pluginTrays[p.Command]
	if !ok {
		log.Println("no item - probably refreshing", tray.Label)
		return
	}
	app.updateLabel(tray, p)
	pluginMenu := app.menuParser.ParseItems(ctx, p.Items.ExpandedItems)
	if pluginMenu == nil {
		pluginMenu = app.newXbarMenu(p, false)
	} else {
		if app.settings.Terminal.AppleScriptTemplate != "false" {
			pluginMenu.Append(menu.Separator())
			pluginMenu.Append(menu.Text("Run in terminal…", keys.CmdOrCtrl("t"), func(_ *menu.CallbackData) {
				err := p.RunInTerminal(app.settings.Terminal.AppleScriptTemplate)
				if err != nil {
					app.runtime.Dialog.Message(&dialog.MessageDialog{
						Type:         dialog.ErrorDialog,
						Title:        "Run in terminal",
						Message:      err.Error(),
						Buttons:      []string{"OK"},
						CancelButton: "OK",
					})
					return
				}
			}))
		}
		pluginMenu.Append(menu.Separator())
		pluginMenu.Merge(app.newXbarMenu(p, true))
	}
	tray.Menu = pluginMenu
	app.runtime.Menu.SetTrayMenu(tray)
}

func (app *app) onCycle(_ context.Context, p *plugins.Plugin) {
	app.lock.Lock()
	defer app.lock.Unlock()
	if app.menuIsOpen {
		// don't update while the menu is open
		// as this can cause a crash
		return
	}
	tray, ok := app.pluginTrays[p.Command]
	if !ok {
		// no tray item - it's probably refreshing
		// so we'll just skip silently.
		return
	}
	if app.updateLabel(tray, p) {
		app.runtime.Menu.UpdateTrayMenuLabel(tray)
	}
}

// refreshMenus refreshes all tray menus to ensure they
// are in sync with the data, EG: checkbox sync
func (app *app) refreshMenus() {
	app.onMenuWillOpen()
	for _, tray := range app.pluginTrays {
		app.runtime.Menu.SetTrayMenu(tray)
	}
	app.onMenuDidClose()
}

func (app *app) updateLabel(tray *menu.TrayMenu, p *plugins.Plugin) bool {
	cycleItem := p.CurrentCycleItem()
	if cycleItem == nil {
		return false
	}
	tray.Label = cycleItem.DisplayText()
	tray.Image = cycleItem.Params.Image
	tray.FontName = cycleItem.Params.Font
	tray.FontSize = cycleItem.Params.Size
	tray.RGBA = cycleItem.Params.Color
	tray.Disabled = cycleItem.Params.Disabled
	if cycleItem.Params.TemplateImage != "" {
		tray.Image = cycleItem.Params.TemplateImage
		tray.MacTemplateImage = true
	}

	return true
}

// checkForUpdates looks to see if there's a newer version of xbar,
// downloads it and installs it.
// If passive is true, it won't complain if it fails.
func (app *app) checkForUpdates(passive bool) {
	if app.Verbose {
		log.Printf("checking for updates... (current: %s)", version)
		log.Println("updates: passive", passive)
		log.Println("updates: AutoUpdate", app.settings.AutoUpdate)
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
		if app.Verbose {
			log.Println("failed to check for updates:", err)
		}
		if !passive {
			app.runtime.Dialog.Message(&dialog.MessageDialog{
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
		if app.Verbose {
			log.Println("update: you have the latest version")
		}
		if !passive {
			app.runtime.Dialog.Message(&dialog.MessageDialog{
				Type:         dialog.InfoDialog,
				Title:        "You're up to date",
				Message:      fmt.Sprintf("%s is the latest version.", latest.TagName),
				Buttons:      []string{"OK"},
				CancelButton: "OK",
			})
		}
		return
	}
	if !app.settings.AutoUpdate {
		oneWeek := 168 * time.Hour
		// if this check is passive, and the release is only a few days
		// old - do a soft prompt.
		if passive && latest.CreatedAt.After(time.Now().Add(0-oneWeek)) {
			// Update menu text
			app.appUpdatesMenu.Label = "Install " + latest.TagName + "…"
			app.refreshMenus()
			return
		}
		switch app.runtime.Dialog.Message(&dialog.MessageDialog{
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
	} else {
		if app.Verbose {
			log.Println("autoupdating...")
		}
	}
	_, err = u.Update()
	if err != nil {
		if app.Verbose {
			log.Println("failed to update:", err)
		}
		if !passive {
			app.runtime.Dialog.Message(&dialog.MessageDialog{
				Type:         dialog.InfoDialog,
				Title:        "Update successful",
				Message:      "Please restart xbar for the changes to take effect.",
				Buttons:      []string{"OK"},
				CancelButton: "OK",
			})
		}
		return
	}
	err = u.Restart()
	if err != nil {
		if app.Verbose {
			log.Println("failed to restart:", err)
		}
		if !passive {
			app.runtime.Dialog.Message(&dialog.MessageDialog{
				Type:         dialog.InfoDialog,
				Title:        "Update successful",
				Message:      "Please restart xbar for the changes to take effect.",
				Buttons:      []string{"OK"},
				CancelButton: "OK",
			})
		}
		return
	}
}

// tickOS waits a beat after some os changes to give the system
// time to reflect those changes.
func tickOS() {
	time.Sleep(500 * time.Millisecond)
}

// setDarkMode sets the current dark mode state.
// It updates app.isDarkMode and also sets the
// appropriate environment variables.
func (app *app) setDarkMode(darkmode bool) {
	app.lock.Lock()
	defer app.lock.Unlock()
	app.isDarkMode = darkmode
	var err error
	if darkmode {
		err = os.Setenv("BitBarDarkMode", "true") // backwards compatibility
		if err != nil {
			log.Println("os.Setenv", err)
		}
		err = os.Setenv("XBARDarkMode", "true")
		if err != nil {
			log.Println("os.Setenv", err)
		}
	} else {
		err = os.Setenv("BitBarDarkMode", "false") // backwards compatibility
		if err != nil {
			log.Println("os.Setenv", err)
		}
		err = os.Setenv("XBARDarkMode", "false")
		if err != nil {
			log.Println("os.Setenv", err)
		}
	}
}
