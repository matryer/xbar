'use strict'
const chalk = require('chalk')

const logo = `
                                      /|\\
                                    //   //
                                  //       //
                                //___*___*___//
                              //--*---------*--//
                            /|| *             * ||/
                          // ||*               *|| //
                        //   || *             * ||   //
                      //_____||___*_________*___||_____//
`

module.exports = require('yargs')
  .usage(
    `${chalk.bold.red(logo)}
Usage:
  $0 [input.css] [OPTIONS] [-o|--output output.css] [--watch|-w]
  $0 <input.css>... [OPTIONS] --dir <output-directory> [--watch|-w]
  $0 <input-directory> [OPTIONS] --dir <output-directory> [--watch|-w]
  $0 <input-glob-pattern> [OPTIONS] --dir <output-directory> [--watch|-w]
  $0 <input.css>... [OPTIONS] --replace`
  )
  .group(
    ['o', 'd', 'r', 'map', 'no-map', 'watch', 'verbose', 'env'],
    'Basic options:'
  )
  .option('o', {
    alias: 'output',
    desc: 'Output file',
    type: 'string',
    conflicts: ['dir', 'replace'],
  })
  .option('d', {
    alias: 'dir',
    desc: 'Output directory',
    type: 'string',
    conflicts: ['output', 'replace'],
  })
  .option('r', {
    alias: 'replace',
    desc: 'Replace (overwrite) the input file',
    type: 'boolean',
    conflicts: ['output', 'dir'],
  })
  .alias('m', 'map')
  .describe('map', 'Create an external sourcemap')
  .describe('no-map', 'Disable the default inline sourcemaps')
  .option('w', {
    alias: 'watch',
    desc: 'Watch files for changes and recompile as needed',
    type: 'boolean',
    conflicts: 'replace',
  })
  .option('verbose', {
    desc: 'Be verbose',
    type: 'boolean',
  })
  .option('env', {
    desc: 'A shortcut for setting NODE_ENV',
    type: 'string',
  })
  .group(
    ['u', 'parser', 'stringifier', 'syntax'],
    'Options for use without a config file:'
  )
  .option('u', {
    alias: 'use',
    desc: 'List of postcss plugins to use',
    type: 'array',
  })
  .option('parser', {
    desc: 'Custom postcss parser',
    type: 'string',
  })
  .option('stringifier', {
    desc: 'Custom postcss stringifier',
    type: 'string',
  })
  .option('syntax', {
    desc: 'Custom postcss syntax',
    type: 'string',
  })
  .group(['ext', 'base'], 'Options for use with --dir:')
  .option('ext', {
    desc: 'Override the output file extension; for use with --dir',
    type: 'string',
    implies: 'dir',
    coerce(ext) {
      if (ext.indexOf('.') !== 0) return `.${ext}`
      return ext
    },
  })
  .option('base', {
    desc:
      'Mirror the directory structure relative to this path in the output directory, for use with --dir',
    type: 'string',
    implies: 'dir',
  })
  .group(['include-dotfiles', 'poll', 'config'], 'Advanced options:')
  .option('include-dotfiles', {
    desc: 'Enable glob to match files/dirs that begin with "."',
    type: 'boolean',
  })
  .option('poll', {
    desc:
      'Use polling for file watching. Can optionally pass polling interval; default 100 ms',
    implies: 'watch',
  })
  .option('config', {
    desc: 'Set a custom directory to look for a config file',
    type: 'string',
  })
  .alias('h', 'help')
  .example('$0 input.css -o output.css', 'Basic usage')
  .example('$0 src/**/*.css --base src --dir build', 'Glob Pattern & output')
  .example(
    'cat input.css | $0 -u autoprefixer > output.css',
    'Piping input & output'
  )
  .epilog(
    `If no input files are passed, it reads from stdin. If neither -o, --dir, or --replace is passed, it writes to stdout.

If there are multiple input files, the --dir or --replace option must be passed.

Input files may contain globs (e.g. src/**/*.css). If you pass an input directory, it will process all files in the directory and any subdirectories, respecting the glob pattern.

For more details, please see https://github.com/postcss/postcss-cli`
  ).argv
