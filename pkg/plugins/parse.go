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
	var (
		items           Items
		params          ItemParams
		depthPrefix     string
		previousItem    *Item
		ancestorItems   []*Item
		captureExpanded bool
		line            int
		text            string
		err             error
		readErr         error
	)
	br := bufio.NewReader(r)
	for readErr == nil { // keep reading until we hit io.EOF
		line++
		text, readErr = br.ReadString('\n')
		if readErr != nil && readErr != io.EOF {
			// some other error reading (io.EOF is fine)
			break
		}
		if readErr == io.EOF && text == "" {
			// io.EOF and no text - looks like were done.
			break
		}
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
			//blankLineItem.Params.Size = 5
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
				if item.Params.Alternate {
					// add to previous item, as Alternate
					previousItem.Alternate = item
				} else if item.Params.Dropdown {
					// if Dropdown=false then don't include it
					items.ExpandedItems = append(items.ExpandedItems, item)
				}
			}
		} else {
			items.CycleItems = append(items.CycleItems, item)
		}
		previousItem = item
	}
	if err != nil && err != io.EOF {
		return items, errors.Wrap(err, "reading")
	}
	return items, nil
}
