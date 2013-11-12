dex = require 'dex'

tryParse = (json) ->
  obj = null
  error = null

  try
    obj = JSON.parse(json)
  catch err
    error = err

  [error, obj]

module.exports =
  type: 'dex'
  description: 'Runs rules against an html page to generate items.'
  weight: 1
  once: false
  example: ''
  enabled: 0

  match: (source, user, callback) ->
    # TODO: implement
    requestedOptions = [
      key: 'rules'
      description: 'Dex ruls to apply as JSON array.'
      type: 'multiline'
    ]
    # NOTE: Forcing of because this is incomplete
    callback(null, false, requestedOptions)

  process: (source, options, user, callback) ->
    # TODO: implement
    # options.rules should have a string of dex rules
    # that needs to be split into an array, parsed, and
    # modified to include the source as url before passing
    # to dex itself
    [error, rules] = tryParse(options)
    if error?
      callback(error)
    else if (typeof !rules.length)
      callback new Error "No rules specificed."
    else
      # ...
      callback(null, [])

