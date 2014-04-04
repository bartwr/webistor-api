# ** Cakefile Template ** is a Template for a common Cakefile that you may use in a coffeescript nodejs project.
#
# It comes baked in with 5 tasks:
#
# * build - compiles your src directory to your app directory
# * watch - watches any changes in your src directory and automatically compiles to the app directory
# * test  - runs mocha test framework, you can edit this task to use your favorite test framework
# * docs  - generates annotated documentation using docco
# * clean - clean generated .js files
files = [
  'lib'
  'src'
]

fs = require 'fs'
{print} = require 'util'
{spawn, exec} = require 'child_process'

try
  which = require('which').sync
catch err
  if process.platform.match(/^win/)?
    console.log 'WARNING: the which module is required for windows\ntry: npm install which'
  which = null

# ANSI Terminal Colors
bold = '\x1b[0;1m'
green = '\x1b[0;32m'
reset = '\x1b[0m'
red = '\x1b[0;31m'

###*
 * Docs
 * Generate Annotated Documentation.
###
task 'docs', 'generate documentation', -> docco()

###*
 * Build
 * Builds Source. Can watch.
###
task 'build', 'compile source', (o) -> build o, -> log ":)", green

###*
 * Watch
 * Builds and watches.
###
task 'watch', 'short for [cake --watch build]', (o) -> o.watch = true and build o, -> log ":-)", green

###*
 * Test
 * Runs your test suite. Can watch.
###
task 'test', 'run tests', (o) -> build -> mocha o, -> log ":)", green

###*
 * Clean
 * Cleans up generated js files.
###
task 'clean', 'clean generated files', -> clean -> log ";)", green

###*
 * Watch
 * Watch option for build or test.
###
option '-w', '--watch', 'watch for changes during test or build'


# Internal Functions
#
# ## *walk*
#
# **given** string as dir which represents a directory in relation to local directory
# **and** callback as done in the form of (err, results)
# **then** recurse through directory returning an array of files
#
# Examples
#
# ``` coffeescript
# walk 'src', (err, results) -> console.log results
# ```
walk = (dir, done) ->
  results = []
  fs.readdir dir, (err, list) ->
    return done(err, []) if err
    pending = list.length
    return done(null, results) unless pending
    for name in list
      file = "#{dir}/#{name}"
      try
        stat = fs.statSync file
      catch err
        stat = null
      if stat?.isDirectory()
        walk file, (err, res) ->
          results.push name for name in res
          done(null, results) unless --pending
      else
        results.push file
        done(null, results) unless --pending

# ## *log*
#
# **given** string as a message
# **and** string as a color
# **and** optional string as an explanation
# **then** builds a statement and logs to console.
#
log = (message, color, explanation) -> console.log color + message + reset + ' ' + (explanation or '')

# ## *launch*
#
# **given** string as a cmd
# **and** optional array and option flags
# **and** optional callback
# **then** spawn cmd with options
# **and** pipe to process stdout and stderr respectively
# **and** on child process exit emit callback if set and status is 0
launch = (cmd, options=[], callback) ->
  cmd = which(cmd) if which
  app = spawn cmd, options
  app.stdout.pipe(process.stdout)
  app.stderr.pipe(process.stderr)
  app.on 'exit', (status) -> callback?() if status is 0

# ## *build*
#
# **given** optional object as argv
# **and** optional function as callback
# **then** invoke launch passing coffee command
# **and** defaulted options to compile src to app
build = (argv, callback) ->
  if typeof argv is 'function'
    callback = argv
    argv = {}

  options = ['-c', '-b']
  options.push '-w' if 'watch' of argv
  options = options.concat ['-o', files...]
  launch 'coffee', options, callback

# ## *unlinkIfCoffeeFile*
#
# **given** string as file
# **and** file ends in '.coffee'
# **then** convert '.coffee' to '.js'
# **and** remove the result
unlinkIfCoffeeFile = (file) ->
  if file.match /\.coffee$/
    fs.unlink file.replace('src','lib').replace(/\.coffee$/, '.js'), ->
    true
  else false

# ## *clean*
#
# **given** optional function as callback
# **then** loop through files variable
# **and** call unlinkIfCoffeeFile on each
clean = (callback) ->
  try
    for file in files
      unless unlinkIfCoffeeFile file
        walk file, (err, results) ->
          for f in results
            unlinkIfCoffeeFile f

    callback?()
  catch err

# ## *mocha*
#
# **given** optional command line arguments
# **and** optional function as callback
# **then** invoke launch passing mocha command
mocha = (argv, callback) ->
  if typeof argv is 'function'
    callback = argv
    argv = {}

  options = ['--compilers', 'coffee:coffee-script/register', '--require', 'must']

  # Decide which output method to use based on whether we're watching or not.
  if 'watch' of argv
    options.push '--reporter'
    options.push 'list'
    options.push '--watch'
  else
    options.push '--reporter'
    options.push 'spec'

  launch 'mocha', options, callback

# ## *docco*
#
# **given** optional function as callback
# **then** invoke launch passing docco command
docco = (callback) ->
  walk 'src', (err, files) -> launch 'docco', files, callback

