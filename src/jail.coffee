Fail2Ban = require './fail2ban'

class Jail extends Fail2Ban

  constructor: (@jail, config) ->
    super config

  @property 'status',
    get: ->
      try
        response = await @message 'status', @jail
        status =
          filter:
            currentlyFailed: response[0][1][0][1]
            totalFailed:     response[0][1][1][1]
            fileList:        response[0][1][2][1]
          actions:
            currentlyBanned: response[1][1][0][1]
            totalBanned:     response[1][1][1][1]
            bannedIPList:    response[1][1][2][1]
      catch e
        status = null

  @property 'regex',
    get: ->
      await @message 'get', @jail, 'failregex'

  addRegex: (regex) ->
    current = await @regex
    throw new Error "Regex already exists" if regex in current
    return @message 'set', @jail, 'addfailregex', regex
    # returns list of regexes

  delRegex: (regex) ->
    current = await @regex
    throw new Error "Regex does not exist" unless regex in current
    return @message 'set', @jail, 'delfailregex', current.indexOf regex
    # returns list of regexes

  ban: (ip) ->
    return @message 'set', @jail, 'banip', ip
    # returns IP banned

  add: (backend = 'systemd') ->
    return @message 'add', @jail, backend

  stop: () ->
    return @message 'stop', @jail

  start: () ->
    return @message 'start', @jail

  #actionBan: (ACT,cmd) ->
  #  return @message 'set', @jail, 'action', ACT, 'actionban', cmd

  addIgnoreIp:(ip) ->
    return @message 'set', @jail, 'addignoreip', ip

  delIgnoreIp:(ip) ->
    return @message 'set', @jail, 'delignoreip', ip

  unban: (ip) ->
    return @message 'set', @jail, 'unbanip', ip  # returns IP unbanned

  addAction: (ACT) ->
    return @message 'set', @jail, 'addaction', ACT

  @property 'findTime',
    get: ->
      await @message 'get', @jail, 'findtime'
    set: (secs) ->
      await @message 'set', @jail, 'findtime', secs.toString()

  @property 'banTime',
    get: ->
      await @message 'get', @jail, 'bantime'
    set: (secs) ->
      await @message 'set', @jail, 'bantime', secs.toString()

  @property 'failRegex',
    get: ->
      await @message 'get', @jail, 'failregex'
    set: (secs) ->
      await @message 'set', @jail, 'failregex', secs.toString()

  @property 'retries',
    get: ->
      await @message 'get', @jail, 'maxretry'

    set: (reties) ->
      await @message 'set', @jail, 'maxretry', reties.toString()

  @property 'useDNS',
    get: ->
      await @message 'get', @jail, 'usedns'

    set: (mode) ->
      modes = [
        'yes'
        'warn'
        'no'
        'raw'
      ]
      unless mode in modes
        throw new Error "Valid modes are: yes, warn, no and raw"
      await @message 'set', @jail, 'usedns', mode

module.exports = Jail
