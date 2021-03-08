package main

import (
	"log"
	"os"
	"os/exec"
	"path/filepath"

	"github.com/pkg/errors"
)

// CommandService provides window service.
type CommandService struct{}

// NewCommandService makes a new CommandService.
func NewCommandService() *CommandService {
	return &CommandService{}
}

// OpenPath opens a window.
func (CommandService) OpenPath(path string) error {
	err := run("open", path)
	if err != nil {
		return errors.Wrapf(err, "unable to open path %q", path)
	}
	return nil
}

// OpenURL opens a window.
func (CommandService) OpenURL(url string) error {
	err := run("open", url)
	if err != nil {
		return errors.Wrapf(err, "unable to open URL %s", url)
	}
	return nil
}

// OpenFile opens a file for editing.
func (CommandService) OpenFile(path string) error {
	// try with $EDITOR
	err := run(os.Getenv("EDITOR"), filepath.Join(pluginDirectory, path))
	if nil == err {
		return nil
	}
	log.Println("open failed:", err)
	// try with open
	err = run("open", filepath.Join(pluginDirectory, path))
	if err != nil {
		return errors.Wrapf(err, "unable to open directory %q", path)
	}
	return nil
}

func run(name string, args ...string) error {
	c := exec.Command(name, args...)
	c.Env = os.Environ()
	return c.Run()
}
