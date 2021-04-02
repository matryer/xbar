package main

import (
	"context"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"net/url"
	"os"
	"path/filepath"
	"sync"
	"time"

	"github.com/matryer/xbar/pkg/metadata"
	"github.com/matryer/xbar/pkg/plugins"
	"github.com/pkg/errors"
	wails "github.com/wailsapp/wails/v2"
	"github.com/wailsapp/wails/v2/pkg/options/dialog"
)

// PluginsService access remote plugin information.
type PluginsService struct {
	runtime *wails.Runtime
	baseURL string

	client *http.Client

	// osLock is used whenever there are operating system changes,
	// like renaming files. This prevents overlap and potentially strange
	// state.
	// todo: move this to a better place.
	osLock sync.Mutex

	// OnRefresh is called whenever the menus should
	// be updated.
	OnRefresh func()
}

// NewPluginsService makes a new PluginsService.
func NewPluginsService(client *http.Client, baseURL string) *PluginsService {
	return &PluginsService{
		baseURL: baseURL,
		client:  client,
	}
}

// GetPlugins gets the plugins for the specified category.
func (p *PluginsService) GetPlugins(categoryPath string) ([]metadata.Plugin, error) {
	req, err := http.NewRequest("GET", p.baseURL+categoryPath+"/plugins.json", nil)
	if err != nil {
		return nil, err
	}
	ctx, cancel := context.WithTimeout(req.Context(), apiRequestTimeout)
	defer cancel()
	req = req.WithContext(ctx)
	res, err := p.client.Do(req)
	if err != nil {
		return nil, err
	}
	defer res.Body.Close()
	body, err := ioutil.ReadAll(res.Body)
	if err != nil {
		return nil, err
	}
	var payload struct {
		Plugins []metadata.Plugin
	}
	err = json.Unmarshal(body, &payload)
	if err != nil {
		return nil, err
	}
	return payload.Plugins, nil
}

// GetPlugin gets the plugin metadata for a plugin.
func (p *PluginsService) GetPlugin(pluginPath string) (*metadata.Plugin, error) {
	req, err := http.NewRequest("GET", p.baseURL+pluginPath+".json", nil)
	if err != nil {
		return nil, err
	}
	ctx, cancel := context.WithTimeout(req.Context(), apiRequestTimeout)
	defer cancel()
	req = req.WithContext(ctx)
	res, err := p.client.Do(req)
	if err != nil {
		return nil, err
	}
	defer res.Body.Close()
	body, err := ioutil.ReadAll(res.Body)
	if err != nil {
		return nil, err
	}
	var payload struct {
		Plugin *metadata.Plugin
	}
	err = json.Unmarshal(body, &payload)
	if err != nil {
		return nil, err
	}
	return payload.Plugin, nil
}

// GetFeaturedPlugins gets the featured plugins.
func (p *PluginsService) GetFeaturedPlugins() ([]metadata.Plugin, error) {
	req, err := http.NewRequest("GET", p.baseURL+"featured-plugins.json", nil)
	if err != nil {
		return nil, err
	}
	ctx, cancel := context.WithTimeout(req.Context(), apiRequestTimeout)
	defer cancel()
	req = req.WithContext(ctx)
	res, err := p.client.Do(req)
	if err != nil {
		return nil, err
	}
	defer res.Body.Close()
	body, err := ioutil.ReadAll(res.Body)
	if err != nil {
		return nil, err
	}
	var payload struct {
		Plugins []metadata.Plugin
	}
	err = json.Unmarshal(body, &payload)
	if err != nil {
		return nil, err
	}
	return payload.Plugins, nil
}

// GetInstalledPlugins gets the installed plugins.
func (p *PluginsService) GetInstalledPlugins() ([]plugins.InstalledPlugin, error) {
	p.osLock.Lock()
	defer p.osLock.Unlock()
	return plugins.GetInstalledPlugins(pluginDirectory)
}

// InstallPlugin installs the plugin described by the provided metadata.
func (p *PluginsService) InstallPlugin(plugin metadata.Plugin) (string, error) {
	defer p.OnRefresh()
	p.osLock.Lock()
	defer p.osLock.Unlock()
	if p.runtime != nil {
		switch p.runtime.Dialog.Message(&dialog.MessageDialog{
			Type:          "Question",
			Title:         "Install plugin",
			Message:       fmt.Sprintf("Are you sure you want to install %s?", plugin.Title),
			Buttons:       []string{"Install", "Cancel"},
			DefaultButton: "Install",
			CancelButton:  "Cancel",
		}) {
		case "Install":
			// continue
		case "Cancel":
			return "", nil
		}
	}
	installer := &plugins.Installer{
		Client: &http.Client{
			Timeout: 1 * time.Minute,
		},
		PluginDir: pluginDirectory,
	}
	pluginPath := "https://xbarapp.com/docs/plugins/" + plugin.Path + ".json"
	pluginPathURL, err := url.Parse(pluginPath)
	if err != nil {
		return "", errors.Wrapf(err, "parse URL: %s", pluginPath)
	}
	installedPluginPath, err := installer.Install(pluginPathURL)
	if err != nil {
		return "", errors.Wrap(err, "Install")
	}
	tickOS() // wait a beat
	return installedPluginPath, nil
}

// UninstallPluginRequest is the object to send when uninstalling an
// installed plugin.
type UninstallPluginRequest struct {
	Path  string
	Title string
}

// UninstallPlugin removes a plugin.
func (p *PluginsService) UninstallPlugin(installedPluginInfo UninstallPluginRequest) (bool, error) {
	defer p.OnRefresh()
	p.osLock.Lock()
	defer p.osLock.Unlock()
	if p.runtime != nil {
		switch p.runtime.Dialog.Message(&dialog.MessageDialog{
			Type:          "Question",
			Title:         "Uninstall plugin",
			Message:       fmt.Sprintf("Are you sure you want to remove %s?\n\nThis cannot be undone.", installedPluginInfo.Title),
			Buttons:       []string{"Uninstall", "Cancel"},
			DefaultButton: "Uninstall",
			CancelButton:  "Cancel",
		}) {
		case "Uninstall":
			// continue
		case "Cancel":
			return false, nil
		}
	}
	installer := &plugins.Installer{
		PluginDir: pluginDirectory,
	}
	err := installer.Uninstall(installedPluginInfo.Path)
	if err != nil {
		return false, errors.Wrap(err, "uninstall")
	}
	tickOS() // wait a beat
	return true, nil
}

// InstalledPluginMetadata is the metadata extracted from an installed
// plugin.
type InstalledPluginMetadata struct {
	Plugin          metadata.Plugin         `json:"plugin"`
	Enabled         bool                    `json:"enabled"`
	RefreshInterval plugins.RefreshInterval `json:"refreshInterval"`
	Error           string                  `json:"error,omitempty"`
}

// GetInstalledPluginMetadata loads the plugin metadata from a plugin file.
func (p *PluginsService) GetInstalledPluginMetadata(installedPluginPath string) (*InstalledPluginMetadata, error) {
	p.osLock.Lock()
	defer p.osLock.Unlock()
	filename := filepath.Base(installedPluginPath)
	b, err := os.ReadFile(filepath.Join(pluginDirectory, installedPluginPath))
	if err != nil {
		return nil, err
	}
	md, err := metadata.Parse(metadata.DebugfNoop, filename, string(b))
	if err != nil {
		return nil, err
	}
	md.Path = installedPluginPath
	response := &InstalledPluginMetadata{
		Plugin:  md,
		Enabled: plugins.IsPluginEnabled(installedPluginPath),
	}
	response.RefreshInterval, err = plugins.ParseFilenameInterval(filename)
	if err != nil {
		response.Error = err.Error()
	}
	return response, nil
}

// LoadVariableValues loads the values for an installed plugin.
func (p *PluginsService) LoadVariableValues(installedPluginPath string) (map[string]interface{}, error) {
	p.osLock.Lock()
	defer p.osLock.Unlock()
	defer tickOS() // wait a beat
	return plugins.LoadVariableValues(pluginDirectory, installedPluginPath)
}

// SaveVariableValues saves the values for an installed plugin.
func (p *PluginsService) SaveVariableValues(installedPluginPath string, values map[string]interface{}) error {
	p.osLock.Lock()
	defer p.osLock.Unlock()
	defer tickOS() // wait a beat
	return plugins.SaveVariableValues(pluginDirectory, installedPluginPath, values)
}

// SetEnabled sets a plugin to enabled or disabled state, depending on the value of
// the enabled parameter.
func (p *PluginsService) SetEnabled(installedPluginPath string, enabled bool) (string, error) {
	defer p.OnRefresh()
	p.osLock.Lock()
	defer p.osLock.Unlock()
	newPath, err := plugins.SetEnabled(pluginDirectory, installedPluginPath, enabled)
	if err != nil {
		return "", err
	}
	tickOS() // wait a beat
	return newPath, err
}

// SetRefreshIntervalResult is the refresh interval result returned from SetRefreshInterval.
type SetRefreshIntervalResult struct {
	InstalledPluginPath string                  `json:"installedPluginPath"`
	RefreshInterval     plugins.RefreshInterval `json:"refreshInterval"`
}

// SetRefreshInterval updates the refresh interval for a plugin.
func (p *PluginsService) SetRefreshInterval(installedPluginPath string, refreshInterval plugins.RefreshInterval) (*SetRefreshIntervalResult, error) {
	defer p.OnRefresh()
	p.osLock.Lock()
	defer p.osLock.Unlock()
	newPath, newInterval, err := plugins.SetRefreshInterval(pluginDirectory, installedPluginPath, refreshInterval)
	if err != nil {
		return nil, err
	}
	result := &SetRefreshIntervalResult{
		InstalledPluginPath: newPath,
		RefreshInterval:     newInterval,
	}
	tickOS() // wait a beat
	return result, nil
}
