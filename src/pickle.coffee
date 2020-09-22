spawn = require('child_process').spawn
Path = require 'path'
fs = require 'fs'
Fail2Error = require './Fail2Error'

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
      ], stdio : ['pipe', 'pipe', 'inherit']
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
      ], stdio : ['pipe', 'pipe', 'inherit']
      response = []
      python.stdout.on 'data', (data) =>
        response.push data
      python.on 'exit', (code) =>
        switch code
          when 0
            resolve JSON.parse Buffer.concat(response).toString()
          else
            err = Buffer.concat(response).toString()
            match = err.match /[A-Z][a-z]+Error\(["'](.*)["']/
            if match then err = match[1]
            reject new Error err
      python.on 'error', (err) =>
        reject err
        python.stdin.end()
      python.stdin.write pickle
      python.stdin.end()


module.exports = Pickle
