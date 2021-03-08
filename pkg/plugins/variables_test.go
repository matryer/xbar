package plugins

import (
	"io/ioutil"
	"os"
	"testing"

	"github.com/matryer/is"
)

func TestVariablesPersistence(t *testing.T) {
	is := is.New(t)

	installedPluginPath := "test-plugin.sh"
	pluginDir, err := ioutil.TempDir("", "xbar-variables-test")
	is.NoErr(err)
	t.Cleanup(func() {
		os.RemoveAll(pluginDir)
	})

	loadedValues, err := LoadVariableValues(pluginDir, installedPluginPath)
	is.NoErr(err)
	is.True(loadedValues != nil)
	is.Equal(len(loadedValues), 0) // should be empty

	values := map[string]interface{}{
		"VAR_NAME":    "Mat",
		"VAR_CITY":    "London",
		"VAR_COUNTRY": "UK",
	}
	err = SaveVariableValues(pluginDir, installedPluginPath, values)
	is.NoErr(err)

	loadedValues, err = LoadVariableValues(pluginDir, installedPluginPath)
	is.NoErr(err)
	is.Equal(loadedValues["VAR_NAME"], "Mat")
	is.Equal(loadedValues["VAR_CITY"], "London")
	is.Equal(loadedValues["VAR_COUNTRY"], "UK")
}
