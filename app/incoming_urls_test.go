package main

import (
	"testing"

	"github.com/matryer/is"
)

func TestParseIncomingURL(t *testing.T) {
	is := is.New(t)

	result, err := parseIncomingURL(`xbar://app.xbarapp.com/openPlugin?path=IoT/homebridge.10s.py`)
	is.NoErr(err)
	is.Equal(result.Action, "openPlugin")
	is.Equal(result.Params.Get("path"), "IoT/homebridge.10s.py")

	result, err = parseIncomingURL(`xbar://app.xbarapp.com/refreshPlugin?path=cycle_text_and_detail`)
	is.NoErr(err)
	is.Equal(result.Action, "refreshPlugin")
	is.Equal(result.Params.Get("path"), "cycle_text_and_detail")

	result, err = parseIncomingURL(`xbar://app.xbarapp.com/nope?path=cycle_text_and_detail`)
	is.True(err != nil)

}
