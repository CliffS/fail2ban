fs  = require 'fs'
net = require 'net'

Pickle  = require './pickle'
Property = require './Property'

END = "<F2B_END_COMMAND>"


class Fail2Ban extends Property

  constructor: (socketFile = '/var/run/fail2ban.sock') ->
    super()
    stats = fs.statSync socketFile
    if stats.isSocket()
      @socket = socketFile
    else
      throw (socketFile+" is not valid socket")
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

module.exports = Fail2Ban
