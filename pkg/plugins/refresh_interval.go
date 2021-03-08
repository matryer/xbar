package plugins

import (
	"fmt"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"time"

	"github.com/pkg/errors"
)

// defaultRefreshInterval is the interval at which plugins will refresh
// if no value is specified in the plugin's filename.
var defaultRefreshInterval = RefreshInterval{
	N:    1,
	Unit: "minutes",
}

// RefreshInterval indicates how often a plugin runs and refreshes its output.
// This type is exposed to ease interaction between the UI and the backend.
type RefreshInterval struct {
	N    int64  `json:"n"`
	Unit string `json:"unit"`
}

// Duration gets the time.Duration for this RefreshInterval.
func (r RefreshInterval) Duration() time.Duration {
	switch r.Unit {
	case "ms":
		// special case for testing
		return time.Duration(r.N) * time.Millisecond
	case "days":
		return time.Hour * time.Duration(24*r.N)
	case "hours":
		return time.Duration(r.N) * time.Hour
	case "minutes":
		return time.Duration(r.N) * time.Minute
	case "seconds":
		return time.Duration(r.N) * time.Second
	default:
		// default
		return 1 * time.Minute
	}
}

// String returns the RefreshInterval as a string that can be used as an xbar
// interval, as represented in plugin filenames.
func (r RefreshInterval) String() string {
	switch r.Unit {
	case "days":
		return fmt.Sprintf("%dd", r.N)
	case "hours":
		return fmt.Sprintf("%dh", r.N)
	case "minutes":
		return fmt.Sprintf("%dm", r.N)
	case "seconds":
		return fmt.Sprintf("%ds", r.N)
	default:
		return "<invalid>"
	}
}

// SetRefreshInterval sets the time interval at which a plugin should be re-run.
func SetRefreshInterval(pluginDirectory, installedPluginPath string, refreshInterval RefreshInterval) (string, RefreshInterval, error) {
	interval := findIntervalInFilename(installedPluginPath)
	if err := validateRefreshInterval(refreshInterval); err != nil {
		return "", RefreshInterval{}, errors.Wrap(err, "invalid refresh interval")
	}
	oldFullPath := filepath.Join(pluginDirectory, installedPluginPath)
	newFilename := strings.Replace(installedPluginPath, "."+interval+".", "."+refreshInterval.String()+".", 1)
	newFullPath := filepath.Join(pluginDirectory, newFilename)
	if err := os.Rename(oldFullPath, newFullPath); err != nil {
		return "", RefreshInterval{}, errors.Wrap(err, "rename plugin file to new refresh interval")
	}
	_, err := os.Stat(newFullPath)
	if err != nil {
		return "", RefreshInterval{}, errors.Wrap(err, "stat plugin file")
	}
	oldVarFullPath := oldFullPath + variableJSONFileExt
	_, err = os.Stat(oldVarFullPath)
	if err != nil && !os.IsNotExist(err) {
		return "", RefreshInterval{}, errors.Wrap(err, "stat plugin vars file")
	}
	if err != nil && os.IsNotExist(err) {
		// no variable file, no probs
		return newFilename, refreshInterval, nil
	}
	newVarFilename := newFilename + variableJSONFileExt
	newVarFullPath := filepath.Join(pluginDirectory, newVarFilename)
	if err := os.Rename(oldVarFullPath, newVarFullPath); err != nil {
		return "", RefreshInterval{}, errors.Wrap(err, "rename plugin vars file to new refresh interval")
	}
	return newFilename, refreshInterval, nil
}

func validateRefreshInterval(refreshInterval RefreshInterval) error {
	if n := refreshInterval.N; n < 1 {
		return errors.Errorf("bad interval value: %d", n)
	}
	for _, unit := range []string{"days", "hours", "minutes", "seconds"} {
		if refreshInterval.Unit == unit {
			return nil
		}
	}
	return errors.Errorf("bad interval unit: %s", refreshInterval.Unit)
}

// ParseFilenameInterval parses the filename to extract the refresh interval
// or returns a default if it is do so.
func ParseFilenameInterval(filename string) (RefreshInterval, error) {
	// ignore disabled piece
	filename = strings.TrimSuffix(filename, disabledPluginExtension)
	intervalStr := findIntervalInFilename(filename)
	if intervalStr == "" {
		return defaultRefreshInterval, nil
	}
	interval, err := parseInterval(intervalStr)
	if err != nil {
		return defaultRefreshInterval, errors.Errorf("%s (from %s)", err.Error(), filename)
	}
	return interval, nil
}

func findIntervalInFilename(filename string) string {
	if filename == "" {
		return ""
	}
	if !IsPluginEnabled(filename) {
		filename = strings.TrimSuffix(filename, disabledPluginExtension)
	}
	fn := filename
	ext := filepath.Ext(filename)
	if ext != "" {
		fn = fn[:len(fn)-len(ext)]
	}
	segs := strings.Split(fn, ".")
	if len(segs) == 1 {
		return ""
	}
	interval := segs[len(segs)-1]
	return interval
}

func parseInterval(interval string) (RefreshInterval, error) {
	unit := interval[len(interval)-1]
	valStr := interval[:len(interval)-1]
	val, err := strconv.ParseInt(valStr, 10, 64)
	if err != nil {
		return defaultRefreshInterval, errors.Errorf("bad interval value: %s", valStr)
	}
	switch unit {
	case 'd': // turn days into hours
		return RefreshInterval{N: val, Unit: "days"}, nil
	case 'h':
		return RefreshInterval{N: val, Unit: "hours"}, nil
	case 'm':
		return RefreshInterval{N: val, Unit: "minutes"}, nil
	case 's':
		return RefreshInterval{N: val, Unit: "seconds"}, nil
	default:
		return defaultRefreshInterval, errors.Errorf("bad interval unit: %s", string(unit))
	}
}
