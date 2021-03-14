# xbar

Put anything into your macOS menu bar (sequel to BitBar)
 
## Development

To build xbar, you will need:

  * Go v1.15+
  * npm v6.14.9
  * Wails v2 cli - `go get github.com/wailsapp/wails/v2/cmd/wails`

### Running

```bash
cd app && wails dev
```

and

```
cd app/frontend && npm run dev
```

### Building

In this directory run `./build.sh`. The binary will be generated in `./build/darwin/desktop/`.

```bash
./build.sh && ./build/darwin/desktop/xbar
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

* You will need `npm install --global create-dmg` see https://github.com/sindresorhus/create-dmg
* You will need `brew install graphicsmagick imagemagick`
