package main

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/matryer/is"
)

func TestSettings(t *testing.T) {
	is := is.New(t)

	t.Cleanup(func() {
		os.RemoveAll(filepath.Join("testdata", "settings.json"))
	})

	s, err := loadSettings(filepath.Join("testdata", "settings.json"))
	is.NoErr(err)
	s.AutoUpdate = true

	err = s.save()
	is.NoErr(err)

	s, err = loadSettings(filepath.Join("testdata", "settings.json"))
	is.NoErr(err)
	is.Equal(s.AutoUpdate, true)

}
