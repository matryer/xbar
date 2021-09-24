package update

import (
	"encoding/json"
	"io"
	"log"
	"net/http"
	"os"
	"os/exec"
	"path"
	"path/filepath"
	"strings"
	"time"

	semver "github.com/Masterminds/semver/v3"
	"github.com/mholt/archiver"
	"github.com/pkg/errors"
)

// Updater updates an app.
type Updater struct {
	// CurrentVersion is the current install version.
	CurrentVersion string
	// LatestReleaseGitHubEndpoint is the URL of the API to get latest release data.
	// For example, https://api.github.com/repos/matryer/xbar/releases/latest.
	LatestReleaseGitHubEndpoint string
	// Client is the HTTP client to use to access the
	// API and download the assets.
	Client *http.Client
	// SelectAsset selects the Asset to install.
	SelectAsset SelectAssetFunc
	// DownloadBytesLimit is the maximum number of bytes to download.
	DownloadBytesLimit int64
	// GetExecutable is the function that gets the current
	// executable. If nil, os.Executable will be used.
	GetExecutable func() (string, error)
}

// SelectAssetFunc selects the Asset to install.
type SelectAssetFunc func(release Release, asset Asset) bool

// Update checks and installs the update.
// Returns nil, nil if no update is required.
func (u *Updater) Update() (*Release, error) {
	if u.DownloadBytesLimit == 0 {
		return nil, errors.New("must set DownloadBytesLimit")
	}
	if u.SelectAsset == nil {
		return nil, errors.New("missing SelectAsset func")
	}
	if u.GetExecutable == nil {
		u.GetExecutable = os.Executable
	}
	latest, err := u.getLatestRelease()
	if err != nil {
		return nil, err
	}
	hasUpdate := hasUpdate(u.CurrentVersion, latest.TagName)
	if !hasUpdate {
		return nil, nil
	}
	var selectedAsset *Asset
	for _, asset := range latest.Assets {
		if u.SelectAsset(*latest, asset) {
			selectedAsset = &asset
			break
		}
	}
	if selectedAsset == nil {
		return nil, errors.New("no asset selected, use SelectAssetFunc to select an asset")
	}
	err = u.downloadAndReplaceApp(*selectedAsset)
	if err != nil {
		return nil, errors.Wrap(err, "download update")
	}
	return latest, nil
}

// Restart spawns the current executable again, and terminates
// the running one.
func (u *Updater) Restart() error {
	time.Sleep(1 * time.Second)
	thisExecuable, err := os.Executable()
	if err != nil {
		return errors.Wrap(err, "get executable")
	}
	log.Println("restarting", thisExecuable)
	cmd := exec.Command(thisExecuable)
	Setpgid(cmd)
	cmd.Dir = filepath.Dir(thisExecuable)
	cmd.Env = os.Environ()
	cmd.Env = append(cmd.Env, "XBAR_UPDATE_RESTART_COUNTER=1")
	cmd.Args = os.Args
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	err = cmd.Start()
	if err != nil {
		if exitErr, ok := err.(*exec.ExitError); ok {
			return errors.Wrapf(err, "starting new app failed: exit code %d", exitErr.ExitCode())
		}
		return errors.Wrap(err, "starting new app failed")
	}
	log.Println("waiting before terminating after update...")
	time.Sleep(1 * time.Second)
	log.Println("terminating after update.")
	os.Exit(0)
	return nil
}

// getLatestRelease gets the latest release.
func (u *Updater) getLatestRelease() (*Release, error) {
	resp, err := u.Client.Get(u.LatestReleaseGitHubEndpoint)
	if err != nil {
		return nil, errors.Wrap(err, "get latest release")
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return nil, errors.Errorf("failed to check for updates: got %s", resp.Status)
	}
	b, err := io.ReadAll(io.LimitReader(resp.Body, u.DownloadBytesLimit))
	if err != nil {
		return nil, errors.Wrap(err, "read body")
	}
	var latestRelease Release
	err = json.Unmarshal(b, &latestRelease)
	if err != nil {
		return nil, errors.Wrap(err, "marshal")
	}
	latestRelease.CreatedAt, err = time.Parse(time.RFC3339Nano, latestRelease.CreatedAtString)
	if err != nil {
		return nil, errors.Wrap(err, "time.Parse: created_at")
	}
	return &latestRelease, nil
}

// HasUpdate checks whether there's an update or not.
func (u *Updater) HasUpdate() (*Release, bool, error) {
	latest, err := u.getLatestRelease()
	if err != nil {
		return nil, false, err
	}
	hasUpdate := hasUpdate(u.CurrentVersion, latest.TagName)
	return latest, hasUpdate, nil
}

// hasUpdate compares the current and latest version strings to
// see if there is an update.
// Returns false if the versions match.
// Returns false is current is in front of latest.
// If semver checking fails, direct string comparison is used.
func hasUpdate(current, latest string) bool {
	semverValid := true
	currentV, err := semver.NewVersion(current)
	if err != nil {
		semverValid = false
	}
	latestV, err := semver.NewVersion(latest)
	if err != nil {
		semverValid = false
	}
	if semverValid {
		if currentV.Equal(latestV) {
			return false // up-to-date
		}
		if currentV.GreaterThan(latestV) {
			return false // local version is higher
		}
	} else {
		// semver failed - just check tags
		if latest == current {
			return false
		}
	}
	return true
}

func (u *Updater) downloadAndReplaceApp(asset Asset) error {
	filename := path.Base(asset.BrowserDownloadURL)
	switch {
	case strings.HasSuffix(filename, ".zip"):
		// fine
	default:
		return errors.Errorf("file not supported: %s", filename)
	}
	resp, err := u.Client.Get(asset.BrowserDownloadURL)
	if err != nil {
		return errors.Wrap(err, "download asset")
	}
	defer resp.Body.Close()
	const defaultTempDir = ""
	f, err := os.CreateTemp(defaultTempDir, "*-"+filename)
	if err != nil {
		return errors.Wrap(err, "create temp file")
	}
	_, err = io.Copy(f, io.LimitReader(resp.Body, u.DownloadBytesLimit))
	if err != nil {
		f.Close()
		return errors.Wrap(err, "download asset")
	}
	f.Close()
	executable, err := u.GetExecutable()
	if err != nil {
		return errors.Wrap(err, "get executable")
	}
	appPath, err := appPathFromExecutable(executable)
	if err != nil {
		return errors.Wrap(err, "find app path")
	}
	appPathDir := filepath.Dir(appPath)
	appPreviousPath := appPath + ".previous"
	err = os.Rename(appPath, appPreviousPath)
	if err != nil {
		_, statErr := os.Stat(appPath)
		// not exist is ok, just ignore it
		if !os.IsNotExist(statErr) {
			return errors.Wrap(err, "rename existing app")
		}
	}
	err = archiver.Unarchive(f.Name(), appPathDir)
	if err != nil {
		return errors.Wrap(err, "unarchive")
	}
	err = os.RemoveAll(appPreviousPath)
	if err != nil {
		return errors.Wrap(err, "remove previous")
	}
	return nil
}

// Release is a GitHub release.
type Release struct {
	TagName         string    `json:"tag_name"`
	Assets          []Asset   `json:"assets"`
	Body            string    `json:"body"`
	CreatedAtString string    `json:"created_at"`
	CreatedAt       time.Time `json:"created_at_time"`
}

// Asset is a file within a Release on GitHub.
type Asset struct {
	Name               string `json:"name"`
	BrowserDownloadURL string `json:"browser_download_url"`
}

// appPathFromExecutable gets the .app path from the currently
// running executable.
func appPathFromExecutable(p string) (string, error) {
	if !strings.HasSuffix(p, "/Contents/MacOS/xbar") {
		return "", errors.New("executable not where it should be")
	}
	return strings.TrimSuffix(p, "/Contents/MacOS/xbar"), nil
}
