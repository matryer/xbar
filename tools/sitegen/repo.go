package main

import (
	"context"
	"encoding/base64"
	"fmt"
	"path"
	"path/filepath"
	"strings"
	"sync"
	"time"

	"github.com/google/go-github/github"
	"github.com/matryer/xbar/pkg/metadata"
	"github.com/pkg/errors"
	"golang.org/x/oauth2"
)

// EachFunc is the callback that recievesplugins
// described with metadata.Plugin.
type EachFunc func(payload metadata.Plugin)

// RepoReader reads the repo calling EachFunc for each
// page of metadata.Plugin results.
// Any parsing errors are ignored.
// Connection errors will return.
type RepoReader struct {
	RepoOwner         string
	RepoName          string
	EachPluginFn      EachFunc
	GitHubAccessToken string

	PrintErrors bool

	// SmallSample will only run a small selection of
	// items. Useful for dev/testing.
	SmallSample bool

	usersLock sync.RWMutex // protects users
	users     map[string]*github.User
}

// All walks all items in the plugin repository.
func (r *RepoReader) All(ctx context.Context) error {
	r.users = make(map[string]*github.User)
	ts := oauth2.StaticTokenSource(
		&oauth2.Token{
			AccessToken: r.GitHubAccessToken,
		},
	)
	var cancel context.CancelFunc
	ctx, cancel = context.WithCancel(ctx)
	defer cancel()
	tc := oauth2.NewClient(ctx, ts)
	tc.Timeout = 2 * time.Second
	gh := github.NewClient(tc)
	const branchName = "master" // todo: update this
	branch, _, err := gh.Repositories.GetBranch(ctx, r.RepoOwner, r.RepoName, branchName)
	if err != nil {
		return errors.Wrapf(err, "get branch: %s/%s[%s]", r.RepoOwner, r.RepoName, branchName)
	}
	sha := branch.Commit.SHA
	tree, _, err := gh.Git.GetTree(ctx, r.RepoOwner, r.RepoName, *sha, true)
	if err != nil {
		return errors.Wrapf(err, "get tree: %s/%s (%s)", r.RepoOwner, r.RepoName, *sha)
	}
	stop := make(chan struct{})
	payloadChan := make(chan metadata.Plugin)
	errChan := make(chan error)
	go func() {
		for payload := range payloadChan {
			r.EachPluginFn(payload)
		}
	}()
	go func() {
		for err := range errChan {
			if r.PrintErrors {
				fmt.Printf("\n%s\n", err)
			}
		}
	}()
	var wg sync.WaitGroup
	semaphore := make(chan struct{}, 8)
	defer close(stop) // stop should fire first
	if r.SmallSample {
		tree.Entries = tree.Entries[:50]
	}
	for _, item := range tree.Entries {
		time.Sleep(70 * time.Millisecond) // keep cool
		if err := ctx.Err(); err != nil {
			return err
		}
		if *item.Type == "blob" {
			if strings.HasPrefix(path.Base(*item.Path), ".") {
				// skip dotfiles
				continue
			}
			if filepath.Ext(*item.Path) == ".md" {
				// skip markdown files
				continue
			}
			wg.Add(1)
			select {
			case semaphore <- struct{}{}: // will block if buffer is full
			case <-ctx.Done():
				return ctx.Err()
			case <-stop:
				return nil
			}
			go func(ctx context.Context, gh *github.Client, treeEntry github.TreeEntry) {
				defer wg.Done()
				defer func() {
					select {
					case <-stop:
						return
					case <-time.After(100 * time.Millisecond): // pace
						<-semaphore // release slot
					}
				}()
				// todo: skip .github and other dotfiles
				payload, err := r.loadPluginMetadata(ctx, gh, *treeEntry.Path, treeEntry)
				if err != nil {
					err = errors.Wrapf(err, "loadPluginMetadata: %v", *treeEntry.Path)
					select {
					case <-stop:
						return
					case errChan <- err:
					}
					return
				}
				select {
				case <-stop:
					return
				case payloadChan <- payload:
				}
			}(ctx, gh, item)
		}
	}
	wg.Wait()
	return nil
}

func (r *RepoReader) loadPluginMetadata(ctx context.Context, gh *github.Client, path string, treeEntry github.TreeEntry) (metadata.Plugin, error) {
	var plugin metadata.Plugin
	if err := ctx.Err(); err != nil {
		return plugin, err
	}
	blob, _, err := gh.Git.GetBlob(ctx, r.RepoOwner, r.RepoName, *treeEntry.SHA)
	if err != nil {
		return plugin, errors.Wrapf(err, "get blob: %s/%s (%s)", r.RepoOwner, r.RepoName, *treeEntry.SHA)
	}
	if blob.Content == nil && *blob.Content != "" {
		return plugin, errors.Wrapf(err, "empty blob: %s/%s (%s)", r.RepoOwner, r.RepoName, *treeEntry.SHA)
	}
	decodedContent, err := base64.StdEncoding.DecodeString(*blob.Content)
	if err != nil {
		return plugin, errors.Wrapf(err, "decode blob: %s/%s (%s)", r.RepoOwner, r.RepoName, *treeEntry.SHA)
	}
	plugin, err = metadata.Parse(metadata.DebugfNoop, path, string(decodedContent))
	if err != nil {
		return plugin, err
	}
	plugin.Path = path
	plugin.DocsPlugin = path + ".html"
	plugin.DocsCategory = filepath.Dir(path) + ".html"
	plugin.CategoryPath = filepath.Dir(path)
	if err := plugin.Complete(); err != nil {
		return plugin, err
	}
	for i := range plugin.Authors {
		if plugin.Authors[i].GitHubUsername != "" {
			var user *github.User
			var ok bool
			r.usersLock.RLock()
			user, ok = r.users[plugin.Authors[i].GitHubUsername]
			r.usersLock.RUnlock()
			if !ok {
				user, _, err = gh.Users.Get(ctx, plugin.Authors[i].GitHubUsername)
				if err != nil {
					return plugin, errors.Wrapf(err, "get %q from GitHub", plugin.Authors[i].GitHubUsername)
				}
				r.usersLock.Lock()
				r.users[plugin.Authors[i].GitHubUsername] = user
				r.usersLock.Unlock()
			}
			if user.Name != nil {
				plugin.Authors[i].Name = *user.Name
			}
			if user.AvatarURL != nil {
				plugin.Authors[i].ImageURL = *user.AvatarURL
			}
			if user.Bio != nil {
				plugin.Authors[i].Bio = *user.Bio
			}
		}
	}
	return plugin, nil
}
