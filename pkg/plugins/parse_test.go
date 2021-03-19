package plugins

import (
	"context"
	"os"
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
	is.Equal(p.Items.CycleItems[0].Params.Color, "#ff0000")
	is.Equal(p.Items.CycleItems[1].Text, "two")
	is.Equal(p.Items.CycleItems[1].Params.Color, "#0000ff")
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

	_, params, err = parseParams(`Before params | nope=badparam`)
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
	is.Equal(len(items.CycleItems), 1)
	is.Equal(items.CycleItems[0].Text, "I sure would like some 🍝 and 🍕.")

	r = strings.NewReader(text + " | emojize=false")
	items, err = p.parseOutput(context.Background(), "no-emoji.txt", r)
	is.NoErr(err)
	is.Equal(len(items.CycleItems), 1)
	is.Equal(items.CycleItems[0].Text, text)
}

func TestParseMultiplePipes(t *testing.T) {
	is := is.New(t)

	const text = `cloudflare | bash=/tmp/bitbar_dns_switcher_cloudflare | terminal=false | refresh=true
google | bash=/tmp/bitbar_dns_switcher_google | terminal=true | refresh=false
`
	p := &Plugin{}
	items, err := p.parseOutput(context.Background(), "optional-pipes.txt", strings.NewReader(text))
	is.NoErr(err)
	is.Equal(items.CycleItems[0].Text, "cloudflare")
	is.Equal(items.CycleItems[0].Params.Terminal, false)
	is.Equal(items.CycleItems[0].Params.Refresh, true)
	is.Equal(items.CycleItems[1].Text, "google")
	is.Equal(items.CycleItems[1].Params.Terminal, true)
	is.Equal(items.CycleItems[1].Params.Refresh, false)
}

func TestStartWithPipe(t *testing.T) {
	is := is.New(t)
	const src = `| templateImage=iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAB70lEQVR4AWJwL/ABtFsOMHfDURSft2iOjdnlvMUv1oJ5wWej/Z5ZjcEQc2YwxWOcOZoRzIid7Jzx2Uza5Jde9d7zbvuSf0NxBbgCXAEpjizLayRJega+i6L4pZqwJ3sLgrA6n4BD4BMeOAcuVJlz7M0ZOQVA4TEUnK/VutmbM/Jt4CgKLtVKAHtzRkUCcE1AnYSVbgbrCW1VVUXmai4Aw7agxgAnFEW5T2CfBAnmai6Ag0ZGRoKGYeyJRCKdhPbo6GgAAuL12ICpaZrtOE5XMrqum8hF67GBvV6vdx+uvmR8Pp/DXD02sJ+/FkM7ksFWDOT21UNAdGhoKGzb9q5k+F0gF6vHK/APDg6GLMvamczw8HCA4uqxgUBTCmCsLAGbNm2ahgcn/xFwBFws0MSXSwBykXzPsjdn0F68ePEUj8czlUEJ10GIuA4+wP6B+23c74I7hD64BZvx1z09PSY+vB3JMIaad6xhbRZu/un9AVyBncDs+X/XOhfORgR3wu7nh8ZV/yEIP0xQExUE4Ulvb28sXUBfX18UtTxL2MCBve8v8A32Ab1gG88duM8o60TE94y/nC9dAGPIWTU/kkF9f3t7+zFd14c1TRshtBnj9mouYNmyZbN4wlEU5TNW+xa8ps3YihUrZrqn4pYT4Ar4CW6NezCnH1ZyAAAAAElFTkSuQmCC`
	p := &Plugin{}
	items, err := p.parseOutput(context.Background(), "handoff.sh", strings.NewReader(src))
	is.NoErr(err)
	is.Equal(len(items.CycleItems), 1)
	is.True(items.CycleItems[0].Params.TemplateImage != "")
}

// TestTokenTooLong tests for really long tokens.
// https://github.com/matryer/xbar/issues/629
func TestTokenTooLong(t *testing.T) {
	is := is.New(t)

	f, err := os.Open(filepath.Join("testdata", "token-too-long", "jma.1h.sh.output"))
	is.NoErr(err) // os.Open
	t.Cleanup(func() {
		err := f.Close()
		is.NoErr(err) // f.Close
	})

	p := Plugin{}
	ctx := context.Background()
	items, err := p.parseOutput(ctx, "jma.1h.sh", f)
	is.NoErr(err)
	is.Equal(len(items.CycleItems), 1)
}

// TestNestedSeparators ensures separators work inside submenus.
// https://github.com/matryer/xbar/issues/648
func TestNestedSeparators(t *testing.T) {
	is := is.New(t)

	src := `a
---
b
--c
-----
--d
----e
-------
----f
-----
--g
---
h`

	p := &Plugin{}
	items, err := p.parseOutput(context.Background(), "nesting.txt", strings.NewReader(src))
	is.NoErr(err)

	is.Equal(len(items.ExpandedItems), 3)

	// root items
	is.Equal(items.ExpandedItems[0].Text, "b")
	is.Equal(items.ExpandedItems[1].Params.Separator, true)
	is.Equal(items.ExpandedItems[2].Text, "h")

	// b submenu
	is.Equal(len(items.ExpandedItems[0].Items), 5)
	is.Equal(items.ExpandedItems[0].Items[0].Text, "c")
	is.Equal(items.ExpandedItems[0].Items[1].Params.Separator, true) // should be separator
	is.Equal(items.ExpandedItems[0].Items[2].Text, "d")
	is.Equal(items.ExpandedItems[0].Items[3].Params.Separator, true)
	is.Equal(items.ExpandedItems[0].Items[4].Text, "g")

	// d submenu
	is.Equal(len(items.ExpandedItems[0].Items[2].Items), 3)
	is.Equal(items.ExpandedItems[0].Items[2].Items[0].Text, "e")
	is.Equal(items.ExpandedItems[0].Items[2].Items[1].Params.Separator, true)
	is.Equal(items.ExpandedItems[0].Items[2].Items[2].Text, "f")

}

func TestParseSeparator(t *testing.T) {
	is := is.New(t)

	text, isSep := parseSeparator("no")
	is.Equal(isSep, false)
	is.Equal(text, "no")

	text, isSep = parseSeparator(separator)
	is.Equal(isSep, true)
	is.Equal(text, "")

	text, isSep = parseSeparator(nesting + separator)
	is.Equal(isSep, true)
	is.Equal(text, nesting)

	text, isSep = parseSeparator(nesting + nesting + separator)
	is.Equal(isSep, true)
	is.Equal(text, nesting+nesting)

	text, isSep = parseSeparator(nesting + nesting + "item")
	is.Equal(isSep, false)
	is.Equal(text, nesting+nesting+"item")

}
