Fail2Ban = require './fail2ban'
class Jail extends Fail2Ban

  constructor: (@jail, config) ->
    super config
    @cfg = config
    return @

  action: (ACT) ->
    return new JailAction(@jail,ACT,@cfg)

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

  addIgnoreIp:(ip) ->
    return @message 'set', @jail, 'addignoreip', ip

  delIgnoreIp:(ip) ->
    return @message 'set', @jail, 'delignoreip', ip

  unban: (ip) ->
    return @message 'set', @jail, 'unbanip', ip  # returns IP unbanned

  addAction: (ACT) ->
    return @message 'set', @jail, 'addaction', ACT

  @property 'actions',
    get: ->
      await @message 'get', @jail, 'actions'

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


class JailAction extends Jail
  constructor: (jail, @action, config) ->
    super jail, config
    @jail = jail
    return @

  @property 'actionStart',
    get: ->
      @message 'get', @jail, 'action', @action, 'actionstart'
    set: (cmd) ->
      await @message 'set', @jail, 'action', @action, 'actionstart', cmd

  @property 'actionStop',
    get: ->
      @message 'get', @jail, 'action', @action, 'actionstop'
    set: (cmd) ->
      await @message 'set', @jail, 'action', @action, 'actionstop', cmd

  @property 'actionCheck',
    get: ->
      @message 'get', @jail, 'action', @action, 'actioncheck'
    set: (cmd) ->
      await @message 'set', @jail, 'action', @action, 'actioncheck', cmd

  @property 'actionBan',
    get: ->
      @message 'get', @jail, 'action', @action, 'actionban'
    set: (cmd) ->
      await @message 'set', @jail, 'action', @action, 'actionban', cmd

  @property 'actionUnban',
    get: ->
      @message 'get', @jail, 'action', @action, 'actionunban'
    set: (cmd) ->
      await @message 'set', @jail, 'action', @action, 'actionunban', cmd

  @property 'timeout',
    get: ->
      @message 'get', @jail, 'action', @action, 'timeout'
    set: (cmd) ->
      await @message 'set', @jail, 'action', @action, 'timeout', cmd

  @property 'actionProperties',
    get: ->
      await @message 'get', @jail, 'actionproperties', @action

  @property 'actionMethods',
    get: ->
      await @message 'get', @jail, 'actionmethods', @action

  getProp: (propName) ->
    return await @message 'get', @jail, 'action', @action, propName
module.exports = Jail
