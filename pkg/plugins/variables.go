package plugins

import (
	"encoding/json"
	"fmt"
	"io"
	"io/ioutil"
	"os"
	"path/filepath"
	"sync"

	"github.com/matryer/xbar/pkg/metadata"
	"github.com/pkg/errors"
)

// variableJSONFileExt is the extension for the variable JSON payload.
const variableJSONFileExt = ".vars.json"

// SaveVariableValues saves the values for a plugin.
func SaveVariableValues(pluginDir, installedPluginPath string, values map[string]interface{}) error {
	b, err := json.MarshalIndent(values, "", "\t")
	if err != nil {
		return errors.Wrap(err, "json.MarshalIndent")
	}
	filename := filepath.Join(pluginDir, installedPluginPath+variableJSONFileExt)
	err = ioutil.WriteFile(filename, b, 0666)
	if err != nil {
		return errors.Wrap(err, "WriteFile")
	}
	return nil
}

// LoadVariableValues loads the variables for a plugin.
func LoadVariableValues(pluginDir, installedPluginPath string) (map[string]interface{}, error) {
	filename := filepath.Join(pluginDir, installedPluginPath+variableJSONFileExt)
	f, err := os.Open(filename)
	if err != nil {
		if os.IsNotExist(err) {
			// no file - but not an error, just empty map
			return map[string]interface{}{}, nil
		}
		return nil, errors.Wrap(err, "Open")
	}
	defer f.Close()
	b, err := io.ReadAll(io.LimitReader(f, 1_000_000 /* ~1MB */))
	if err != nil {
		return nil, errors.Wrap(err, "ReadAll")
	}
	var values map[string]interface{}
	err = json.Unmarshal(b, &values)
	if err != nil {
		return nil, errors.Wrap(err, "json.Unmarshal")
	}
	return values, nil
}

func (p *Plugin) loadVariablesAsEnvVars() ([]string, error) {
	vars, err := p.loadVariables()
	if err != nil {
		return nil, errors.Wrap(err, "loadVariables")
	}
	envvars := make([]string, 0, len(vars))
	for k, v := range vars {
		envvars = append(envvars, fmt.Sprintf("%s=%v", k, v))
	}
	return envvars, nil
}

func (p *Plugin) loadVariables() (map[string]interface{}, error) {
	var wg sync.WaitGroup
	var defaultVars, jsonFileVars map[string]interface{}
	var defaultVarsErr, jsonFileVarsErr error
	wg.Add(1)
	go func() {
		defaultVars, defaultVarsErr = p.loadVariablesFromPluginMetadata()
		wg.Done()
	}()
	wg.Add(1)
	go func() {
		jsonFileVars, jsonFileVarsErr = p.loadVariablesFromJSONFile()
		wg.Done()
	}()
	wg.Wait()
	if defaultVarsErr != nil {
		return nil, errors.Wrap(defaultVarsErr, "load default vars")
	}
	if jsonFileVarsErr != nil {
		return nil, errors.Wrap(jsonFileVarsErr, "load json file vars")
	}
	// add the json file vars to the defaults,
	// and return them.
	for k, v := range jsonFileVars {
		defaultVars[k] = v
	}
	return defaultVars, nil
}

// loadVariablesFromJSONFile gets a list of environment variable friendly
// key=value pairs.
func (p *Plugin) loadVariablesFromJSONFile() (map[string]interface{}, error) {
	variablesJSONFilename := p.Command + variableJSONFileExt
	f, err := os.Open(variablesJSONFilename)
	if err != nil && os.IsNotExist(err) {
		// no .vars.json file - no probs
		return nil, nil
	} else if err != nil {
		return nil, errors.Wrap(err, "open vars json file")
	}
	defer f.Close()
	b, err := io.ReadAll(io.LimitReader(f, 1_000_000))
	if err != nil {
		return nil, err
	}
	var vars map[string]interface{}
	if err := json.Unmarshal(b, &vars); err != nil {
		return nil, errors.Wrap(err, "json.Unmarshal")
	}
	return vars, nil
}

func (p *Plugin) loadVariablesFromPluginMetadata() (map[string]interface{}, error) {
	// read the plugin metadata for default values
	pluginFile, err := os.Open(p.Command)
	if err != nil {
		return nil, errors.Wrap(err, "open plugin source")
	}
	defer pluginFile.Close()
	pluginFileB, err := io.ReadAll(io.LimitReader(pluginFile, 1_000_000))
	if err != nil {
		return nil, errors.Wrap(err, "read plugin source")
	}
	pluginMetadata, err := metadata.Parse(metadata.DebugFunc(p.Debugf), p.CleanFilename(), string(pluginFileB))
	if err != nil {
		return nil, errors.Wrap(err, "metadata.Parse")
	}
	vars := make(map[string]interface{})
	for _, pluginVar := range pluginMetadata.Vars {
		if pluginVar.Default == "" {
			// skip values with no default
			continue
		}
		vars[pluginVar.Name] = pluginVar.DefaultValue()
	}
	return vars, nil
}
