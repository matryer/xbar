package main

import (
	"encoding/json"
	"io/ioutil"
	"os"
	"path/filepath"
	"sync"

	"github.com/pkg/errors"
)

type settings struct {
	sync.Mutex

	path string `json:"-"`

	// AutoUpdate indicates that xbar should automatically
	// update itself.
	AutoUpdate bool `json:"autoupdate"`

	Terminal struct {
		AppleScriptWithVarsTemplate string `json:"appleScriptWithVarsTemplate"`
	} `json:"terminal"`
}

func (s *settings) setDefaults() {
	if s.Terminal.AppleScriptWithVarsTemplate == "" {
		s.Terminal.AppleScriptWithVarsTemplate = `activate application "Terminal"
tell application "Terminal" 
	if not (exists window 1) then reopen
	set quotedScriptName to quoted form of "{{ .Command }}"
	set commandLine to {{ .Vars }} & " " & quotedScriptName
	do script commandLine
end tell
`
	}
}

func loadSettings(path string) (*settings, error) {
	s := &settings{
		path: path,
	}
	b, err := ioutil.ReadFile(path)
	if err != nil {
		if os.IsNotExist(err) {
			// file not found - it's ok, just use defaults
			s.setDefaults()
			return s, nil
		}
		return nil, errors.Wrap(err, "ReadFile")
	}
	err = json.Unmarshal(b, s)
	if err != nil {
		return nil, errors.Wrap(err, "Unmarshal")
	}
	s.setDefaults()
	return s, nil
}

func (s *settings) save() error {
	s.Lock()
	defer s.Unlock()
	s.setDefaults()
	b, err := json.MarshalIndent(s, "", "\t")
	if err != nil {
		return errors.Wrap(err, "MarshalIndent")
	}
	err = os.MkdirAll(filepath.Dir(s.path), 0777)
	if err != nil {
		return errors.Wrap(err, "MkdirAll")
	}
	err = ioutil.WriteFile(s.path, b, 0777)
	if err != nil {
		return errors.Wrap(err, "WriteFile")
	}
	return nil
}
