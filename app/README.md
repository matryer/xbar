# xbar

Put anything into your macOS menu bar (sequel to BitBar)
 
## Development

To build xbar, you will need:

  * Go v1.15+
  * npm v6.14.9
  * Wails v2 cli - `go install github.com/wailsapp/wails/v2/cmd/wails@v2.0.0-alpha.72`

### Running

If running for the first time first generate the `.version` file and install the npm dependencies by running: 

```bash
cd app && git describe --tags > .version 
```

and 

```bash
cd app/frontend && npm install
```

To start the application run:

```bash
cd app/frontend && npm run dev
```

and

```bash
cd app && wails dev
```

### Building

In this directory run `./build.sh`. The binary will be generated in `./build/darwin/desktop/`.

```bash
./build.sh && ./build/bin/xbar
```

### Updates

To use the latest version of the Wails library, ensure that go.mod is using the latest release tag.
The Wails CLI may be updated by running `wails update -pre`. When v2 is released, then `wails update` will keep you 
on the stable channel.

### Packaging

Tag the branch:

```bash
git tag -a v0.1.0 -m "release tag."
git push origin v0.1.0
```

```bash
./package.sh
```

* For code signing, xbar uses https://github.com/matryer/gon (fork of https://github.com/mitchellh/gon) 
