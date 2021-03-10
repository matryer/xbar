package main

import (
	"context"
	"os"
	"testing"
	"time"

	"github.com/matryer/is"
	"github.com/matryer/xbar/pkg/metadata"
)

func TestReadRepo(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping")
		return
	}
	is := is.New(t)
	ctx := context.Background()
	var cancel context.CancelFunc
	ctx, cancel = context.WithTimeout(ctx, 2*time.Minute)
	defer cancel()
	each := EachFunc(func(payload metadata.Plugin) {
		//log.Printf("discovered plugin: %v\b", payload.Path)
	})
	r := &RepoReader{
		RepoOwner:         "matryer",
		RepoName:          "xbar-plugins",
		EachPluginFn:      each,
		GitHubAccessToken: os.Getenv("XBAR_GITHUB_ACCESS_TOKEN"),
	}
	err := r.All(ctx)
	is.NoErr(err) // ReadRepo

}
