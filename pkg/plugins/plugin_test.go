package plugins

import (
	"context"
	"path/filepath"
	"strings"
	"sync"
	"testing"
	"time"

	"github.com/matryer/is"
	"github.com/pkg/errors"
)

func TestRun(t *testing.T) {
	is := is.New(t)

	plugins, err := Dir(filepath.Join("testdata", "plugins"))
	is.NoErr(err)

	var lock sync.Mutex // protects counters
	var counters struct {
		cycles    int
		refreshes int
	}

	for i := range plugins {
		plugins[i].Timeout = 2 * time.Second
		plugins[i].Debugf = func(format string, v ...interface{}) { /* silent */ }
		plugins[i].CycleInterval = 100 * time.Millisecond
		plugins[i].RefreshInterval = RefreshInterval{N: 250, Unit: "milliseconds"}
		plugins[i].OnRefresh = func(ctx context.Context, p *Plugin, err error) {
			lock.Lock()
			counters.refreshes++
			lock.Unlock()
		}
		plugins[i].OnCycle = func(ctx context.Context, p *Plugin) {
			lock.Lock()
			counters.cycles++
			lock.Unlock()
		}
		// plugin := plugins[i]
		// plugins[i].Debugf = func(format string, v ...interface{}) {
		// 	log.Printf(filepath.Base(plugin.Command)+": "+format, v...)
		// }
	}

	ctx, cancel := context.WithTimeout(context.Background(), 1*time.Second)
	defer cancel()

	plugins.Run(ctx)

	is.True(counters.refreshes > 10)
	is.True(counters.cycles > 20)
	is.True(counters.cycles > counters.refreshes)

}

func TestRunStderr(t *testing.T) {
	is := is.New(t)

	ps, err := Dir(filepath.Join("testdata", "broken-plugins"))
	is.NoErr(err)

	ctx, cancel := context.WithTimeout(context.Background(), 1*time.Second)
	t.Cleanup(cancel)
	ps[0].Run(ctx)

	is.Equal(ps[0].Items.CycleItems[0].Text, "⚠️ broken.1m.sh")
	is.Equal(ps[0].Items.ExpandedItems[0].Text, "exit status 1: an error printed to stderr")
}

func TestPluginsDir(t *testing.T) {
	is := is.New(t)

	plugins, err := Dir(filepath.Join("testdata", "plugins"))
	is.NoErr(err)
	is.Equal(len(plugins), 8)
}

func TestPluginsExist(t *testing.T) {
	is := is.New(t)

	plugins, err := Dir(filepath.Join("testdata", "plugins"))
	is.NoErr(err)

	is.Equal(plugins.Exist("simple.1s.sh"), true)
	is.Equal(plugins.Exist("missing.1s.sh"), false)
}

func TestPluginOnRefresh(t *testing.T) {
	is := is.New(t)
	ctx := context.Background()
	ctx, cancel := context.WithTimeout(ctx, 1*time.Second)
	defer cancel()
	p := NewPlugin(filepath.Join("testdata", "plugins", "simple.1s.sh"))
	OnRefreshCalls := 0
	p.OnRefresh = func(refreshCtx context.Context, plugin *Plugin, err error) {
		is.NoErr(err)             // err
		is.Equal(ctx, refreshCtx) // ctx
		is.Equal(p, plugin)       // plugin
		OnRefreshCalls++
		is.Equal(p.CycleIndex, 0) // CycleIndex should get reset
	}
	is.Equal(p.RefreshInterval.Duration(), 1*time.Second)
	p.CycleIndex = 1
	p.Refresh(ctx)
	is.Equal(OnRefreshCalls, 1) // OnRefreshCalls
}

func TestPluginSimple(t *testing.T) {
	is := is.New(t)
	ctx := context.Background()
	ctx, cancel := context.WithTimeout(ctx, 1*time.Second)
	defer cancel()
	p := NewPlugin(filepath.Join("testdata", "plugins", "simple.1s.sh"))
	is.Equal(p.RefreshInterval.Duration(), 1*time.Second)
	p.Refresh(ctx)
	is.Equal(len(p.Items.CycleItems), 3)
	is.Equal(p.Items.CycleItems[0].Text, "one")
	is.Equal(p.Items.CycleItems[1].Text, "two")
	is.Equal(p.Items.CycleItems[2].Text, "three")
	is.Equal(len(p.Items.ExpandedItems), 0)
}

func TestPluginExpanded(t *testing.T) {
	is := is.New(t)
	ctx := context.Background()
	ctx, cancel := context.WithTimeout(ctx, 1*time.Second)
	defer cancel()
	p := NewPlugin(filepath.Join("testdata", "plugins", "expanded.1s.sh"))
	is.Equal(p.RefreshInterval.Duration(), 1*time.Second)
	p.Refresh(ctx)

	is.Equal(len(p.Items.CycleItems), 3)
	is.Equal(p.Items.CycleItems[0].Text, "one")
	is.Equal(p.Items.CycleItems[1].Text, "two")
	is.Equal(p.Items.CycleItems[2].Text, "three")
	is.Equal(len(p.Items.ExpandedItems), 3)
	is.Equal(p.Items.ExpandedItems[0].Text, "four")
	is.Equal(p.Items.ExpandedItems[1].Text, "five")
	is.Equal(p.Items.ExpandedItems[2].Text, "six")
}

func TestCycleItems(t *testing.T) {
	is := is.New(t)

	onCycleCalls := 0
	ctx := context.Background()

	p := &Plugin{
		OnCycle: func(ctx context.Context, p *Plugin) {
			onCycleCalls++
		},
	}
	p.Items = Items{
		CycleItems: []*Item{ // three items
			{
				Text:   "1",
				Plugin: p,
			},
			{
				Text:   "2",
				Plugin: p,
			},
			{
				Text:   "3",
				Plugin: p,
			},
		},
	}
	is.Equal(p.CycleIndex, 0) // default CycleIndex
	is.Equal(p.CurrentCycleItem().Text, "1")
	p.cycle(ctx)
	is.Equal(p.CycleIndex, 1) // CycleIndex
	is.Equal(onCycleCalls, 1) // onCycleCalls
	is.Equal(p.CurrentCycleItem().Text, "2")

	p.cycle(ctx)
	is.Equal(p.CycleIndex, 2) // CycleIndex
	is.Equal(onCycleCalls, 2) // onCycleCalls
	is.Equal(p.CurrentCycleItem().Text, "3")

	p.cycle(ctx)
	is.Equal(p.CycleIndex, 0) // CycleIndex
	is.Equal(onCycleCalls, 3) // onCycleCalls
	is.Equal(p.CurrentCycleItem().Text, "1")

	p.cycle(ctx)
	is.Equal(p.CycleIndex, 1) // CycleIndex
	is.Equal(onCycleCalls, 4) // onCycleCalls
	is.Equal(p.CurrentCycleItem().Text, "2")

	p.cycle(ctx)
	is.Equal(p.CycleIndex, 2) // CycleIndex
	is.Equal(onCycleCalls, 5) // onCycleCalls
	is.Equal(p.CurrentCycleItem().Text, "3")

	// go out of range - can happen if refreshed while
	// cycling
	p.CycleIndex = 5
	is.Equal(p.CurrentCycleItem().Text, "1") // should revert to first one

}

func TestSubmenus(t *testing.T) {
	is := is.New(t)

	p := &Plugin{}
	items, err := p.parseOutput(context.Background(), "text.txt", strings.NewReader(strings.TrimSpace(`
cycle1
cycle2
cycle3
---
parent1
--child1
--child2
--child3
----subchild1
----subchild2
------subsubchild1
--child4
parent2
--child1
--child2
--child3
parent3
`)))
	is.NoErr(err)
	is.Equal(len(items.ExpandedItems), 3) // 3 parent items
	is.Equal(items.ExpandedItems[0].Text, "parent1")
	is.Equal(len(items.ExpandedItems[0].Items), 4)
	is.Equal(items.ExpandedItems[0].Items[0].Text, "child1")
	is.Equal(items.ExpandedItems[0].Items[1].Text, "child2")
	is.Equal(items.ExpandedItems[0].Items[2].Text, "child3")
	is.Equal(len(items.ExpandedItems[0].Items[2].Items), 2)
	is.Equal(items.ExpandedItems[0].Items[2].Items[0].Text, "subchild1")
	is.Equal(items.ExpandedItems[0].Items[2].Items[1].Text, "subchild2")
	is.Equal(items.ExpandedItems[0].Items[3].Text, "child4")
	is.Equal(items.ExpandedItems[1].Text, "parent2")
	is.Equal(len(items.ExpandedItems[1].Items), 3)
	is.Equal(items.ExpandedItems[1].Items[0].Text, "child1")
	is.Equal(items.ExpandedItems[1].Items[1].Text, "child2")
	is.Equal(items.ExpandedItems[1].Items[2].Text, "child3")
	is.Equal(items.ExpandedItems[2].Text, "parent3")
	is.Equal(len(items.ExpandedItems[2].Items), 0)
}

func TestOnErr(t *testing.T) {
	is := is.New(t)

	p := &Plugin{}
	err := errors.New(`this is a very long item,
it contains lots of lines.
It also contains a very long line which should be wrapped, because otherwise it will result in a very long menu item that will be impossible to read`)
	p.OnErr(err)

	var s string
	for i := range p.Items.ExpandedItems {
		s += p.Items.ExpandedItems[i].Text + "\n"
	}

	is.Equal(len(p.Items.ExpandedItems), 3)

}
func TestCleanFilename(t *testing.T) {
	is := is.New(t)

	p := Plugin{
		Command: "/path/to/001-file.2m.sh",
	}
	is.Equal(p.CleanFilename(), "file.2m.sh")

	p = Plugin{
		Command: "/path/to/file.2m.sh",
	}
	is.Equal(p.CleanFilename(), "file.2m.sh")

	p = Plugin{
		Command: "file.sh",
	}
	is.Equal(p.CleanFilename(), "file.sh")

}

// TestPluginWontQuit tests to see if plugins that ignore the signal
// still end up refreshing. Turns out they do because we're using exec.CommandContext.
func TestPluginWontQuit(t *testing.T) {
	p := Plugin{
		Debugf:  t.Logf,
		Command: filepath.Join("testdata", "broken-plugins", "wont-quit.1m.sh"),
	}
	ctx := context.Background()
	ctx, cancel := context.WithTimeout(ctx, 1*time.Second)
	t.Cleanup(func() {
		cancel()
	})
	p.Refresh(ctx)
	p.Refresh(ctx)
	p.Refresh(ctx)
}

func TestVariablesEnvString(t *testing.T) {
	is := is.New(t)

	vars := []string{
		"one=1",
		"two=2",
		"spaces=I have spaces",
		"malformed",
	}

	s := variablesEnvString(vars)
	is.Equal(s, `one="1" two="2" spaces="I have spaces"`)

}
