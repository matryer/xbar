package main

import (
	"net/url"
	"strings"

	"github.com/pkg/errors"
)

type incomingURL struct {
	// Action is the action to take.
	Action string
	// Params are the parameters for the action.
	Params url.Values
}

// parseIncomingURL parses an incoming xbar:// URL.
func parseIncomingURL(urlStr string) (incomingURL, error) {
	var inURL incomingURL
	u, err := url.Parse(urlStr)
	if err != nil {
		return inURL, err
	}
	if u.Scheme != "xbar" && u.Host != "app.xbarapp.com" {
		return inURL, errors.New("not an xbar:// url")
	}
	inURL.Action = strings.Trim(u.Path, "/")
	inURL.Params = u.Query()
	switch inURL.Action {
	case "openPlugin":
	case "refreshPlugin":
	default: // not ok
		return inURL, errors.Errorf("unsupported action %q", inURL.Action)
	}
	return inURL, nil
}
