fs            = require 'fs'
{print}       = require 'util'
{spawn, exec} = require 'child_process'
csv           = require 'ya-csv'

# ANSI Terminal Colors
bold  = '\x1B[0;1m'
red   = '\x1B[0;31m'
green = '\x1B[0;32m'
reset = '\x1B[0m'

pkg = JSON.parse fs.readFileSync('./package.json')
testCmd = pkg.scripts.test
startCmd = pkg.scripts.start
  

log = (message, color, explanation) ->
  console.log color + message + reset + ' ' + (explanation or '')

# Compiles app.coffee and src directory to the app directory
build = (callback) ->
  options = ['-c','-b', '-o', 'app', 'src']
  coffee = spawn 'coffee', options
  coffee.stdout.pipe process.stdout
  coffee.stderr.pipe process.stderr
  coffee.on 'exit', (status) -> callback?() if status is 0

# mocha test
test = (callback) ->
  options = [
    '--compilers'
    'coffee:coffee-script'
    '--colors'
    '--require'
    'should'
    '--require'
    './server'
  ]
  spec = spawn 'mocha', options
  spec.stdout.pipe process.stdout 
  spec.stderr.pipe process.stderr
  spec.on 'exit', (status) -> callback?() if status is 0

task 'docs', 'Generate annotated source code with Docco', ->
  fs.readdir 'src', (err, contents) ->
    files = ("src/#{file}" for file in contents when /\.coffee$/.test file)
    docco = spawn 'docco', files
    docco.pipe process.stdout
    docco.stdout.pipe process.stdout
    docco.stderr.pipe process.stderr
    docco.on 'exit', (status) -> callback?() if status is 0


task 'build', ->
  build -> log ":)", green

task 'spec', 'Run Mocha tests', ->
  build -> test -> log ":)", green

task 'test', 'Run Mocha tests', ->
  build -> test -> log ":)", green

task 'dev', 'start dev env', ->
  # watch_coffee
  options = ['-c', '-b', '-w', '-o', 'app', 'src']
  coffee = spawn './node_modules/coffee-script/bin/coffee', options
  coffee.stdout.pipe process.stdout
  coffee.stderr.pipe process.stderr
  log 'Watching coffee files', green
  # watch_js
  supervisor = spawn 'node', ['./node_modules/supervisor/lib/cli-wrapper.js','-w','app,views', '-e', 'js|jade', 'server']
  supervisor.stdout.pipe process.stdout
  supervisor.stderr.pipe process.stderr
  log 'Watching js files and running server', green
  
task 'db:seed', 'Populate graph database with seed data', ->  
  log "Start Seeding ...", bold      
  # 1. load financial years (one node per record)
  # 2. load relation (one node per record)
  # 3. load referral (one node per record)
  # 4. load stock
  # 5. load partner
  # 6. load other entities ... 
  # 7. make relationship sound
  
  db_seed_stocks -> 
    log "done", green

task 'db:clean', 'Clear out existing data', ->
  print "todo\n"
  
task 'db:reseed', 'Clear out existing data, and seed', ->
  print "todo\n"
  
read_csv = (file, next, callback) ->
  reader = csv.createCsvFileReader file,
    'separator': ','
    'quote': ''
    'escape': ''
    'comment': ''

  reader.addListener 'data', (data) ->
    callback(data)

  reader.addListener 'end', ->
    log "  done", green
    next()

db_seed_stocks = (next) ->
  log "  - Seeding Stocks", reset
  Stock = require './app/models/stock'
  
  read_csv './db/fixtures/Stock.csv', next, (data) ->
    Stock.create_from_csv data, (error, stock) ->
      if error
        log error, red 

