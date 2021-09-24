package plugins

import (
	"bufio"
	"context"
	"io"
	"strings"

	"github.com/pkg/errors"
)

const (
	nesting   = "--"
	separator = "---"
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
	)
	scanner := bufio.NewScanner(r)
	for scanner.Scan() {
		line++
		text = scanner.Text()
		text, params, err = parseParams(text)
		if err != nil {
			return items, &errParsing{
				filename: filename,
				line:     line,
				text:     text,
				err:      err,
			}
		}
		if !captureExpanded && strings.TrimSpace(text) == separator {
			// first --- means end of cycle items,
			// start collecting expanded items now
			captureExpanded = true
			continue
		}

		text, isSeparator := parseSeparator(text)

		for !strings.HasPrefix(text, depthPrefix) {
			// drop a level
			ancestorItems = ancestorItems[:len(ancestorItems)-1]
			depthPrefix = strings.TrimPrefix(depthPrefix, nesting)
		}
		if strings.HasPrefix(text, depthPrefix+nesting) {
			// if this is a separator in the submenu,
			// then don't treat it as a another submenu.
			if strings.TrimPrefix(text, depthPrefix) != separator {
				// increase a level
				ancestorItems = append(ancestorItems, previousItem)
				depthPrefix += nesting
			}
		}
		text = strings.TrimPrefix(text, depthPrefix)
		if captureExpanded && isSeparator {
			params.Separator = true
			separatorItem := &Item{
				Plugin: p,
				Text:   text,
				Params: params,
			}
			if len(ancestorItems) > 0 {
				parentItem := ancestorItems[len(ancestorItems)-1]
				parentItem.Items = append(parentItem.Items, separatorItem)
			} else {
				items.ExpandedItems = append(items.ExpandedItems, separatorItem)
			}
			continue
		}
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
	if err := scanner.Err(); err != nil {
		return items, errors.Wrap(err, "reading")
	}
	if err != nil && err != io.EOF {
		return items, errors.Wrap(err, "reading")
	}
	return items, nil
}

func parseSeparator(src string) (string, bool) {
	text := strings.TrimSpace(src)
	if text == separator {
		return "", true
	}
	for strings.HasPrefix(text, nesting) {
		text = strings.TrimPrefix(text, nesting)
		if text == separator {
			return src[:len(src)-3], true
		}
	}
	return src, false
}
