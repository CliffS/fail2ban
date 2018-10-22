fs  = require 'fs'
net = require 'net'

ini     = require 'ini'
Pickle  = require './pickle'
Property = require './Property'
SQLite   = require 'better-sqlite3'

END = "<F2B_END_COMMAND>"


class Fail2Ban extends Property

  constructor: (config = '/etc/fail2ban/fail2ban.conf') ->
    super()
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

  @property 'status',
    get: ->
      response = await @message 'status'
      status =
        jails: response[1][0][1]
        list: response[1][1][1].split /,\s*/

  ping: ->
    @message 'ping'
    .then (response) =>
      response[1]

  @property 'dbfile',
    get: ->
      response = await @message 'get', 'dbfile'
      response[1]
    set: (file) ->
      @message 'set', 'dbfile', file

  @property 'bans',
    get: ->
      file = await @dbfile
      db = new SQLite file,
        fileMustExist: true
        readonly: true
      jail = @jail ? '%'
      statement = db.prepare '''
        SELECT jail, ip, timeofban, data
          FROM bans
        WHERE jail LIKE ?
      '''
      bans = statement.all jail
      for ban in bans
        ban.data = JSON.parse ban.data.toString()
      bans


module.exports = Fail2Ban
