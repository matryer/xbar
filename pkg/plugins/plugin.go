package plugins

import (
	"bytes"
	"context"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"sync"
	"syscall"
	"time"

	"github.com/pkg/errors"
)

type (
	// RefreshFunc is a callback fired after a Plugin is refreshed.
	RefreshFunc func(ctx context.Context, p *Plugin, err error)
	// CycleFunc is a callback fired after a Plugin's CycleIndex
	// has changed.
	CycleFunc func(ctx context.Context, p *Plugin)
	// DebugFunc is a function that records debug information.
	DebugFunc func(format string, v ...interface{})
)

// Plugin is a single executable xbar plugin.
type Plugin struct {
	// Command is the excutable file that this plugin calls.
	Command string
	// Variables are the values in the accompanying .vars.json file.
	Variables []string
	// Items are the menu items for this plugin.
	Items Items
	// RefreshInterval is the duration at which this Plugin should
	// update.
	RefreshInterval RefreshInterval
	// CycleInterval is the interval at which the Items.CycleItems
	// will change.
	CycleInterval time.Duration
	// CycleIndex is the currently active Item from CycleItems.
	CycleIndex int
	// Timeout is the time.Duration within which a plugin execution
	// must complete before being cancelled.
	Timeout time.Duration
	// Debugf is a function that writes debug information.
	Debugf DebugFunc
	// OnRefresh is called when the plugin has been updated.
	// Ignored if nil.
	OnRefresh RefreshFunc
	// OnCycle is called when the Plugin's CycleIndex has changed.
	OnCycle CycleFunc

	// Stdout is a writer that will have stdout written to if not nil.
	Stdout io.Writer
	// Stderr is a writer that will have stderr written to if not nil.
	Stderr io.Writer

	// refreshSignal is a signal which will trigger the plugin to refresh.
	// Called via TriggerRefresh().
	refreshSignal chan (struct{})
	// cycleSignal is a signal channel which will trigger the plugin to
	// update its cycle.
	// Called in TriggerRefresh() when updating the plugin menu to the
	// refreshing state, before refreshSignal is triggered.
	cycleSignal chan (struct{})
}

// CleanFilename gets a clean human readable representation of the
// filename. Specifically by stripping off any 001- prefixes.
func (p Plugin) CleanFilename() string {
	fn := filepath.Base(p.Command)
	var count int
	_, _ = fmt.Sscanf(fn, "%d-%v", &count, &fn)
	return fn
}

// cycle advances the CycleIndex, and wraps around if
// we've reached the end.
func (p *Plugin) cycle(ctx context.Context) {
	p.CycleIndex++
	if p.CycleIndex == len(p.Items.CycleItems) {
		p.CycleIndex = 0
	}
	if p.OnCycle != nil {
		p.OnCycle(ctx, p)
	}
}

// Plugins are many plugins that can be executed
// synchronously.
type Plugins []*Plugin

// Run executes the plugins at regular intervals
// updating the menu items based on the output of the
// executable.
// Use the context for cancelation.
func (p Plugins) Run(ctx context.Context) {
	var wg sync.WaitGroup
	for i := range p {
		wg.Add(1)
		go func(p *Plugin) {
			p.Run(ctx)
			wg.Done()
		}(p[i])
	}
	wg.Wait()
}

// Exist checks whether a plugin exists.
func (p Plugins) Exist(path string) bool {
	filename := filepath.Base(path)
	for i := range p {
		if filename == filepath.Base(p[i].Command) {
			return true
		}
	}
	return false
}

// Dir gets Plugins from a directory.
func Dir(path string) (Plugins, error) {
	files, err := ioutil.ReadDir(path)
	if err != nil {
		return nil, err
	}
	plugins := make(Plugins, 0, len(files))
	for _, file := range files {
		filename := file.Name()
		if strings.HasPrefix(filename, ".") {
			// ignore .dot files
			continue
		}
		if file.IsDir() {
			// ignore directories
			continue
		}
		if strings.HasSuffix(filename, variableJSONFileExt) {
			// ignore .vars.json files
			continue
		}
		if !IsPluginEnabled(filename) {
			// ignore disabled plugins
			continue
		}
		command := filepath.Join(path, filename)
		plugins = append(plugins, NewPlugin(command))
	}
	return plugins, nil
}

// NewPlugin makes a new Plugin with the specified executable
// file.
func NewPlugin(command string) *Plugin {
	filename := filepath.Base(command)
	p := &Plugin{
		Timeout:       1 * time.Minute,
		CycleInterval: 5 * time.Second,
		Command:       command,
		Debugf:        DebugfNoop,
		refreshSignal: make(chan struct{}, 1),
		cycleSignal:   make(chan struct{}, 1),
	}
	var err error
	p.RefreshInterval, err = ParseFilenameInterval(filename)
	if err != nil {
		p.Debugf("failed to process interval: %s: %s (using default %v)", filename, err, defaultRefreshInterval)
		p.RefreshInterval = defaultRefreshInterval
	}
	return p
}

// Run executes the plugin at regular intervals
// updating the menu items based on the output of the
// executable.
// Use the context for cancelation.
func (p *Plugin) Run(ctx context.Context) {
	var err error
	p.Variables, err = p.loadVariablesAsEnvVars()
	if err != nil {
		p.Debugf("ERR: %s", err)
		p.OnErr(err)
	}
	p.Refresh(ctx)
	cycleReset := make(chan struct{})
	var wg sync.WaitGroup
	// cycle loop
	wg.Add(1)
	go func() {
		defer wg.Done()
		for {
			select {
			case <-cycleReset:
				// this will loop round and start the CycleInterval
				// timer again.
				p.CycleIndex = 0
				continue
			case <-p.cycleSignal:
				p.Debugf("cycling: %s", filepath.Base(p.Command))
				p.cycle(ctx)
			case <-time.After(p.CycleInterval):
				p.Debugf("cycling: %s", filepath.Base(p.Command))
				p.cycle(ctx)
			case <-ctx.Done():
				return
			}
		}
	}()
	// refresh (reexecutation) loop
	wg.Add(1)
	go func() {
		defer wg.Done()
		for {
			select {
			case <-p.refreshSignal:
				p.Debugf("refreshing: %s", filepath.Base(p.Command))
				p.Refresh(ctx)
				cycleReset <- struct{}{}
			case <-time.After(p.RefreshInterval.Duration()):
				p.Debugf("refreshing: %s", filepath.Base(p.Command))
				p.Refresh(ctx)
				cycleReset <- struct{}{}
			case <-ctx.Done():
				return
			}
		}
	}()
	wg.Wait()
	p.Debugf("finished")
}

// TriggerRefresh triggers a refresh on this Plugin.
func (p *Plugin) TriggerRefresh() {
	// disable the menu
	p.CycleIndex = 0 // reset
	// just keep the current item
	currentItem := p.CurrentCycleItem()
	//currentItem.Text = "…"
	currentItem.Params.Disabled = true
	p.Items.CycleItems = []*Item{
		currentItem,
	}
	p.CycleIndex = 0 // reset
	if p.OnCycle != nil {
		p.cycleSignal <- struct{}{}
	}
	// trigger the actual refresh
	p.refreshSignal <- struct{}{}
}

// Refresh executes and updates the Plugin.
// The menu is updated in an instant, unlike with Refresh().
// Run calls this method periodically.
func (p *Plugin) Refresh(ctx context.Context) {
	err := p.refresh(ctx)
	if err != nil {
		p.Debugf("ERR: %s", err)
		p.OnErr(err)
	}
	p.CycleIndex = 0 // reset
	if p.OnRefresh != nil {
		p.OnRefresh(ctx, p, err)
	}
}

// CurrentCycleItem returns the Item related to the current cycle.
func (p *Plugin) CurrentCycleItem() *Item {
	if len(p.Items.CycleItems) == 0 {
		return nil
	}
	if p.CycleIndex > len(p.Items.CycleItems)-1 {
		p.CycleIndex = 0
	}
	return p.Items.CycleItems[p.CycleIndex]
}

// refresh runs the plugin and parses the output, updating the
// state of Plugin.
func (p *Plugin) refresh(ctx context.Context) error {
	commandCtx, cancel := context.WithTimeout(ctx, p.Timeout)
	defer cancel()
	cmd := exec.CommandContext(commandCtx, "./"+filepath.Base(p.Command))
	cmd.SysProcAttr = &syscall.SysProcAttr{
		Setpgid: true,
	}
	cmd.Dir = filepath.Dir(p.Command)
	// inherit outside environment
	cmd.Env = append(cmd.Env, os.Environ()...)
	// add variables from .vars.json file
	cmd.Env = append(cmd.Env, p.Variables...)
	var stdout, stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr
	if p.Stdout != nil {
		cmd.Stdout = io.MultiWriter(cmd.Stdout, p.Stdout)
	}
	if p.Stderr != nil {
		cmd.Stderr = io.MultiWriter(cmd.Stderr, p.Stderr)
	}
	if err := cmd.Run(); err != nil {
		return errExec{
			err:    err,
			Stderr: stderr.String(),
		}
	}
	var err error
	p.Items, err = p.parseOutput(ctx, filepath.Base(p.Command), &stdout)
	if err != nil {
		return errors.Wrap(err, "parse stdout")
	}
	return nil
}

// OnErr is called when something has gone wrong at some point.
func (p *Plugin) OnErr(err error) {
	p.Items.CycleItems = []*Item{
		{
			Plugin: p,
			Text:   "⚠️ " + p.CleanFilename(),
		},
	}
	p.Items.ExpandedItems = p.stringToItems(err.Error())
}

// errExec is used for plugin execution errors.
type errExec struct {
	// Stderr is the data captured from stderr.
	Stderr string
	// err is the cause.
	err error
}

func (e errExec) Error() string {
	if e.Stderr != "" {
		return e.err.Error() + ": " + e.Stderr
	}
	return e.err.Error()
}

// stringToItems turns a string into one or more Item objects,
// breaking long strings down effectively wrapping them.
func (p *Plugin) stringToItems(s string) []*Item {
	var items []*Item
	for _, str := range strings.Split(s, "\n") {
		if len(strings.TrimSpace(str)) == 0 {
			// skip empty lines
			continue
		}
		items = append(items, &Item{
			Params: ItemParams{
				Dropdown: true,
			},
			Plugin: p,
			Text:   str,
		})
	}
	if strings.Contains(s, "fork/exec") && strings.Contains(s, "exec format error") {
		// add a tip
		items = append(items, &Item{
			Params: ItemParams{
				Separator: true,
			},
		})
		items = append(items, &Item{
			Params: ItemParams{
				Dropdown: true,
			},
			Plugin: p,
			Text:   "👉 Don't forget your shebang at the top of the plugin script file",
		})
	}
	if strings.Contains(s, "fork/exec") && strings.Contains(s, "permission denied") {
		// add a tip
		items = append(items, &Item{
			Params: ItemParams{
				Separator: true,
			},
		})
		items = append(items, &Item{
			Params: ItemParams{
				Dropdown: true,
			},
			Plugin: p,
			Text:   "👉 Make your script executable: chmod +x " + filepath.Base(p.Command),
		})
	}
	return items
}

// DebugfNoop is a silent DebugFunc.
func DebugfNoop(format string, v ...interface{}) {}

// DebugfLog uses log.Print to write debug information.
func DebugfLog(format string, v ...interface{}) {
	log.Printf(format, v...)
}

// DebugfPrefix wraps a DebugFunc and prepends a prefix string.
func DebugfPrefix(prefix string, debugf DebugFunc) DebugFunc {
	return func(format string, v ...interface{}) {
		s := fmt.Sprintf(format, v...)
		if len(prefix) > 0 {
			lines := strings.Split(s, "\n")
			for i := range lines {
				lines[i] = prefix + ": " + lines[i]
			}
			s = strings.Join(lines, "\n")
		}
		debugf("%s", s)
	}
}

// errParsing is used for output parsing errors.
type errParsing struct {
	filename string
	line     int
	text     string
	err      error
}

func (e *errParsing) Error() string {
	return fmt.Sprintf("%s:%d: %v", e.filename, e.line, e.err)
}
