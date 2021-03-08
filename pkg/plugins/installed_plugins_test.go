package plugins

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/matryer/is"
)

func TestGetInstalledPlugins(t *testing.T) {
	is := is.New(t)

	installedPlugins, err := GetInstalledPlugins(filepath.Join("testdata", "plugins"))
	is.NoErr(err)
	is.Equal(len(installedPlugins), 9)

	is.Equal(installedPlugins[0].Name, "expanded.1m.sh")
	is.Equal(installedPlugins[0].Counter, 1)
	is.Equal(installedPlugins[0].Path, "expanded.1m.sh")
	is.Equal(installedPlugins[0].Enabled, true)

	is.Equal(installedPlugins[1].Name, "expanded.1m.sh")
	is.Equal(installedPlugins[1].Counter, 1)
	is.Equal(installedPlugins[1].Path, "expanded.1m.sh.off")
	is.Equal(installedPlugins[1].Enabled, false)

	is.Equal(installedPlugins[2].Name, "expanded.1s.sh")
	is.Equal(installedPlugins[2].Counter, 1)
	is.Equal(installedPlugins[2].Path, "expanded.1s.sh")

	is.Equal(installedPlugins[3].Name, "multiple.1s.sh")     // Name should exclude counter
	is.Equal(installedPlugins[3].Counter, 1)                 // Counter
	is.Equal(installedPlugins[3].Path, "001-multiple.1s.sh") // Path should include counter

	is.Equal(installedPlugins[4].Name, "multiple.1s.sh")     // Name should exclude counter
	is.Equal(installedPlugins[4].Counter, 2)                 // Counter
	is.Equal(installedPlugins[4].Path, "002-multiple.1s.sh") // Path should include counter

}

func TestIsPluginEnabled(t *testing.T) {
	is := is.New(t)

	is.Equal(IsPluginEnabled("nope.sh"+disabledPluginExtension), false)
	is.Equal(IsPluginEnabled("yep.sh"), true)

}

func TestSetEnabled(t *testing.T) {
	const (
		mainTestdir         = "testdata/set_enabled_test"
		installedPluginPath = "set-enabled-plugin.1h.sh"
	)
	t.Cleanup(func() {
		is := is.New(t)
		err := os.RemoveAll(mainTestdir)
		is.NoErr(err)
	})
	scaffold := func(t *testing.T, testcase string) string {
		is := is.New(t)
		testdir := filepath.Join(mainTestdir, testcase)
		err := os.MkdirAll(testdir, 0777)
		is.NoErr(err)
		t.Cleanup(func() {
			err := os.RemoveAll(testdir)
			is.NoErr(err)
		})
		return testdir
	}
	t.Run("enabled to disabled", func(t *testing.T) {
		var (
			is         = is.New(t)
			testdir    = scaffold(t, "enable")
			pluginPath = filepath.Join(testdir, installedPluginPath)
		)
		_, err := os.Create(pluginPath)
		is.NoErr(err)
		newpath, err := SetEnabled(testdir, installedPluginPath, false)
		is.NoErr(err)
		is.Equal(newpath, "set-enabled-plugin.1h.sh.off")
		is.Equal(IsPluginEnabled(newpath), false)
		_, err = os.Stat(pluginPath + disabledPluginExtension)
		is.NoErr(err)
	})
	t.Run("disabled to enabled", func(t *testing.T) {
		var (
			is                     = is.New(t)
			testdir                = scaffold(t, "disable")
			disabledPluginFilename = installedPluginPath + disabledPluginExtension
			pluginPath             = filepath.Join(testdir, installedPluginPath+disabledPluginExtension)
		)
		_, err := os.Create(pluginPath)
		is.NoErr(err)
		newpath, err := SetEnabled(testdir, disabledPluginFilename, false)
		is.NoErr(err)
		is.Equal(newpath, "set-enabled-plugin.1h.sh.off")
		is.Equal(IsPluginEnabled(newpath), false)
		_, err = os.Stat(pluginPath)
		is.NoErr(err)
	})
	t.Run("enable already enabled: no op", func(t *testing.T) {
		var (
			is         = is.New(t)
			testdir    = scaffold(t, "enable-noop")
			pluginPath = filepath.Join(testdir, installedPluginPath)
		)
		_, err := os.Create(pluginPath)
		is.NoErr(err)
		newpath, err := SetEnabled(testdir, installedPluginPath, true)
		is.NoErr(err)
		is.Equal(newpath, "set-enabled-plugin.1h.sh")
		is.Equal(IsPluginEnabled(newpath), true)
		_, err = os.Stat(pluginPath)
		is.NoErr(err)
		_, err = os.Stat(pluginPath + disabledPluginExtension)
		is.True(os.IsNotExist(err))
	})
	t.Run("disable aldready disabled: no op", func(t *testing.T) {
		var (
			is                     = is.New(t)
			testdir                = scaffold(t, "disable-noop")
			pluginPath             = filepath.Join(testdir, installedPluginPath)
			disabledPluginFilename = installedPluginPath + disabledPluginExtension
		)
		_, err := os.Create(filepath.Join(testdir, disabledPluginFilename))
		is.NoErr(err)
		newpath, err := SetEnabled(testdir, disabledPluginFilename, false)
		is.NoErr(err)
		is.Equal(newpath, "set-enabled-plugin.1h.sh.off")
		is.Equal(IsPluginEnabled(newpath), false)
		_, err = os.Stat(filepath.Join(testdir, disabledPluginFilename))
		is.NoErr(err)
		_, err = os.Stat(pluginPath)
		is.True(os.IsNotExist(err))
	})
}
