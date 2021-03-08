package plugins

import (
	"encoding/json"
	"io"
	"io/ioutil"
	"os"
	"path/filepath"

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
