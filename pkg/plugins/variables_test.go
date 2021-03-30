package plugins

import (
	"context"
	"io/ioutil"
	"os"
	"path/filepath"
	"testing"
	"time"

	"github.com/matryer/is"
)

func TestEnvironmentVariables(t *testing.T) {
	is := is.New(t)

	err := os.Setenv("XBAR_TEST_EXPLICIT_VAR", "explicit")
	is.NoErr(err)
	t.Cleanup(func() {
		err := os.Unsetenv("XBAR_TEST_EXPLICIT_VAR")
		is.NoErr(err)
	})

	ctx := context.Background()
	ctx, cancel := context.WithTimeout(ctx, 1*time.Second)
	defer cancel()

	p := &Plugin{
		Command:         filepath.Join("testdata", "vars-test", "plugin.sh"),
		Debugf:          DebugfNoop,
		Timeout:         1 * time.Second,
		RefreshInterval: RefreshInterval{N: 250, Unit: "milliseconds"},
		CycleInterval:   500 * time.Millisecond,
	}
	p.Run(ctx)

	is.Equal(len(p.Items.CycleItems), 3)
	is.Equal(p.Items.CycleItems[0].Text, `XBAR_TEST_EXPLICIT_VAR=explicit`)     // inherited
	is.Equal(p.Items.CycleItems[1].Text, `XBAR_TEST_SET_IN_VARS_JSON=json`)     // in vars.json file
	is.Equal(p.Items.CycleItems[2].Text, `XBAR_TEST_DEFAULT_VAR=default-value`) // from plugin metadata

}

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
