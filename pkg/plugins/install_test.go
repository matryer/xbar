package plugins

import (
	"net/http"
	"net/http/httptest"
	"net/url"
	"os"
	"path/filepath"
	"testing"

	"github.com/matryer/is"
	"github.com/matryer/xbar/pkg/metadata"
)

func TestInstall(t *testing.T) {
	var (
		apiPath = filepath.Join("testdata", "stub-api")
		srv     = httptest.NewServer(http.FileServer(http.Dir(apiPath)))
	)
	t.Cleanup(srv.Close)
	t.Run("single-file plugin installation", func(t *testing.T) {
		var (
			is        = is.New(t)
			pluginDir = filepath.Join("testdata", "single_file_install_tests")
		)
		t.Cleanup(func() {
			err := os.RemoveAll(pluginDir)
			is.NoErr(err)
		})

		const plugin = "currency-tracker.1h.py"
		installer := Installer{
			Client:    srv.Client(),
			PluginDir: pluginDir,
		}
		pluginMetadataAPIPath, err := url.Parse(srv.URL + "/" + plugin + ".json")
		is.NoErr(err)
		installedPluginPath, err := installer.Install(pluginMetadataAPIPath)
		is.NoErr(err)
		is.Equal(installedPluginPath, "001-currency-tracker.1h.py")

		expected := filepath.Join(pluginDir, "001-"+plugin)
		fi, err := os.Stat(expected)
		is.True(os.IsNotExist(err) == false)
		is.Equal(fi.Mode(), os.FileMode(0755))
	})

	// note: this feature isn't yet implemented

	// t.Run("folder plugin installation", func(t *testing.T) {
	// 	var (
	// 		is        = is.New(t)
	// 		pluginDir = filepath.Join("testdata", "folder_install_tests")
	// 	)
	// 	t.Cleanup(func() {
	// 		err := os.RemoveAll(pluginDir)
	// 		is.NoErr(err)
	// 	})

	// 	const plugin = "folder-based.1h.sh"
	// 	installer := Installer{
	// 		Client:    srv.Client(),
	// 		PluginDir: pluginDir,
	// 	}
	// 	pluginMetadataAPIPath, err := url.Parse(srv.URL + "/" + plugin + ".json")
	// 	is.NoErr(err)
	// 	installedPluginPath, err := installer.Install(pluginMetadataAPIPath)
	// 	is.NoErr(err)
	// 	is.Equal(installedPluginPath, "abc")

	// 	// Ensure that the entry point is set executable and the rest are not.
	// 	// This assumes umask 022 is set, since xbar sets the file mode for the
	// 	// entry point to 0777. The mode for non-entry point files is not
	// 	// explicitly set.
	// 	var (
	// 		installedAt = filepath.Join(pluginDir, "001-"+plugin)
	// 		wantFiles   = map[string]os.FileMode{
	// 			"folder-based.1h.sh": 0755,
	// 			"data-1.txt":         0644,
	// 			"data-2.txt":         0644,
	// 		}
	// 	)
	// 	gotFiles, err := ioutil.ReadDir(installedAt)
	// 	is.NoErr(err)
	// 	for _, file := range gotFiles {
	// 		mode, ok := wantFiles[file.Name()]
	// 		is.True(ok) // Unexpected file in installation directory.
	// 		is.Equal(file.Mode(), mode)
	// 	}
	// })

	t.Run("multiple installations of single plugin", func(t *testing.T) {
		var (
			is        = is.New(t)
			pluginDir = filepath.Join("testdata", "multi_install_tests")
		)
		t.Cleanup(func() {
			err := os.RemoveAll(pluginDir)
			is.NoErr(err)
		})

		const plugin = "currency-tracker.1h.py"

		// Fake an existing installation of the plugin. We need to create the
		// plugin directory ourselves here in order to fake the
		// already-installed plugin, even though Installer#Install would do this
		// for us normally. Directory creation is tested in the other test cases
		// here, so it's fine to bypass it here.
		err := os.MkdirAll(pluginDir, 0777)
		is.NoErr(err)
		_, err = os.Create(filepath.Join(pluginDir, "001-"+plugin))
		is.NoErr(err)

		installer := Installer{
			Client:    srv.Client(),
			PluginDir: pluginDir,
		}
		pluginMetadataAPIPath, err := url.Parse(srv.URL + "/" + plugin + ".json")
		is.NoErr(err)
		installedPluginPath, err := installer.Install(pluginMetadataAPIPath)
		is.NoErr(err)
		is.Equal(installedPluginPath, "002-currency-tracker.1h.py")

		expected := filepath.Join(pluginDir, "002-"+plugin)
		fi, err := os.Stat(expected)
		is.True(os.IsNotExist(err) == false)
		is.Equal(fi.Mode(), os.FileMode(0755))
	})
}

func TestGetInstalledPluginName(t *testing.T) {
	const installDir = "testdata/plugins"
	t.Run("not already installed", func(t *testing.T) {
		is := is.New(t)
		installer := Installer{PluginDir: "testdata/plugins"}
		plugin := metadata.Plugin{
			Filename: "does-not-exist.1s.sh",
		}
		name, err := installer.getInstalledPluginName(plugin)
		is.NoErr(err)
		is.Equal(name, filepath.Join(installDir, "001-does-not-exist.1s.sh"))
	})
	t.Run("already installed", func(t *testing.T) {
		is := is.New(t)
		installer := Installer{PluginDir: "testdata/plugins"}
		plugin := metadata.Plugin{
			Filename: "multiple.1s.sh",
		}
		name, err := installer.getInstalledPluginName(plugin)
		is.NoErr(err)
		is.Equal(name, filepath.Join(installDir, "003-multiple.1s.sh"))
	})
}

// func TestRewritePluginFileDest(t *testing.T) {
// 	t.Run("single file plugin", func(t *testing.T) {
// 		is := is.New(t)
// 		originalFile := metadata.File{Path: "Category/plugin-name.1s.py"}
// 		const want = "001-plugin-name.1s.py"
// 		got, err := rewritePluginFileDest(want, originalFile)
// 		is.NoErr(err)
// 		is.Equal(got, want)
// 	})
// 	t.Run("folder-based plugin", func(t *testing.T) {
// 		is := is.New(t)
// 		originalFile := metadata.File{Path: "Category/plugin-name.1s.py/plugin-name.1s.py"}
// 		const installDir = "001-plugin-name.1s.py"
// 		got, err := rewritePluginFileDest(installDir, originalFile)
// 		is.NoErr(err)
// 		is.Equal(got, filepath.Join(installDir, "plugin-name.1s.py"))
// 	})
// 	t.Run("invalid plugin filename", func(t *testing.T) {
// 		is := is.New(t)
// 		originalFile := metadata.File{Path: "Category/"}
// 		_, err := rewritePluginFileDest("does-not-matter-here", originalFile)
// 		is.True(err != nil)
// 	})
// }

const simplePlugin = `#!/bin/bash
echo "Hello, xbar."
`
