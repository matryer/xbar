package main

import (
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"syscall"

	"github.com/pkg/errors"
	wails "github.com/wailsapp/wails/v2"
)

// CommandService provides window service.
type CommandService struct {
	runtime    *wails.Runtime
	OnRefresh  func()
	clearCache func(passive bool)
}

// NewCommandService makes a new CommandService.
func NewCommandService(OnRefresh func()) *CommandService {
	return &CommandService{
		OnRefresh: OnRefresh,
	}
}

// ClearCache clears the cache.
func (c *CommandService) ClearCache() {
	c.clearCache(false)
}

// RefreshAllPlugins refreshes all plugins.
func (c *CommandService) RefreshAllPlugins() {
	c.OnRefresh()
}

// WindowHide hides the window.
func (c *CommandService) WindowHide() {
	c.runtime.Window.Hide()
}

// WindowMinimise minimises the window.
func (c *CommandService) WindowMinimise() {
	c.runtime.Window.Minimise()
}

// OpenPath opens a window.
func (c CommandService) OpenPath(path string) error {
	err := c.runCommand("open", path)
	if err != nil {
		return errors.Wrapf(err, "unable to open path %q", path)
	}
	return nil
}

// OpenURL opens a window.
func (c CommandService) OpenURL(url string) error {
	err := c.runCommand("open", url)
	if err != nil {
		return errors.Wrapf(err, "unable to open URL %s", url)
	}
	return nil
}

// OpenFile opens a file for editing.
func (c CommandService) OpenFile(path string) error {
	// try with $EDITOR
	err := c.runCommand(os.Getenv("EDITOR"), filepath.Join(pluginDirectory, path))
	if nil == err {
		return nil // done
	}
	log.Println("open failed:", err)
	// try with open
	err = c.runCommand("open", filepath.Join(pluginDirectory, path))
	if err != nil {
		return errors.Wrapf(err, "unable to open directory %q", path)
	}
	return nil
}

// runCommand runs the command, wiring up stdout and stderr, and
// inheriting the environment.
func (CommandService) runCommand(name string, args ...string) error {
	cmd := exec.Command(name, args...)
	cmd.SysProcAttr = &syscall.SysProcAttr{
		Setpgid: true,
	}
	cmd.Env = os.Environ()
	return cmd.Run()
}
