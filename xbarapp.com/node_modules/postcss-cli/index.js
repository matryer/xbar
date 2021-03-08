'use strict'

const fs = require('fs-extra')
const path = require('path')

const prettyHrtime = require('pretty-hrtime')
const stdin = require('get-stdin')
const read = require('read-cache')
const chalk = require('chalk')
const globber = require('globby')
const slash = require('slash')
const chokidar = require('chokidar')

const postcss = require('postcss')
const postcssrc = require('postcss-load-config')
const reporter = require('postcss-reporter/lib/formatter')()

const argv = require('./lib/args')
const createDependencyGraph = require('./lib/DependencyGraph')
const getMapfile = require('./lib/getMapfile')
const depGraph = createDependencyGraph()

let input = argv._
const { dir, output } = argv

if (argv.map) argv.map = { inline: false }

const cliConfig = {
  options: {
    map: argv.map !== undefined ? argv.map : { inline: true },
    parser: argv.parser ? require(argv.parser) : undefined,
    syntax: argv.syntax ? require(argv.syntax) : undefined,
    stringifier: argv.stringifier ? require(argv.stringifier) : undefined,
  },
  plugins: argv.use
    ? argv.use.map((plugin) => {
        try {
          return require(plugin)()
        } catch (e) {
          const msg = e.message || `Cannot find module '${plugin}'`
          let prefix = msg.includes(plugin) ? '' : ` (${plugin})`
          if (e.name && e.name !== 'Error') prefix += `: ${e.name}`
          return error(`Plugin Error${prefix}: ${msg}'`)
        }
      })
    : [],
}

let configFile

if (argv.env) process.env.NODE_ENV = argv.env
if (argv.config) argv.config = path.resolve(argv.config)

if (argv.watch) {
  process.stdin.on('end', () => process.exit(0))
  process.stdin.resume()
}

/* istanbul ignore next */
if (parseInt(postcss().version) < 8) {
  error('Please install PostCSS 8 or above')
}

Promise.resolve()
  .then(() => {
    if (argv.watch && !(argv.output || argv.replace || argv.dir)) {
      error('Cannot write to stdout in watch mode')
    }

    if (input && input.length) {
      return globber(
        input.map((i) => slash(String(i))),
        { dot: argv.includeDotfiles }
      )
    }

    if (argv.replace || argv.dir) {
      error(
        'Input Error: Cannot use --dir or --replace when reading from stdin'
      )
    }

    if (argv.watch) {
      error('Input Error: Cannot run in watch mode when reading from stdin')
    }

    return ['stdin']
  })
  .then((i) => {
    if (!i || !i.length) {
      error('Input Error: You must pass a valid list of files to parse')
    }

    if (i.length > 1 && !argv.dir && !argv.replace) {
      error(
        'Input Error: Must use --dir or --replace with multiple input files'
      )
    }

    if (i[0] !== 'stdin') i = i.map((i) => path.resolve(i))

    input = i

    return files(input)
  })
  .then((results) => {
    if (argv.watch) {
      const printMessage = () =>
        printVerbose(chalk.dim('\nWaiting for file changes...'))
      const watcher = chokidar.watch(input.concat(dependencies(results)), {
        usePolling: argv.poll,
        interval: argv.poll && typeof argv.poll === 'number' ? argv.poll : 100,
        awaitWriteFinish: {
          stabilityThreshold: 50,
          pollInterval: 10,
        },
      })

      if (configFile) watcher.add(configFile)

      watcher.on('ready', printMessage).on('change', (file) => {
        let recompile = []

        if (input.includes(file)) recompile.push(file)

        recompile = recompile.concat(
          depGraph.dependantsOf(file).filter((file) => input.includes(file))
        )

        if (!recompile.length) recompile = input

        return files(recompile)
          .then((results) => watcher.add(dependencies(results)))
          .then(printMessage)
          .catch(error)
      })
    }
  })
  .catch((err) => {
    error(err)

    process.exit(1)
  })

function rc(ctx, path) {
  if (argv.use) return Promise.resolve(cliConfig)

  return postcssrc(ctx, path)
    .then((rc) => {
      if (rc.options.from || rc.options.to) {
        error(
          'Config Error: Can not set from or to options in config file, use CLI arguments instead'
        )
      }
      configFile = rc.file
      return rc
    })
    .catch((err) => {
      if (!err.message.includes('No PostCSS Config found')) throw err
    })
}

function files(files) {
  if (typeof files === 'string') files = [files]

  return Promise.all(
    files.map((file) => {
      if (file === 'stdin') {
        return stdin().then((content) => {
          if (!content) return error('Input Error: Did not receive any STDIN')
          return css(content, 'stdin')
        })
      }

      return read(file).then((content) => css(content, file))
    })
  )
}

function css(css, file) {
  const ctx = { options: cliConfig.options }

  if (file !== 'stdin') {
    ctx.file = {
      dirname: path.dirname(file),
      basename: path.basename(file),
      extname: path.extname(file),
    }

    if (!argv.config) argv.config = path.dirname(file)
  }

  const relativePath =
    file !== 'stdin' ? path.relative(path.resolve(), file) : file

  if (!argv.config) argv.config = process.cwd()

  const time = process.hrtime()

  printVerbose(chalk`{cyan Processing {bold ${relativePath}}...}`)

  return rc(ctx, argv.config)
    .then((config) => {
      config = config || cliConfig
      const options = { ...config.options }

      if (file === 'stdin' && output) file = output

      // TODO: Unit test this
      options.from = file === 'stdin' ? path.join(process.cwd(), 'stdin') : file

      if (output || dir || argv.replace) {
        const base = argv.base
          ? file.replace(path.resolve(argv.base), '')
          : path.basename(file)
        options.to = output || (argv.replace ? file : path.join(dir, base))

        if (argv.ext) {
          options.to = options.to.replace(path.extname(options.to), argv.ext)
        }

        options.to = path.resolve(options.to)
      }

      if (!options.to && config.options.map && !config.options.map.inline) {
        error(
          'Output Error: Cannot output external sourcemaps when writing to STDOUT'
        )
      }

      return postcss(config.plugins)
        .process(css, options)
        .then((result) => {
          const tasks = []

          if (options.to) {
            tasks.push(fs.outputFile(options.to, result.css))

            if (result.map) {
              const mapfile = getMapfile(options)
              tasks.push(fs.outputFile(mapfile, result.map.toString()))
            }
          } else process.stdout.write(result.css, 'utf8')

          return Promise.all(tasks).then(() => {
            const prettyTime = prettyHrtime(process.hrtime(time))
            printVerbose(
              chalk`{green Finished {bold ${relativePath}} in {bold ${prettyTime}}}`
            )

            const messages = result.warnings()
            if (messages.length) {
              console.warn(reporter({ ...result, messages }))
            }

            return result
          })
        })
    })
    .catch((err) => {
      throw err
    })
}

function dependencies(results) {
  if (!Array.isArray(results)) results = [results]

  const messages = []

  results.forEach((result) => {
    if (result.messages <= 0) return

    result.messages
      .filter((msg) => (msg.type === 'dependency' ? msg : ''))
      .map(depGraph.add)
      .forEach((dependency) => messages.push(dependency.file))
  })

  return messages
}

function printVerbose(message) {
  if (argv.verbose) console.warn(message)
}

function error(err) {
  // Seperate error from logging output
  if (argv.verbose) console.error()

  if (typeof err === 'string') {
    console.error(chalk.red(err))
  } else if (err.name === 'CssSyntaxError') {
    console.error(err.toString())
  } else {
    console.error(err)
  }
  // Watch mode shouldn't exit on error
  if (argv.watch) return
  process.exit(1)
}
