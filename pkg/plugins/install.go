package plugins

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"net/url"
	"os"
	"path"
	"path/filepath"
	"strings"

	"github.com/matryer/xbar/pkg/metadata"
	"github.com/pkg/errors"
)

// example: https://xbarapp.com/docs/plugins/Finance/currency-tracker.1h.py.json

// Installer installs plugins from the xbar plugin API to the user's local xbar
// installation.
type Installer struct {
	Client    *http.Client
	PluginDir string
}

// Uninstall removes an installed plugin.
func (i Installer) Uninstall(installedPluginPath string) error {
	err := os.RemoveAll(filepath.Join(i.PluginDir, installedPluginPath))
	if err != nil {
		return err
	}
	return nil
}

// Install installs the plugin whose metadata and content is located at
// pluginPath.
func (i Installer) Install(pluginPath *url.URL) (string, error) {
	err := os.MkdirAll(i.PluginDir, 0777)
	if err != nil {
		return "", errors.Wrap(err, "make plugin directory")
	}
	plugin, err := i.fetchPlugin(pluginPath)
	if err != nil {
		return "", errors.Wrapf(err, "fetchPlugin: %s", pluginPath)
	}
	dest, err := i.getInstalledPluginName(plugin)
	if err != nil {
		return "", errors.Wrap(err, "getInstalledPluginName")
	}
	if err := i.writePluginFiles(dest, plugin); err != nil {
		return "", errors.Wrap(err, "writePluginFiles")
	}
	installedPluginPath, err := filepath.Rel(i.PluginDir, dest)
	if err != nil {
		return "", errors.Wrap(err, "filepath.Rel")
	}
	return installedPluginPath, nil
}

// fetchPlugin fetches the plugin metadata and file contents from the xbar website.
func (i Installer) fetchPlugin(pluginPath *url.URL) (metadata.Plugin, error) {
	resp, err := i.Client.Get(pluginPath.String())
	if err != nil {
		return metadata.Plugin{}, err
	}
	if resp.StatusCode != http.StatusOK {
		return metadata.Plugin{}, errors.Errorf("error fetching plugin %s: %s", pluginPath, resp.Status)
	}
	defer resp.Body.Close()
	var responseBody struct {
		Plugin metadata.Plugin `json:"plugin"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&responseBody); err != nil {
		return metadata.Plugin{}, errors.Wrapf(err, "error decoding plugin %s", pluginPath)
	}
	return responseBody.Plugin, nil
}

// getInstalledPluginName builds a name for the file or folder that will be
// created in the plugin installation directory. Since a plugin can be installed
// multiple times, each installed plugin will be given a sequence number to
// ensure unique naming in the filesystem.
func (i Installer) getInstalledPluginName(plugin metadata.Plugin) (string, error) {
	var (
		count         int
		candidatePath string
		err           error
	)
	for err == nil {
		count++
		candidateBaseName := fmt.Sprintf("%03d-%s", count, plugin.Filename)
		candidatePath = filepath.Join(i.PluginDir, candidateBaseName)
		_, err = os.Stat(candidatePath)
	}
	if !os.IsNotExist(err) {
		return "", err
	}
	return candidatePath, nil
}

// writePluginFiles iterates through the files defined for the plugin, and
// writes them to the plugin installation directory, and sets the entry point
// to be executable.
func (i Installer) writePluginFiles(dstPath string, plugin metadata.Plugin) error {
	if len(plugin.Files) == 0 {
		return errors.New("no plugin files")
	}
	if len(plugin.Files) > 1 {
		return errors.Errorf("only one plugin file supported: found %d.", len(plugin.Files))
	}
	for _, f := range plugin.Files {
		pluginFile := dstPath
		dir := path.Dir(pluginFile)
		if err := os.MkdirAll(dir, 0777); err != nil {
			return errors.Wrapf(err, "create directory %s for plugin", dir)
		}
		writer, err := os.Create(pluginFile)
		if err != nil {
			return errors.Wrapf(err, "create plugin file %s", f.Path)
		}
		reader := strings.NewReader(f.Content)
		if _, err := io.Copy(writer, reader); err != nil {
			return errors.Wrapf(err, "write plugin file %s", f.Path)
		}
		// If the Filename property of the current file matches the Filename
		// property of the plugin, this is the entry point, so set it to be
		// executable.
		if f.Filename != plugin.Filename {
			continue
		}
		if err := os.Chmod(pluginFile, 0755); err != nil {
			return errors.Wrap(err, "set executable permission on plugin entry point")
		}
		// write the default variables
		plugin, err := metadata.Parse(metadata.DebugfNoop, pluginFile, f.Content)
		if err != nil {
			log.Println("install plugin: unable to parse metadata:", err)
		}
		if len(plugin.Vars) > 0 {
			defaultVars := make(map[string]interface{})
			for _, pluginVar := range plugin.Vars {
				defaultVars[pluginVar.Name] = pluginVar.DefaultValue()
			}
			err := SaveVariableValues(i.PluginDir, pluginFile, defaultVars)
			if err != nil {
				return errors.Wrap(err, "write default variables")
			}
		}
	}
	return nil
}
