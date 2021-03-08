package main

import (
	"context"
	"testing"
	"time"

	"github.com/matryer/is"
	"github.com/matryer/xbar/pkg/metadata"
)

func TestReadRepo(t *testing.T) {
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
		RepoName:          "bitbar-plugins",
		EachPluginFn:      each,
		GitHubAccessToken: "",
	}
	err := r.All(ctx)
	is.NoErr(err) // ReadRepo

}
