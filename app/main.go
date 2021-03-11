package main

import (
	"fmt"
	"os"

	"github.com/wailsapp/wails/v2"
	"github.com/wailsapp/wails/v2/pkg/logger"
	"github.com/wailsapp/wails/v2/pkg/options"
	"github.com/wailsapp/wails/v2/pkg/options/mac"
)

// version is the xbar version (set by the git tag in build.sh).
var version string = "dev"

func main() {
	println("xbar", version)
	if err := run(); err != nil {
		fmt.Fprintf(os.Stderr, "%s\n", err)
		os.Exit(1)
	}
	println("xbar exited")
}

func run() error {
	app := newApp()
	wailsLogLevel := logger.ERROR
	app.Verbose = true
	if app.Verbose {
		wailsLogLevel = logger.DEBUG
	}
	err := wails.Run(&options.App{
		Title:             "xbar",
		Width:             1080,
		Height:            700,
		MinWidth:          800,
		MinHeight:         600,
		StartHidden:       true,
		HideWindowOnClose: true,
		Mac: &mac.Options{
			WebviewIsTransparent:          true,
			WindowBackgroundIsTranslucent: true,
			TitleBar:                      mac.TitleBarHiddenInset(),
			Menu:                          app.appMenu,
			ActivationPolicy:              mac.NSApplicationActivationPolicyAccessory,
			URLHandlers: map[string]func(string){
				// xbar://...
				"xbar": app.handleIncomingURL,
			},
		},
		LogLevel: wailsLogLevel,
		Startup:  app.Start,
		Shutdown: app.Shutdown,
		Bind: []interface{}{
			app.PersonService,
			app.CategoriesService,
			app.PluginsService,
			app.CommandService,
		},
	})
	if err != nil {
		return err
	}
	return nil
}
