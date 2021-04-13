package main

import (
	"context"
	"encoding/json"
	"testing"
	"time"

	"github.com/matryer/is"
	"github.com/matryer/xbar/pkg/plugins"
	"github.com/wailsapp/wails/v2/pkg/menu"
)

func TestMenuParser(t *testing.T) {
	is := is.New(t)

	ctx := context.Background()
	ctx, cancel := context.WithTimeout(ctx, 1*time.Second)
	defer cancel()

	items := []*plugins.Item{
		{
			Text: "one",
			Items: []*plugins.Item{
				{Text: "sub1"},
				{Text: "sub2"},
				{Text: "sub3"},
			},
		},
		{
			Text: "two",
			Params: plugins.ItemParams{
				Font: "Courier New",
				Size: 26,
				Key:  "CmdOrCtrl+Shift+K",
			},
		},
		{
			Text: "three",
		},
		{
			Text: "four",
			Params: plugins.ItemParams{
				Href: "https://xbarapp.com",
			},
		},
		{
			Text: "five",
			Params: plugins.ItemParams{
				Shell:       "echo",
				ShellParams: []string{"hi"},
			},
		},
		{
			Text: "six",
			Params: plugins.ItemParams{
				Refresh: true,
			},
		},
		{
			Text: "seven but this will be truncated",
			Params: plugins.ItemParams{
				Refresh: true,
				Length:  5,
			},
		},
		{
			Text: "Template Image",
			Params: plugins.ItemParams{
				TemplateImage: "base64stuff",
			},
		},
		{
			Text: "Non Alternate",
			Alternate: &plugins.Item{
				Text: "Alternate",
				Params: plugins.ItemParams{
					Alternate: true,
				},
			},
		},
		{
			Text: "\033[0;38;2;255;0;0mA\033[0;38;2;255;127;0mN\033[0;38;2;255;255;0mS\033[0;38;2;0;255;0mI\u001B[0m",
			Params: plugins.ItemParams{
				Refresh: true,
			},
		},
	}
	menuitems := NewMenuParser().ParseItems(ctx, items)

	is.Equal(len(menuitems.Items), 11) // len(menuitems.Items)

	is.Equal(menuitems.Items[0].Label, "one")
	is.Equal(menuitems.Items[0].Disabled, false)
	is.True(menuitems.Items[0].SubMenu != nil)
	is.Equal(len(menuitems.Items[0].SubMenu.Items), 3)

	is.Equal(menuitems.Items[1].Label, "two")
	is.Equal(menuitems.Items[1].Disabled, true)
	is.Equal(menuitems.Items[1].FontName, "Courier New")
	is.Equal(menuitems.Items[1].FontSize, 26)
	is.True(menuitems.Items[1].Accelerator != nil)
	is.Equal(menuitems.Items[1].Accelerator.Key, "k")
	is.Equal(len(menuitems.Items[1].Accelerator.Modifiers), 2) // len(modifiers)

	is.Equal(menuitems.Items[2].Label, "three")
	is.Equal(menuitems.Items[2].Disabled, true)

	is.Equal(menuitems.Items[3].Label, "four")
	is.Equal(menuitems.Items[3].Disabled, false)

	is.Equal(menuitems.Items[4].Label, "five")
	is.Equal(menuitems.Items[4].Disabled, false)

	is.Equal(menuitems.Items[5].Label, "six")
	is.Equal(menuitems.Items[5].Disabled, false)

	is.Equal(menuitems.Items[6].Label, "seve…")
	is.Equal(menuitems.Items[6].Tooltip, "seven but this will be truncated")

	is.Equal(menuitems.Items[7].Label, "Template Image")
	is.Equal(menuitems.Items[7].Image, "base64stuff")
	//is.Equal(menuitems.Items[7].MacTemplateImage, true)

	is.Equal(menuitems.Items[8].Label, "Non Alternate")
	is.Equal(menuitems.Items[9].Label, "Alternate")
	is.Equal(menuitems.Items[9].MacAlternate, true)

	is.Equal(menuitems.Items[10].Tooltip, "ANSI")
}

func JSON(menu *menu.Menu, is *is.I) string {
	data, err := json.Marshal(menu)
	is.NoErr(err)
	return string(data)
}
