package main

import (
	"log"

	"github.com/wailsapp/wails/v2"
	"github.com/wailsapp/wails/v2/pkg/logger"
	"github.com/wailsapp/wails/v2/pkg/options"
	"github.com/wailsapp/wails/v2/pkg/options/mac"
)

// version is the xbar version (set by the git tag in build.sh).
var version string = "dev"

func main() {
	app := newApp()
	err := wails.Run(&options.App{
		Title:             "xbar",
		Width:             1060,
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
				"xbar": app.handleIncomingURL,
			},
		},
		LogLevel: logger.DEBUG,
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
		log.Fatal(err)
	}
	println("xbar exited")
}
