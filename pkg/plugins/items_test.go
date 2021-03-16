package plugins

import (
	"context"
	"strings"
	"testing"

	"github.com/matryer/is"
)

func TestParseParamStr(t *testing.T) {
	is := is.New(t)

	params := defaultParams

	// pipe separated
	err := parseParamStr(&params, strings.Join([]string{
		`href="https://xbarapp.com"`,
		`color=red`,
		`font="MyFont"`,
		`size=12`,
		`shell="script.sh"`,
		`terminal=false`,
		`refresh=true`,
		`dropdown=false`,
		`length=10`,
		`trim=false`,
		`alternate=true`,
		`templateImage="abc123"`,
		`image='abc123'`,
		`emojize=false`,
		`ansi=false`,
		`param1=parameterValue1`,
		`param2=parameterValue2`,
		`param3=parameterValue3`,
		`param4=parameterValue4`,
		`param5=parameterValue5`,
		`param6=parameterValue6`,
		`param7=parameterValue7`,
		`param8=parameterValue8`,
		`param9=parameterValue9`,
		`param10=parameterValue10`,
		`key=shift+g`,
		`disabled=true`,
	}, " | "))
	is.NoErr(err)
	is.Equal(params.Href, "https://xbarapp.com")
	is.Equal(params.Color, "#ff0000")
	is.Equal(params.Font, "MyFont")
	is.Equal(params.Shell, "script.sh")
	is.Equal(params.Terminal, false)
	is.Equal(params.Refresh, true)
	is.Equal(params.Dropdown, false)
	is.Equal(params.Length, 10)
	is.Equal(params.Trim, false)
	is.Equal(params.Alternate, true)
	is.Equal(params.TemplateImage, "abc123")
	is.Equal(params.Image, "abc123")
	is.Equal(params.Emojize, false)
	is.Equal(params.ANSI, false)
	is.Equal(params.Key, "shift+g")
	is.Equal(params.Disabled, true)
	is.Equal(len(params.ShellParams), 10)
	is.Equal(params.ShellParams[0], "parameterValue1")
	is.Equal(params.ShellParams[1], "parameterValue2")
	is.Equal(params.ShellParams[2], "parameterValue3")
	is.Equal(params.ShellParams[3], "parameterValue4")
	is.Equal(params.ShellParams[4], "parameterValue5")
	is.Equal(params.ShellParams[5], "parameterValue6")
	is.Equal(params.ShellParams[6], "parameterValue7")
	is.Equal(params.ShellParams[7], "parameterValue8")
	is.Equal(params.ShellParams[8], "parameterValue9")
	is.Equal(params.ShellParams[9], "parameterValue10")

	// space separator
	err = parseParamStr(&params, strings.Join([]string{
		`href="https://xbarapp.com"`,
		`color=red`,
		`font="MyFont"`,
	}, " "))
	is.NoErr(err)
	is.Equal(params.Href, "https://xbarapp.com")
	is.Equal(params.Color, "#ff0000")
	is.Equal(params.Font, "MyFont")

	// tight pipe separator
	err = parseParamStr(&params, `|href="https://xbarapp.com"|color=red|font="MyFont"`)
	is.NoErr(err)
	is.Equal(params.Href, "https://xbarapp.com")
	is.Equal(params.Color, "#ff0000")
	is.Equal(params.Font, "MyFont")

	// bash should work as well as shell
	params = defaultParams
	err = parseParamStr(&params, strings.Join([]string{
		"bash=script.sh",
	}, " "))
	is.NoErr(err)
	is.Equal(params.Shell, "script.sh")
}

// TestLength tests the length truncation parameter.
func TestLength(t *testing.T) {
	is := is.New(t)

	item := Item{
		Text: strings.Repeat("x", 20),
		Params: ItemParams{
			Length: 10,
		},
	}
	displayText := item.DisplayText()
	is.Equal(displayText, "xxxxxxxxx…")

	item = Item{
		Text: strings.Repeat("x", 20),
		Params: ItemParams{
			Length: 30,
		},
	}
	displayText = item.DisplayText()
	is.Equal(displayText, strings.Repeat("x", 20))
}

// TestDropdown excludes dropdown=false entries from the dropdown.
func TestDropdown(t *testing.T) {
	is := is.New(t)

	ctx := context.Background()
	p := &Plugin{}
	items, err := p.parseOutput(ctx, "test.txt", strings.NewReader(strings.TrimSpace(`
	
cycle1
cycle2
cycle3
---
yes1
no | dropdown=false
yes2

	`)))
	is.NoErr(err)
	is.Equal(len(items.CycleItems), 3)    // CycleItems
	is.Equal(len(items.ExpandedItems), 2) // ExpandedItems
	is.Equal(items.ExpandedItems[0].Text, "yes1")
	is.Equal(items.ExpandedItems[1].Text, "yes2")
}

func TestAlternate(t *testing.T) {
	is := is.New(t)

	ctx := context.Background()
	p := &Plugin{}
	items, err := p.parseOutput(ctx, "test.txt", strings.NewReader(strings.TrimSpace(`
	
cycle1
cycle2
cycle3
---
before1
after1 | alternate=true
before2
before3 | alternate=false

	`)))
	is.NoErr(err)
	is.Equal(len(items.CycleItems), 3)    // CycleItems
	is.Equal(len(items.ExpandedItems), 3) // ExpandedItems
	is.Equal(items.ExpandedItems[0].Text, "before1")
	is.True(items.ExpandedItems[0].Alternate != nil)          // should be alternate
	is.Equal(items.ExpandedItems[0].Alternate.Text, "after1") // after text
	is.Equal(items.ExpandedItems[1].Text, "before2")
	is.Equal(items.ExpandedItems[2].Text, "before3")
}

func TestTrim(t *testing.T) {
	is := is.New(t)

	ctx := context.Background()
	p := &Plugin{}
	items, err := p.parseOutput(ctx, "test.txt", strings.NewReader(strings.TrimSpace(`
	
		cycle1 | trim=true
     cycle2 | trim=false
	  	  cycle3	
	`)))
	is.NoErr(err)
	is.Equal(len(items.CycleItems), 3) // CycleItems
	is.Equal(items.CycleItems[0].Text, `cycle1`)
	is.Equal(items.CycleItems[1].Text, `     cycle2 `)
	is.Equal(items.CycleItems[2].Text, `cycle3`)
}

func TestSeparator(t *testing.T) {
	is := is.New(t)

	ctx := context.Background()
	p := &Plugin{}
	items, err := p.parseOutput(ctx, "test.txt", strings.NewReader(strings.TrimSpace(`
cycle1 | trim=true
cycle2 | trim=false
cycle
---
one
---
two
---
three`)))
	is.NoErr(err)
	is.Equal(len(items.CycleItems), 3)    // CycleItems
	is.Equal(len(items.ExpandedItems), 5) // ExtendedItems
	is.Equal(items.ExpandedItems[1].Params.Separator, true)
	is.Equal(items.ExpandedItems[3].Params.Separator, true)

}

func TestBlankLines(t *testing.T) {
	is := is.New(t)
	ctx := context.Background()
	p := &Plugin{}
	items, err := p.parseOutput(ctx, "test.txt", strings.NewReader(strings.TrimSpace(`
items
---
one

two

three
`)))
	is.NoErr(err)
	is.Equal(len(items.CycleItems), 1)
	is.Equal(len(items.ExpandedItems), 5)
	//is.Equal(items.ExpandedItems[1].Params.Size, 5) // items.ExpandedItems[1].Params.Size
}

func TestErrors(t *testing.T) {
	is := is.New(t)

	ctx := context.Background()
	p := &Plugin{}
	items, err := p.parseOutput(ctx, "test.txt", strings.NewReader(strings.TrimSpace(`

Click me | href=

	`)))
	is.NoErr(err)
	is.Equal(len(items.CycleItems), 1)

	items, err = p.parseOutput(ctx, "test.txt", strings.NewReader(strings.TrimSpace(`
		Go to
		---
		Open | href="https://xbarapp.com"
	`)))
	is.NoErr(err)
	is.Equal(len(items.ExpandedItems), 1)
	is.Equal(items.ExpandedItems[0].Text, "Open")
	is.Equal(items.ExpandedItems[0].Params.Href, "https://xbarapp.com")

}

func TestTruncate(t *testing.T) {
	is := is.New(t)
	const maxLen = 10
	for input, expected := range map[string]string{
		"basic characters":   "basic cha…",
		"På tide å logge av": "På tide å…",
	} {
		is.Equal(truncate(input, maxLen), expected)
	}
}

func TestGoodColors(t *testing.T) {
	is := is.New(t)

	ctx := context.Background()
	p := &Plugin{}
	items, err := p.parseOutput(ctx, "colors.txt", strings.NewReader(strings.TrimSpace(`
	named | color=red
	RGB | color=#333
	RGBA | color=#3338
	RRGGBB | color=#333333
	RRGGBBAA | color=#33333388
	darkviolet | color=DarkViolet
	`)))
	is.NoErr(err)
	is.Equal(len(items.CycleItems), 6) // CycleItems
	is.Equal(items.CycleItems[0].Params.Color, `#ff0000`)
	is.Equal(items.CycleItems[1].Params.Color, `#333`)
	is.Equal(items.CycleItems[2].Params.Color, `#3338`)
	is.Equal(items.CycleItems[3].Params.Color, `#333333`)
	is.Equal(items.CycleItems[4].Params.Color, `#33333388`)
	is.Equal(items.CycleItems[5].Params.Color, `#9400d3`)
}

func TestBadColors(t *testing.T) {
	is := is.New(t)

	ctx := context.Background()
	cols := map[string]string{
		``:         "colors.txt:1: color: expected hex string or named color",
		`""`:       "colors.txt:1: color: expected hex string or named color",
		`#`:        "colors.txt:1: color: invalid hex format \"#\"",
		`#fmty`:    "colors.txt:1: color: invalid hex format \"#fmty\"",
		`badname`:  "colors.txt:1: color: invalid named color \"badname\"",
		`#12`:      "colors.txt:1: color: invalid hex format \"#12\"",
		`#12345`:   "colors.txt:1: color: invalid hex format \"#12345\"",
		`#1234567`: "colors.txt:1: color: invalid hex format \"#1234567\"",
	}
	for col, errorMessage := range cols {
		t.Run(col, func(t *testing.T) {
			is := is.New(t)
			p := &Plugin{}
			_, err := p.parseOutput(ctx, "colors.txt", strings.NewReader(strings.TrimSpace(`
bad | color=`+col)))
			is.True(err != nil)
			is.Equal(err.Error(), errorMessage)
		})
	}
}

/**

 */
