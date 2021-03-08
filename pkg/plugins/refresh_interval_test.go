package plugins

import (
	"os"
	"path/filepath"
	"testing"
	"time"

	"github.com/matryer/is"
	"github.com/pkg/errors"
)

func TestSetRefreshInterval(t *testing.T) {
	is := is.New(t)
	baseTestPath := filepath.Join("testdata", "set-refresh-interval-test")
	t.Run("single-file plugin", func(t *testing.T) {
		var (
			testpath      = filepath.Join(baseTestPath, "single-file-plugin")
			oldPluginName = "set-refresh-interval.1m.sh"
			oldPluginPath = filepath.Join(testpath, oldPluginName)
			newPluginName = "set-refresh-interval.1d.sh"
			newPluginPath = filepath.Join(testpath, newPluginName)
		)
		err := os.MkdirAll(testpath, 0777)
		is.NoErr(err)
		t.Cleanup(func() {
			os.RemoveAll(testpath)
		})
		_, err = os.Create(oldPluginPath)
		is.NoErr(err)
		renamedPlugin, refreshInterval, err := SetRefreshInterval(testpath, oldPluginName, RefreshInterval{N: 1, Unit: "days"})
		is.NoErr(err)
		is.Equal(renamedPlugin, newPluginName)
		is.Equal(refreshInterval, RefreshInterval{N: 1, Unit: "days"})
		_, err = os.Stat(newPluginPath)
		is.NoErr(err)
	})
	t.Run("update vars json file too", func(t *testing.T) {
		var (
			testpath          = filepath.Join(baseTestPath, "single-file-plugin")
			oldPluginName     = "set-refresh-interval.1m.sh"
			oldPluginPath     = filepath.Join(testpath, oldPluginName)
			oldPluginVarsName = "set-refresh-interval.1m.sh" + variableJSONFileExt
			oldPluginVarsPath = filepath.Join(testpath, oldPluginVarsName)
			newPluginName     = "set-refresh-interval.1d.sh"
			newPluginPath     = filepath.Join(testpath, newPluginName)
			newPluginVarsName = "set-refresh-interval.1d.sh" + variableJSONFileExt
			newPluginVarsPath = filepath.Join(testpath, newPluginVarsName)
		)
		err := os.MkdirAll(testpath, 0777)
		is.NoErr(err)
		t.Cleanup(func() {
			os.RemoveAll(testpath)
		})
		_, err = os.Create(oldPluginPath)
		is.NoErr(err)
		_, err = os.Create(oldPluginVarsPath)
		is.NoErr(err)
		renamedPlugin, refreshInterval, err := SetRefreshInterval(testpath, oldPluginName, RefreshInterval{N: 1, Unit: "days"})
		is.NoErr(err)
		is.Equal(renamedPlugin, newPluginName)
		is.Equal(refreshInterval, RefreshInterval{N: 1, Unit: "days"})
		_, err = os.Stat(newPluginPath)
		is.NoErr(err)
		_, err = os.Stat(newPluginVarsPath)
		is.NoErr(err)
	})
	t.Run("disabled plugin", func(t *testing.T) {
		var (
			testpath      = filepath.Join(baseTestPath, "single-file-plugin")
			oldPluginName = "set-refresh-interval.1m.sh" + disabledPluginExtension
			oldPluginPath = filepath.Join(testpath, oldPluginName)
			newPluginName = "set-refresh-interval.1d.sh" + disabledPluginExtension
			newPluginPath = filepath.Join(testpath, newPluginName)
		)
		err := os.MkdirAll(testpath, 0777)
		is.NoErr(err)
		t.Cleanup(func() {
			os.RemoveAll(testpath)
		})
		_, err = os.Create(oldPluginPath)
		is.NoErr(err)
		renamedPlugin, refreshInterval, err := SetRefreshInterval(testpath, oldPluginName, RefreshInterval{N: 1, Unit: "days"})
		is.NoErr(err)
		is.Equal(renamedPlugin, newPluginName)
		is.Equal(refreshInterval, RefreshInterval{N: 1, Unit: "days"})
		_, err = os.Stat(newPluginPath)
		is.NoErr(err)
	})

	t.Run("plugin file does not exist", func(t *testing.T) {
		var (
			testpath      = filepath.Join(baseTestPath, "plugin-does-not-exist")
			oldPluginName = "set-refresh-interval.1m.sh"
		)
		err := os.MkdirAll(testpath, 0777)
		is.NoErr(err)
		t.Cleanup(func() {
			os.RemoveAll(testpath)
		})
		// Do not create plugin file here.
		_, _, err = SetRefreshInterval(testpath, oldPluginName, RefreshInterval{N: 1, Unit: "hours"})
		is.True(err != nil)
	})
	t.Run("bad refresh interval", func(t *testing.T) {
		var (
			testpath      = filepath.Join(baseTestPath, "bad-refresh-interval")
			oldPluginName = "set-refresh-interval.1m.sh"
			pluginFile    = filepath.Join(testpath, oldPluginName)
		)
		err := os.MkdirAll(testpath, 0777)
		is.NoErr(err)
		t.Cleanup(func() {
			os.RemoveAll(testpath)
		})
		_, err = os.Create(pluginFile)
		is.NoErr(err)
		renamedPlugin, refreshInterval, err := SetRefreshInterval(testpath, oldPluginName, RefreshInterval{})
		is.Equal(renamedPlugin, "")
		is.Equal(refreshInterval, RefreshInterval{})
		is.Equal(err.Error(), errors.Errorf("invalid refresh interval: bad interval value: 0").Error())
	})
}

func TestParseFilenameInterval(t *testing.T) {
	is := is.New(t)

	for filename, expected := range map[string]time.Duration{
		"":                    1 * time.Minute, // default
		"/path/to/file.sh":    1 * time.Minute, // default
		"/path/to/file.1s.sh": 1 * time.Second,
		"/path/to/file.2m.sh": 2 * time.Minute,
		"/path/to/file.3h.sh": 3 * time.Hour,
		"/path/to/file.1d.sh": 24 * time.Hour,
		"/path/to/file.2d.sh": 48 * time.Hour,

		"/path/to/file.5s.sh.off": 5 * time.Second,
	} {
		t.Run(filename, func(t *testing.T) {
			actual, err := ParseFilenameInterval(filename)
			is.NoErr(err)
			is.Equal(expected, actual.Duration())
		})
	}

	_, err := ParseFilenameInterval("bad.VALd.sh")
	is.True(err != nil)
	is.Equal(err.Error(), "bad interval value: VAL (from bad.VALd.sh)")

	_, err = ParseFilenameInterval("bad.10p.sh")
	is.True(err != nil)
	is.Equal(err.Error(), "bad interval unit: p (from bad.10p.sh)")

}

func TestValidateRefreshInterval(t *testing.T) {
	is := is.New(t)

	// Valid refresh intervals.
	for _, ri := range []RefreshInterval{
		{N: 1, Unit: "hours"},
		{N: 42, Unit: "days"},
		{N: 22, Unit: "minutes"},
		{N: 3, Unit: "seconds"},
	} {
		err := validateRefreshInterval(ri)
		is.NoErr(err)
	}

	// Invalid refresh intervals.
	for ri, expectedErr := range map[RefreshInterval]error{
		{N: -10, Unit: "days"}: errors.New("bad interval value: -10"), // negative value
		{N: 0, Unit: "hours"}:  errors.New("bad interval value: 0"),   // zero value
		{N: 1, Unit: "q"}:      errors.New("bad interval unit: q"),    // invalid unit
		{N: 1, Unit: ""}:       errors.New("bad interval unit: "),     // empty unit
	} {
		err := validateRefreshInterval(ri)
		is.Equal(err.Error(), expectedErr.Error())
	}
}

func TestRefreshIntervalString(t *testing.T) {
	is := is.New(t)
	for ri, expected := range map[RefreshInterval]string{
		{N: 14, Unit: "days"}:    "14d",
		{N: 22, Unit: "hours"}:   "22h",
		{N: 10, Unit: "minutes"}: "10m",
		{N: 3, Unit: "seconds"}:  "3s",
		{}:                       "<invalid>",
	} {
		is.Equal(ri.String(), expected)
	}
}
