package plugins

import (
	"context"
	"fmt"
	"os"
	"os/exec"
	"runtime"
	"strings"
	"syscall"
	"time"
)

// ActionFunc is a function that handles the
// menu item clicks/selections.
type ActionFunc func(ctx context.Context)

// actionTimeout is the amount of time xbar will wait for an
// action to complete.
const actionTimeout = 10 * time.Second

// Action returns a function that will handle the
// action should this item be clicked/selected.
// nil response indicates no action, so you must check
// for nil before calling.
// The following code should be called:
//  actionFunc := item.Action()
//  if actionFunc != nil {
//  	actionFunc(ctx)
//  }
func (i *Item) Action() ActionFunc {
	debugf := DebugfNoop
	if i.Plugin != nil {
		debugf = i.Plugin.Debugf
	}
	if i.Params.Href != "" {
		return actionHref(debugf, i.Params.Href)
	}
	if i.Params.Shell != "" {
		return actionShell(debugf, i, i.Params.Shell, i.Params.ShellParams)
	}
	if i.Params.Refresh == true {
		return actionRefresh(debugf, i.Plugin.Refresh)
	}
	return nil // no action
}

// actionHref gets an ActionFunc that opens a URL.
func actionHref(debugf DebugFunc, href string) ActionFunc {
	return func(ctx context.Context) {
		debugf("action href: %s", href)
		commandCtx, cancel := context.WithTimeout(ctx, actionTimeout)
		defer cancel()
		var err error
		switch runtime.GOOS {
		case "linux":
			cmd := exec.CommandContext(commandCtx, "xdg-open", href)
			cmd.SysProcAttr = &syscall.SysProcAttr{
				Setpgid: true,
			}
			cmd.Run()
		case "windows":
			cmd := exec.CommandContext(commandCtx, "rundll32", "url.dll,FileProtocolHandler", href)
			cmd.SysProcAttr = &syscall.SysProcAttr{
				Setpgid: true,
			}
			cmd.Run()
		case "darwin":
			cmd := exec.CommandContext(commandCtx, "open", href)
			cmd.SysProcAttr = &syscall.SysProcAttr{
				Setpgid: true,
			}
			cmd.Run()
		default:
			err = fmt.Errorf("unsupported platform")
		}
		if err != nil {
			debugf("ERR: action href: %s", err)
			return
		}
	}
}

// actionShell gets an ActionFunc that runs a shell command.
func actionShell(debugf DebugFunc, item *Item, command string, params []string) ActionFunc {
	return func(ctx context.Context) {
		var commandExec string
		var commandArgs []string
		if item.Params.Terminal {
			shell := os.Getenv("SHELL")
			if shell == "" {
				shell = "/bin/bash"
			}
			commandExec = shell
			commandArgs = append([]string{command}, params...)
		} else {
			commandExec = command
			commandArgs = params
		}
		debugf("exec: %s %s", commandExec, strings.Join(commandArgs, " "))
		cmd := exec.CommandContext(context.Background(), commandExec, commandArgs...)
		cmd.SysProcAttr = &syscall.SysProcAttr{
			Setpgid: true,
		}
		err := cmd.Start()
		if err != nil {
			debugf("ERR: action shell: %s", err)
			return
		}
	}
}

// actionRefresh gets an ActionFunc that manually refreshes the
// Plugin.
func actionRefresh(debugf DebugFunc, refreshFunc func(ctx context.Context)) ActionFunc {
	return func(ctx context.Context) {
		debugf("action refresh")
		refreshFunc(ctx)
		return
	}
}
