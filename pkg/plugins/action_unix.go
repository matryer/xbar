//go:build linux || darwin
package plugins

import (
	"os/exec"
	"syscall"
)

func Setpgid(cmd *exec.Cmd) {
	cmd.SysProcAttr = &syscall.SysProcAttr{
		Setpgid: true,
	}
}
