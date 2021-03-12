package main

import (
	"encoding/json"
	"io"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/matryer/is"
	"github.com/matryer/xbar/pkg/metadata"
)

var docsFolder = filepath.Join("public", "docs")

func TestPluginMetadata(t *testing.T) {
	is := is.New(t)

	pluginMetadataPath := filepath.Join(docsFolder, "/plugins/Dev/Tutorial/cycle_text_and_detail.sh.json")
	p := loadPluginMetadata(is, pluginMetadataPath)
	is.Equal(p.Version, version) // version doesn't match
	is.True(p.LastUpdated != "")

	is.Equal(p.Plugin.Path, "Dev/Tutorial/cycle_text_and_detail.sh")
	is.Equal(len(p.Plugin.Files), 1)
	is.Equal(p.Plugin.Files[0].Filename, "cycle_text_and_detail.sh")
	is.True(p.Plugin.Files[0].Content != "")
	is.Equal(p.Plugin.Filename, "cycle_text_and_detail.sh")
	is.Equal(p.Plugin.Dir, "Dev/Tutorial")
	is.Equal(p.Plugin.DocsPlugin, "Dev/Tutorial/cycle_text_and_detail.sh.html")
	is.Equal(p.Plugin.DocsCategory, "Dev/Tutorial.html")
	is.Equal(len(p.Plugin.PathSegments), 2)
	is.Equal(p.Plugin.PathSegments[0], "Dev")
	is.Equal(p.Plugin.PathSegments[1], "Tutorial")
	is.Equal(len(p.Plugin.CategoryPathSegments), 2)
	is.Equal(p.Plugin.CategoryPathSegments[0].Text, "Dev")
	is.Equal(p.Plugin.CategoryPathSegments[0].Path, "Dev")
	is.Equal(p.Plugin.CategoryPathSegments[0].IsLast, false)
	is.Equal(p.Plugin.CategoryPathSegments[1].Text, "Tutorial")
	is.Equal(p.Plugin.CategoryPathSegments[1].Path, "Dev/Tutorial")
	is.Equal(p.Plugin.CategoryPathSegments[1].IsLast, true)

	is.Equal(p.Plugin.Version, "v1.0")
	is.Equal(p.Plugin.Title, "Cycle text and detail text")
	is.Equal(p.Plugin.Desc, "Example of how to include items that cycle in the top, and items that only appear in the dropdown.")
	is.Equal(p.Plugin.Author, "Mat Ryer")
	is.Equal(len(p.Plugin.Authors), 1)
	is.Equal(p.Plugin.Authors[0].GitHubUsername, "matryer")
	is.True(p.Plugin.ImageURL != "")
	is.Equal(strings.Join(p.Plugin.Dependencies, ", "), "")
	is.Equal(p.Plugin.AboutURL, "https://github.com/matryer/bitbar-plugins/blob/master/Tutorial/cycle_text_and_detail.sh")
	is.Equal(p.Plugin.LastUpdated.IsZero(), false)
	is.Equal(len(p.Plugin.Vars), 0)
}

type pluginPayload struct {
	Version     string
	LastUpdated string
	Plugin      metadata.Plugin
}

func loadPluginMetadata(is *is.I, path string) pluginPayload {
	is.Helper()
	f, err := os.Open(path)
	is.NoErr(err) // Open
	defer f.Close()
	b, err := io.ReadAll(f)
	is.NoErr(err) // ReadAll
	var payload pluginPayload
	err = json.Unmarshal(b, &payload)
	is.NoErr(err)
	return payload
}
