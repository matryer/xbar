package main

import (
	"encoding/json"
	"io/ioutil"
	"os"
	"path/filepath"

	"github.com/pkg/errors"
)

type settings struct {
	path string `json:"-"`

	// AutoUpdate indicates that xbar should automatically
	// update itself.
	AutoUpdate bool `json:"autoupdate"`
}

func loadSettings(path string) (*settings, error) {
	s := &settings{
		path: path,
	}
	b, err := ioutil.ReadFile(path)
	if err != nil {
		if os.IsNotExist(err) {
			// file not found - it's ok, just use defaults
			return s, nil
		}
		return nil, errors.Wrap(err, "ReadFile")
	}
	err = json.Unmarshal(b, s)
	if err != nil {
		return nil, errors.Wrap(err, "Unmarshal")
	}
	return s, nil
}

func (s *settings) save() error {
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
