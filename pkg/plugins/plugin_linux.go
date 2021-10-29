package plugins

import (
	"bytes"
	"log"
	"os/exec"
	"syscall"

	"github.com/pkg/errors"
)

func Setpgid(cmd *exec.Cmd) {
	cmd.SysProcAttr = &syscall.SysProcAttr{
		Setpgid: true,
	}
}

func (p *Plugin) runInTerminal(appleScriptTemplate3, command, paramsStr string, vars []string) error {

	log.Println(p.Command, "RunInTerminal", command)
	// x-terminal-emulator is provided by the 'alternatives' system
	// on most (all?) common Linux distributions, this is mapped to the default terminal application
	cmd := exec.Command("x-terminal-emulator", "-e", command)
	cmd.Env = append(cmd.Env, vars...)

	var stderr bytes.Buffer
	cmd.Stderr = &stderr
	err := cmd.Run()
	if err != nil {
		p.Debugf("(ignoring) RunInTerminal failed: %s", err)
	}
	if cmd.ProcessState != nil && cmd.ProcessState.ExitCode() != 0 {
		return errors.Errorf("run in terminal script failed: %s", stderr.String())
	}
	return nil
}
