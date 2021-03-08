package plugins

import (
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
	"sort"
	"strings"

	"github.com/pkg/errors"
)

// InstalledPlugin is a plugin that has been installed.
type InstalledPlugin struct {
	Counter         int             `json:"counter"`
	Name            string          `json:"name"`
	Path            string          `json:"path"`
	Enabled         bool            `json:"enabled"`
	RefreshInterval RefreshInterval `json:"refreshInterval"`
}

// disabledPluginExtension is the extension that is toggled at the
// end of plugins to enable/disable them.
const disabledPluginExtension = ".off"

// IsPluginEnabled gets whether the plugin is disabled or not.
func IsPluginEnabled(pluginPath string) bool {
	return !strings.HasSuffix(pluginPath, disabledPluginExtension)
}

// SetEnabled sets a plugin to enabled or disabled state, depending on the value
// of the enabled parameter.
func SetEnabled(pluginDirectory, installedPluginPath string, enabled bool) (string, error) {
	fullPluginPath := filepath.Join(pluginDirectory, installedPluginPath)
	// Enable a disabled plugin.
	if enabled && !IsPluginEnabled(installedPluginPath) {
		newFullPluginPath := strings.TrimSuffix(fullPluginPath, disabledPluginExtension)
		newInstalledPluginPath := strings.TrimSuffix(installedPluginPath, disabledPluginExtension)
		err := os.Rename(fullPluginPath, newFullPluginPath)
		return newInstalledPluginPath, err
	}
	// Disable an enabled plugin.
	if !enabled && IsPluginEnabled(installedPluginPath) {
		newFullPluginPath := fullPluginPath + disabledPluginExtension
		newInstalledPluginPath := installedPluginPath + disabledPluginExtension
		err := os.Rename(fullPluginPath, newFullPluginPath)
		return newInstalledPluginPath, err
	}
	return installedPluginPath, nil
}

// GetInstalledPlugins gets the installed fplugins from the pluginDirectory.
func GetInstalledPlugins(pluginDirectory string) ([]InstalledPlugin, error) {
	files, err := ioutil.ReadDir(pluginDirectory)
	if err != nil {
		if os.IsNotExist(err) {
			// no plugins directory - so no installed plugins
			// but not an error
			return nil, nil
		}
		return nil, errors.Wrap(err, "ReadDir")
	}
	var installedPlugins []InstalledPlugin
	for _, file := range files {
		if file.IsDir() {
			continue
		}
		if strings.HasPrefix(file.Name(), ".") {
			continue
		}
		if strings.HasSuffix(file.Name(), variableJSONFileExt) {
			// ignore variable payload files
			continue
		}
		enabled := !strings.HasSuffix(file.Name(), disabledPluginExtension)
		name := file.Name()
		installedPlugin := InstalledPlugin{
			Name:    name,
			Path:    file.Name(),
			Enabled: enabled,
		}
		_, _ = fmt.Sscanf(file.Name(), "%d-%v", &installedPlugin.Counter, &installedPlugin.Name)
		if !enabled {
			installedPlugin.Name = strings.TrimSuffix(installedPlugin.Name, disabledPluginExtension)
		}
		if installedPlugin.Counter == 0 {
			installedPlugin.Counter = 1
		}
		installedPlugins = append(installedPlugins, installedPlugin)
	}
	// sort them by name
	sort.Slice(installedPlugins, func(i, j int) bool {
		return installedPlugins[i].Name < installedPlugins[j].Name
	})
	return installedPlugins, nil
}
