# xbar sitegen

This tool generates the xbar website by mixing the plugin data from the
github.com/matryer/xbar-plugins repo with the templates.

## Before you run this

You should probably go to `../xbarapp.com` and update the CSS:

```bash
npm run build
```

* See the README in that folder for more information

## To run

```bash
go build -o sitegen && XBAR_GITHUB_ACCESS_TOKEN=xxx ./sitegen -small && cd ../../xbarapp.com && npm run build
```

* Remove `-small` flag to process all plugins
* GitHub may rate limit if you use this tool too much
