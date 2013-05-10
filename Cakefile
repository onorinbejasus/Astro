fs = require 'fs'

{print} = require 'sys'
{spawn} = require 'child_process'

task 'build', 'Build project from src/*.coffee to lib/*.js', ->
	coffee = spawn 'coffee', ['-c', '-b', '-o', 'lib', 'src']   
	coffee.stderr.on 'data', (data) ->
      process.stderr.write data.toString()
    coffee.stdout.on 'data', (data) ->
      print data.toString()

 task 'watch', 'Watch src/ for changes', ->
    coffee = spawn 'coffee', ['-c', '-b', '-o', 'lib', 'src']
    coffee.stderr.on 'data', (data) ->
      process.stderr.write data.toString()
    coffee.stdout.on 'data', (data) ->
      print data.toString()