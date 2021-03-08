# `xbar` Package

The `xbar` Go package provides the core xbar functionality.

 ## Usage

 Run all the plugins in a directory:

 ```go
func refreshFunc(ctx context.Context, p *Plugin, err error) {
    // todo: update the menu
}

func cycleFunc(ctx context.Context, p *Plugin) {
    // todo: update menu bar label
}

ps, err := plugins.Dir(filepath.Join("path", "to", "plugins"))
if err != nil {
    return err
}
for i := range ps {
    ps[i].OnRefresh = refreshFunc
    ps[i].OnCycle = cycleFunc
    ps[i].Debugf = plugins.DebugfLog
}
ctx := context.Background()
ps.Run(ctx)
```
