package main

import (
	"context"
	"fmt"
	"strconv"

	"github.com/leaanthony/go-ansi-parser"
	"github.com/matryer/xbar/pkg/plugins"
	"github.com/wailsapp/wails/v2/pkg/menu"
	"github.com/wailsapp/wails/v2/pkg/menu/keys"
)

// MenuParser translates xbar items into Wails menu items.
type MenuParser struct{}

// NewMenuParser makes a new MenuParser.
func NewMenuParser() *MenuParser {
	return &MenuParser{}
}

// ParseItems parses the items, returning the new menu.
func (m MenuParser) ParseItems(ctx context.Context, items []*plugins.Item) *menu.Menu {
	if len(items) == 0 {
		return nil
	}
	theMenu := menu.NewMenu()
	for _, item := range items {
		if item.Params.Separator {
			theMenu.Append(menu.Separator())
			continue
		}
		menuItem := m.ParseMenuItem(ctx, item)
		theMenu.Append(menuItem)
		if item.Alternate != nil {
			menuItem = m.ParseMenuItem(ctx, item.Alternate)
			theMenu.Append(menuItem)
		}
	}
	return theMenu
}

// ParseMenuItem parses a single item, returning the new menu.
func (m MenuParser) ParseMenuItem(ctx context.Context, item *plugins.Item) *menu.MenuItem {
	var err error
	displayText := item.DisplayText()
	itemAction := item.Action()
	menuItem := menu.Text(displayText, nil, func(_ *menu.CallbackData) {
		if itemAction == nil {
			return
		}
		itemAction(ctx)
	})
	if item.Text != displayText {
		tooltip := item.Text
		if item.Params.ANSI {
			tooltip, err = strconv.Unquote(`"` + tooltip + `"`)
			if err != nil {
				tooltip = item.Text
			}
		}
		if ansi.HasEscapeCodes(tooltip) {
			menuItem.Tooltip, err = ansi.Cleanse(tooltip)
			if err != nil {
				menuItem.Tooltip = err.Error()
			}
		} else {
			menuItem.Tooltip = tooltip
		}
	}
	if item.Params.Key != "" {
		acc, err := keys.Parse(item.Params.Key)
		if err != nil {
			// show the error in the menu
			menuItem.Label = fmt.Sprintf("error: %s", err)
		}
		menuItem.Accelerator = acc
	}
	menuItem.Image = item.Params.Image
	menuItem.FontName = item.Params.Font
	menuItem.FontSize = item.Params.Size
	menuItem.RGBA = item.Params.Color
	// Check for template image
	if item.Params.TemplateImage != "" {
		menuItem.Image = item.Params.TemplateImage
		// get template images working on all macOS versions
		menuItem.MacTemplateImage = true
	}
	menuItem.MacAlternate = item.Params.Alternate
	if item.Params.Dropdown == false {
		menuItem.Hidden = true
	}
	if len(item.Items) > 0 { // subitems
		menuItem.SubMenu = m.ParseItems(ctx, item.Items)
	}
	if itemAction == nil && menuItem.SubMenu == nil {
		// no action and no submenu, disable it.
		menuItem.Disabled = true
	}
	if item.Params.Disabled {
		// explicitly disabled
		menuItem.Disabled = true
	}
	return menuItem
}
