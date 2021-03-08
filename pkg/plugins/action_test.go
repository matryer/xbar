package plugins

import (
	"context"
	"testing"

	"github.com/matryer/is"
)

func OffTestItemAction(t *testing.T) {
	is := is.New(t)

	// work in progress

	// action is called when the item is
	// clicked
	var action ActionFunc

	item := Item{
		Text:   "Item",
		Params: ItemParams{},
	}
	action = item.Action()
	is.True(action == nil)

	item = Item{
		Text: "Item",
		Params: ItemParams{
			Href: "https://xbarapp.com",
		},
	}
	action = item.Action()
	action(context.Background())

	item = Item{
		Text: "Item",
		Params: ItemParams{
			Shell: `echo \"hello\"`,
		},
	}
	action = item.Action()
	action(context.Background())

	item = Item{
		Text: "Item",
		Params: ItemParams{
			Refresh: true,
		},
	}
	action = item.Action()
	action(context.Background())

}

func TestTerminal(t *testing.T) {
	p := NewPlugin("/dev/null")
	p.Debugf = DebugfLog
	item := Item{
		Plugin: p,
		Text:   "Item",
		Params: ItemParams{
			Terminal:    true,
			Shell:       `echo \"hello\"`,
			ShellParams: []string{},
		},
	}
	action := item.Action()
	action(context.Background())
}
