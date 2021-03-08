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
	var incomingURL incomingURL
	u, err := url.Parse(urlStr)
	if err != nil {
		return incomingURL, err
	}
	if u.Scheme != "xbar" && u.Host != "app.xbarapp.com" {
		return incomingURL, errors.New("not an xbar:// url")
	}
	incomingURL.Action = strings.Trim(u.Path, "/")
	incomingURL.Params = u.Query()
	switch incomingURL.Action {
	case "openPlugin":
	case "refreshPlugin":
	default: // not ok
		return incomingURL, errors.Errorf("unsupported action %q", incomingURL.Action)
	}
	return incomingURL, nil
}
