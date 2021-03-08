package plugins

import (
	"context"
	"path/filepath"
	"strings"
	"testing"
	"time"

	"github.com/matryer/is"
)

func TestPluginParams(t *testing.T) {
	is := is.New(t)
	ctx := context.Background()
	ctx, cancel := context.WithTimeout(ctx, 1*time.Second)
	defer cancel()
	p := NewPlugin(filepath.Join("testdata", "plugins", "params.3s.sh"))
	is.Equal(p.RefreshInterval.Duration(), 3*time.Second)
	p.Refresh(ctx)
	is.Equal(len(p.Items.CycleItems), 3)
	is.Equal(p.Items.CycleItems[0].Text, "one")
	is.Equal(p.Items.CycleItems[0].Params.Color, "red")
	is.Equal(p.Items.CycleItems[1].Text, "two")
	is.Equal(p.Items.CycleItems[1].Params.Color, "blue")
	is.Equal(p.Items.CycleItems[2].Text, "three")
	is.Equal(p.Items.CycleItems[2].Params.Href, "https://xbarapp.com")
}

func TestParseParams(t *testing.T) {
	is := is.New(t)

	var s string
	var params ItemParams
	var err error

	// check default values
	s, params, err = parseParams(`no params`)
	is.NoErr(err)
	is.Equal(s, "no params")
	is.Equal(params.Terminal, false)  // Terminal
	is.Equal(params.Refresh, false)   // Refresh
	is.Equal(params.Dropdown, true)   // Dropdown
	is.Equal(params.Length, 0)        // Length
	is.Equal(params.Trim, true)       // Trim
	is.Equal(params.Alternate, false) // Alternate
	is.Equal(params.Emojize, true)    // Emojize
	is.Equal(params.ANSI, true)       // ANSI

	s, params, err = parseParams(`Before params |color=#123def`)
	is.NoErr(err)
	is.Equal(s, "Before params ")
	is.Equal(params.Color, "#123def")

	// with quotes
	s, params, err = parseParams(`Before params | shell="/annoying path with spaces/file.sh"`)
	is.NoErr(err)
	is.Equal(s, "Before params ")
	is.Equal(params.Shell, "/annoying path with spaces/file.sh")

	s, params, err = parseParams(`Before params | nope=badparam`)
	is.True(err != nil)
	is.Equal(err.Error(), "unknown parameter: nope")

}

func TestParseErrors(t *testing.T) {
	iss := is.New(t)

	assertParseErr := func(is *is.I, err string, s string) {
		p := &Plugin{}
		_, actualErr := p.parseOutput(context.Background(), "text.txt", strings.NewReader(s))
		is.True(actualErr != nil)
		is.Equal(err, actualErr.Error())
	}

	assertParseErr(iss, `text.txt:3: terminal: expected "true" or "false", not "123"`, `
	
one | terminal=123

`)
	assertParseErr(iss, `text.txt:2: length: expected an int, not "false"`, `
one | length=false
`)

}

func TestParseEmoji(t *testing.T) {
	const text = "I sure would like some :spaghetti: and :pizza:."
	var (
		is = is.New(t)
		p  = &Plugin{}
		r  = strings.NewReader(text)
	)
	items, err := p.parseOutput(context.Background(), "with-emoji.txt", r)
	is.NoErr(err)
	is.Equal(items.CycleItems[0].Text, "I sure would like some 🍝 and 🍕.")

	r = strings.NewReader(text + " | emojize=false")
	items, err = p.parseOutput(context.Background(), "no-emoji.txt", r)
	is.NoErr(err)
	is.Equal(items.CycleItems[0].Text, text)
}
