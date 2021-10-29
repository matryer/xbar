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
		AppleScriptTemplate3 string `json:"appleScriptTemplate3"`
	} `json:"terminal"`
}

func (s *settings) setDefaults() {
	if s.Terminal.AppleScriptTemplate3 == "" {
		s.Terminal.AppleScriptTemplate3 = `
			set quotedScriptName to quoted form of "{{ .Command }}"
		{{ if .Params }}
			set commandLine to {{ .Vars }} & " " & quotedScriptName & " " & {{ .Params }}
		{{ else }}
			set commandLine to {{ .Vars }} & " " & quotedScriptName
		{{ end }}
			if application "Terminal" is running then 
				tell application "Terminal"
					do script commandLine
					activate
				end tell
			else
				tell application "Terminal"
					do script commandLine in window 1
					activate
				end tell
			end if
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
