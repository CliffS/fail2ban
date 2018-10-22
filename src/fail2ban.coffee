fs  = require 'fs'
net = require 'net'

ini     = require 'ini'
Pickle  = require './pickle'

END = "<F2B_END_COMMAND>"


class Fail2Ban

  constructor: (config = '/etc/fail2ban/fail2ban.conf') ->
    stats = fs.statSync config
    if stats.isSocket()
      @socket = config
    else
      conf = ini.parse fs.readFileSync config, 'utf-8'
      @socket = conf.Definition.socket
    @pickle = new Pickle

  message: (msg...) ->
    new Promise (resolve, reject) =>
      @pickle.dump msg
      .then (encoded) =>
        conn = net.connect @socket, =>
          conn.write encoded
          conn.write END
        .on 'error', (err) =>
          reject err
        .on 'data', (data) =>
          response = Buffer.from data
          if response.toString('binary').endsWith END
            response = response.slice 0, response.length - END.length
          conn.end()
          @pickle.load response
          .then (result) =>
            resolve result
          .catch (err) =>
            reject err
      .catch (err) =>
        reject err

  status: (jail) ->
    if jail
      @message 'status', jail
      .then (response) =>
        response
    else
      @message 'status'
      .then (response) =>
        status =
          jails: response[1][0][1]
          list: response[1][1].slice 1

  reload: ->
    @message 'reload'

  ping: ->
    @message 'ping'
    .then (response) =>
      response[1]

  dbFile: ->
    @message 'get', 'dbfile'
    .then (response) =>
      response[1]


module.exports = Fail2Ban
