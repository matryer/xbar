[![npm][npm]][npm-url]
[![node][node]][node-url]
[![Greenkeeper badge](https://badges.greenkeeper.io/postcss/postcss-cli.svg)](https://greenkeeper.io/)
[![tests][tests]][tests-url]
[![cover][cover]][cover-url]
[![chat][chat]][chat-url]

<div align="center">
  <img width="100" height="100" title="CLI" src="https://raw.githubusercontent.com/postcss/postcss-cli/HEAD/logo.svg">
  <a href="https://github.com/postcss/postcss">
    <img width="110" height="110" title="PostCSS" src="http://postcss.github.io/postcss/logo.svg" hspace="10">
  </a>
  <h1>PostCSS CLI</h1>
</div>

<h2 align="center">Install</h2>

```bash
npm i -D postcss postcss-cli
```

<h2 align="center">Usage</h2>

```
Usage:
  postcss [input.css] [OPTIONS] [-o|--output output.css] [--watch|-w]
  postcss <input.css>... [OPTIONS] --dir <output-directory> [--watch|-w]
  postcss <input-directory> [OPTIONS] --dir <output-directory> [--watch|-w]
  postcss <input-glob-pattern> [OPTIONS] --dir <output-directory> [--watch|-w]
  postcss <input.css>... [OPTIONS] --replace

Basic options:
  -o, --output   Output file                                            [string]
  -d, --dir      Output directory                                       [string]
  -r, --replace  Replace (overwrite) the input file                    [boolean]
  -m, --map      Create an external sourcemap
  --no-map       Disable the default inline sourcemaps
  -w, --watch    Watch files for changes and recompile as needed       [boolean]
  --verbose      Be verbose                                            [boolean]
  --env          A shortcut for setting NODE_ENV                        [string]

Options for use without a config file:
  -u, --use      List of postcss plugins to use                          [array]
  --parser       Custom postcss parser                                  [string]
  --stringifier  Custom postcss stringifier                             [string]
  --syntax       Custom postcss syntax                                  [string]

Options for use with --dir:
  --ext   Override the output file extension; for use with --dir        [string]
  --base  Mirror the directory structure relative to this path in the output
          directory, for use with --dir                                 [string]

Advanced options:
  --include-dotfiles  Enable glob to match files/dirs that begin with "."
                                                                       [boolean]
  --poll              Use polling for file watching. Can optionally pass polling
                      interval; default 100 ms
  --config            Set a custom directory to look for a config file  [string]

Options:
  --version   Show version number                                      [boolean]
  -h, --help  Show help                                                [boolean]

Examples:
  postcss input.css -o output.css                       Basic usage
  postcss src/**/*.css --base src --dir build           Glob Pattern & output
  cat input.css | postcss -u autoprefixer > output.css  Piping input & output

If no input files are passed, it reads from stdin. If neither -o, --dir, or
--replace is passed, it writes to stdout.

If there are multiple input files, the --dir or --replace option must be passed.

Input files may contain globs (e.g. src/**/*.css). If you pass an input
directory, it will process all files in the directory and any subdirectories,
respecting the glob pattern.
```

> ℹ️ More details on custom parsers, stringifiers and syntaxes, can be found [here](https://github.com/postcss/postcss#syntaxes).

### [Config](https://github.com/michael-ciniawsky/postcss-load-config)

If you need to pass options to your plugins, or have a long plugin chain, you'll want to use a configuration file.

**postcss.config.js**

```js
module.exports = {
  parser: 'sugarss',
  plugins: [
    require('postcss-import')({ ...options }),
    require('postcss-url')({ url: 'copy', useHash: true }),
  ],
}
```

Note that you **can not** set the `from` or `to` options for postcss in the config file. They are set automatically based on the CLI arguments.

### Context

For more advanced usage it's recommend to to use a function in `postcss.config.js`, this gives you access to the CLI context to dynamically apply options and plugins **per file**

|   Name    |    Type    |              Default               | Description          |
| :-------: | :--------: | :--------------------------------: | :------------------- |
|   `env`   | `{String}` |          `'development'`           | process.env.NODE_ENV |
|  `file`   | `{Object}` |    `dirname, basename, extname`    | File                 |
| `options` | `{Object}` | `map, parser, syntax, stringifier` | PostCSS Options      |

**postcss.config.js**

```js
module.exports = (ctx) => ({
  map: ctx.options.map,
  parser: ctx.file.extname === '.sss' ? 'sugarss' : false,
  plugins: {
    'postcss-import': { root: ctx.file.dirname },
    cssnano: ctx.env === 'production' ? {} : false,
  },
})
```

> ⚠️ If you want to set options via CLI, it's mandatory to reference `ctx.options` in `postcss.config.js`

```bash
postcss input.sss -p sugarss -o output.css -m
```

**postcss.config.js**

```js
module.exports = (ctx) => ({
  map: ctx.options.map,
  parser: ctx.options.parser,
  plugins: {
    'postcss-import': { root: ctx.file.dirname },
    cssnano: ctx.env === 'production' ? {} : false,
  },
})
```

[npm]: https://img.shields.io/npm/v/postcss-cli.svg
[npm-url]: https://npmjs.com/package/postcss-cli
[node]: https://img.shields.io/node/v/postcss-cli.svg
[node-url]: https://nodejs.org/
[tests]: http://img.shields.io/travis/postcss/postcss-cli/master.svg
[tests-url]: https://travis-ci.org/postcss/postcss-cli
[cover]: https://img.shields.io/coveralls/postcss/postcss-cli/master.svg
[cover-url]: https://coveralls.io/github/postcss/postcss-cli
[chat]: https://img.shields.io/gitter/room/postcss/postcss.svg
[chat-url]: https://gitter.im/postcss/postcss
