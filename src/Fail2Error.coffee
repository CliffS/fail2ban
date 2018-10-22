
class Fail2Error extends Error

  constructor: (@code, message) ->
    super message
    Error.captureStackTrace @, Fail2Error

module.exports = Fail2Error

