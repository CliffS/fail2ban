spawn = require('child_process').spawn
Path = require 'path'
fs = require 'fs'

class Pickle

  constructor: ->
    @script = Path.normalize Path.join __dirname, '..', 'util', 'pypickle.py'
    fs.statSync @script


  dump: (obj) ->
    new Promise (resolve, reject) =>
      python = spawn '/usr/bin/env', [
        'python3'
        @script
        'dump'
      ]
      response = []
      python.stdout.on 'data', (data) =>
        response.push data
      python.on 'exit', (code, signal) =>
        return reject new Error "Response code of #{code}" if code
        resolve Buffer.concat response
      python.on 'error', (err) =>
        reject err
        python.stdin.end()
      python.stdin.write JSON.stringify obj
      python.stdin.end()

  load: (pickle) ->
    new Promise (resolve, reject) =>
      python = spawn '/usr/bin/env', [
        'python3'
        @script
        'load'
      ]
      response = []
      python.stdout.on 'data', (data) =>
        response.push data
      python.on 'exit', (code) =>
        return reject new Error "Response code of #{code}" if code
        resolve JSON.parse Buffer.concat(response).toString()
      python.on 'error', (err) =>
        reject err
        python.stdin.end()
      python.stdin.write pickle
      python.stdin.end()


module.exports = Pickle

