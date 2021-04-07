package update

import (
	"archive/zip"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"path"
	"path/filepath"
	"testing"
	"time"

	"github.com/matryer/is"
)

func TestForReals(t *testing.T) {
	is := is.New(t)

	t.Cleanup(func() {
		err := os.RemoveAll(filepath.Join("testreal-testarea"))
		is.NoErr(err)
	})

	u := &Updater{
		CurrentVersion:              "v0.0.1",
		LatestReleaseGitHubEndpoint: "https://api.github.com/repos/matryer/updatetest/releases/latest",
		Client:                      &http.Client{Timeout: 10 * time.Minute},
		SelectAsset: func(release Release, asset Asset) bool {
			// look for the zip file
			return filepath.Ext(asset.Name) == ".zip"
			//return asset.Name == "xbar."+release.TagName+".zip"
		},
		DownloadBytesLimit: 10_741_824, // 10MB
		GetExecutable: func() (string, error) {
			return "./testreal-testarea/xbar.app/Contents/MacOS/xbar", nil
		},
	}
	_, hasUpdate, err := u.HasUpdate()
	is.NoErr(err)
	is.Equal(hasUpdate, true)
	_, err = u.Update()
	is.NoErr(err)
}

func TestUpdate(t *testing.T) {
	is := is.New(t)
	t.Cleanup(func() {
		err := os.RemoveAll(filepath.Join("testupdate-testarea"))
		is.NoErr(err)
	})
	downloadServer := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		zipWriter := zip.NewWriter(w)
		defer func() {
			err := zipWriter.Close()
			is.NoErr(err)
		}()

		f, err := zipWriter.Create("xbar.version.zip")
		is.NoErr(err)

		n, err := f.Write([]byte("12345678")) // sample data
		is.NoErr(err)                         // tarWriter.Write
		is.Equal(n, 8)                        // should write eight bytes
	}))
	t.Cleanup(func() {
		downloadServer.Close()
	})
	apiServer := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		version := "v2.0.0"
		response := Release{
			CreatedAtString: time.Now().Format(time.RFC3339Nano),
			TagName:         version,
			Assets: []Asset{
				{
					Name:               "xbar-" + version + ".zip",
					BrowserDownloadURL: downloadServer.URL + "/xbar-" + version + ".zip",
				},
			},
		}
		b, err := json.Marshal(response)
		is.NoErr(err) // marshal
		_, err = w.Write(b)
		is.NoErr(err) // write
	}))
	t.Cleanup(func() {
		apiServer.Close()
	})
	u := Updater{
		DownloadBytesLimit:          1_000_000,
		LatestReleaseGitHubEndpoint: apiServer.URL,
		CurrentVersion:              "v1.9.0",
		Client:                      &http.Client{Timeout: 1 * time.Minute},
		SelectAsset: func(release Release, asset Asset) bool {
			return path.Base(asset.BrowserDownloadURL) == "xbar-"+release.TagName+".zip"
		},
		GetExecutable: func() (string, error) {
			return "./testupdate-testarea/xbar.app/Contents/MacOS/xbar", nil
		},
	}
	release, err := u.Update()
	is.NoErr(err)
	is.Equal(release.TagName, "v2.0.0")
}

func TestAppPathFromExecutable(t *testing.T) {
	is := is.New(t)

	appPath, err := appPathFromExecutable("/path/to/xbar.app/Contents/MacOS/xbar")
	is.NoErr(err)
	is.Equal(appPath, "/path/to/xbar.app")
}

func TestMatchingVersions(t *testing.T) {
	is := is.New(t)

	t.Cleanup(func() {
		err := os.RemoveAll(filepath.Join("testreal-testarea"))
		is.NoErr(err)
	})

	apiServer := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		version := "v2.1.0"
		response := Release{
			CreatedAtString: time.Now().Format(time.RFC3339Nano),
			TagName:         version,
			Assets: []Asset{
				{
					Name:               "xbar-" + version + ".zip",
					BrowserDownloadURL: "/xbar-" + version + ".zip",
				},
			},
		}
		b, err := json.Marshal(response)
		is.NoErr(err) // marshal
		_, err = w.Write(b)
		is.NoErr(err) // write
	}))
	t.Cleanup(func() {
		apiServer.Close()
	})

	u := &Updater{
		CurrentVersion:              "v2.1.0",
		LatestReleaseGitHubEndpoint: apiServer.URL,
		Client:                      &http.Client{Timeout: 10 * time.Minute},
		SelectAsset: func(release Release, asset Asset) bool {
			return asset.Name == "xbar."+release.TagName+".zip"
		},
		DownloadBytesLimit: 10_741_824, // 10MB
		GetExecutable: func() (string, error) {
			return "./testreal-testarea/xbar.app/Contents/MacOS/xbar", nil
		},
	}
	_, hasUpdate, err := u.HasUpdate()
	is.NoErr(err)
	is.Equal(hasUpdate, false)
	_, err = u.Update()
	is.NoErr(err)
}

func TestLocalVersionIsHigher(t *testing.T) {
	is := is.New(t)

	t.Cleanup(func() {
		err := os.RemoveAll(filepath.Join("testreal-testarea"))
		is.NoErr(err)
	})

	apiServer := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		version := "v2.1.0"
		response := Release{
			CreatedAtString: time.Now().Format(time.RFC3339Nano),
			TagName:         version,
			Assets: []Asset{
				{
					Name:               "xbar-" + version + ".zip",
					BrowserDownloadURL: "/xbar-" + version + ".zip",
				},
			},
		}
		b, err := json.Marshal(response)
		is.NoErr(err) // marshal
		_, err = w.Write(b)
		is.NoErr(err) // write
	}))
	t.Cleanup(func() {
		apiServer.Close()
	})

	u := &Updater{
		CurrentVersion:              "v2.1.1",
		LatestReleaseGitHubEndpoint: apiServer.URL,
		Client:                      &http.Client{Timeout: 10 * time.Minute},
		SelectAsset: func(release Release, asset Asset) bool {
			return asset.Name == "xbar."+release.TagName+".zip"
		},
		DownloadBytesLimit: 10_741_824, // 10MB
		GetExecutable: func() (string, error) {
			return "./testreal-testarea/xbar.app/Contents/MacOS/xbar", nil
		},
	}
	_, hasUpdate, err := u.HasUpdate()
	is.NoErr(err)
	is.Equal(hasUpdate, false)
	_, err = u.Update()
	is.NoErr(err)
}
