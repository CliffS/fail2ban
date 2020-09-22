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
            currentlyFailed: response[1][0][1][0][1]
            totalFailed:     response[1][0][1][1][1]
            fileList:        response[1][0][1][2][1]
          actions:
            currentlyBanned: response[1][1][1][0][1]
            totalBanned:     response[1][1][1][1][1]
            bannedIPList:    response[1][1][1][2][1]
      catch e
        status = null

  @property 'regex',
    get: ->
      response = await @message 'get', @jail, 'failregex'
      response[1]

  addRegex: (regex) ->
    @regex
    .then (current) =>
      throw new Error "Regex already exists" if regex in current
      @message 'set', @jail, 'addfailregex', regex
    .then (response) =>
      response[1]       # returns list of regexes

  delRegex: (regex) ->
    @regex
    .then (current) =>
      throw new Error "Regex does not exist" unless regex in current
      @message 'set', @jail, 'delfailregex', current.indexOf regex
    .then (response) =>
      response[1]       # returns list of regexes

  ban: (ip) ->
    @message 'set', @jail, 'banip', ip
    .then (response) =>
      response[1]       # returns IP banned

  add: (backend = 'systemd') ->
    return @message 'add', @jail, backend

  stop: () ->
    return @message 'stop', @jail

  start: () ->
    return @message 'start', @jail

  actionban: (ACT,cmd) ->
    return @message 'set', @jail, 'action', ACT, 'actionban', cmd

  unban: (ip) ->
    @message 'set', @jail, 'unbanip', ip
    .then (response) =>
      response[1]       # returns IP unbanned

  @property 'findTime',
    get: ->
      @message 'get', @jail, 'findtime'
      .then (time) =>
        time[1]
    set: (secs) ->
      @message 'set', @jail, 'findtime', secs.toString()

  @property 'retries',
    get: ->
      @message 'get', @jail, 'maxretry'
      .then (reties) =>
        reties[1]
    set: (reties) ->
      @message 'set', @jail, 'maxretry', reties.toString()

  @property 'useDNS',
    get: ->
      @message 'get', @jail, 'usedns'
      .then (dns) =>
        dns[1]
    set: (mode) ->
      modes = [
        'yes'
        'warn'
        'no'
        'raw'
      ]
      unless mode in modes
        throw new Error "Valid modes are: yes, warn, no and raw"
      @message 'set', @jail, 'usedns', mode

module.exports = Jail
