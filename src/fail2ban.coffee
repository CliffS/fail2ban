fs  = require 'fs'
net = require 'net'

unpickle  = require 'unpickle';
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

  message: (msg...) ->
    new Promise (resolve, reject) =>
      encoded = unpickle.dump msg
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
        result = unpickle.parse response
        resolve result[1]

  @property 'status',
    get: ->
      response = await @message 'status'
      status =
        jails: response[0][1]
        list: response[1][1].split /,\s*/

  ping: ->
    return @message 'ping'

  reload: (jail) ->
    if jail
      return @message 'reload', jail
    return @message 'reload'

  @property 'dbfile',
    get: ->
      await @message 'get', 'dbfile'

    set: (file) ->
      await @message 'set', 'dbfile', file

module.exports = Fail2Ban
