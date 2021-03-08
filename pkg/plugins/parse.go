package plugins

import (
	"bufio"
	"context"
	"io"
	"strings"

	"github.com/pkg/errors"
)

// parseOutput parses the output of a plugin run, and returns the
// Items.
func (p *Plugin) parseOutput(ctx context.Context, filename string, r io.Reader) (Items, error) {
	var items Items
	var params ItemParams
	var depthPrefix string
	var previousItem *Item
	var ancestorItems []*Item
	var err error
	line := 0
	src := bufio.NewScanner(r)
	captureExpanded := false
	for src.Scan() {
		line++
		text := src.Text()
		trimmedText := strings.TrimSpace(text)
		text, params, err = parseParams(text)
		if err != nil {
			return items, &errParsing{
				filename: filename,
				line:     line,
				text:     text,
				err:      err,
			}
		}
		if !captureExpanded && trimmedText == "---" {
			// first --- means end of cycle items,
			// start collecting expanded items now
			captureExpanded = true
			continue
		}
		if captureExpanded && trimmedText == "---" {
			// subsequent --- is a separator
			params.Separator = true
			separatorItem := &Item{
				Plugin: p,
				Text:   text,
				Params: params,
			}
			items.ExpandedItems = append(items.ExpandedItems, separatorItem)
			continue
		}
		if captureExpanded && trimmedText == "" {
			// empty lines should be smaller
			blankLineItem := &Item{
				Plugin: p,
				Text:   " ",
				Params: params,
			}
			blankLineItem.Params.Size = 5
			items.ExpandedItems = append(items.ExpandedItems, blankLineItem)
			continue
		}
		for !strings.HasPrefix(text, depthPrefix) {
			// drop a level
			ancestorItems = ancestorItems[:len(ancestorItems)-1]
			depthPrefix = strings.TrimPrefix(depthPrefix, "--")
		}
		if strings.HasPrefix(text, depthPrefix+"--") {
			// increase a level
			ancestorItems = append(ancestorItems, previousItem)
			depthPrefix += "--"
		}
		text = strings.TrimPrefix(text, depthPrefix)
		if params.Trim {
			text = strings.TrimSpace(text)
		}
		if params.Emojize {
			text = Emojize(text)
		}
		item := &Item{
			Plugin: p,
			Text:   text,
			Params: params,
		}
		if captureExpanded {
			if len(ancestorItems) > 0 {
				parentItem := ancestorItems[len(ancestorItems)-1]
				parentItem.Items = append(parentItem.Items, item)
			} else {
				if item.Params.Alternate == true {
					// add to previous item, as Alternate
					previousItem.Alternate = item
				} else if item.Params.Dropdown == true {
					// if Dropdown=false then don't include it
					items.ExpandedItems = append(items.ExpandedItems, item)
				}
			}
		} else {
			items.CycleItems = append(items.CycleItems, item)
		}
		previousItem = item
	}
	if err := src.Err(); err != nil {
		return items, errors.Wrap(err, "scanning")
	}
	return items, nil
}
