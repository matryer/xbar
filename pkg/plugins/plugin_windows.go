package plugins

import (
	"bytes"
	"log"
	"os/exec"

	"github.com/pkg/errors"
)

// Setpgid is a no-op in Windows
func Setpgid(cmd *exec.Cmd) {
}

func (p *Plugin) runInTerminal(appleScriptTemplate3, command, paramsStr string, vars []string) error {

	log.Println(p.Command, "RunInTerminal", command)
	cmd := exec.Command("start", "cmd", "/k", command)
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
