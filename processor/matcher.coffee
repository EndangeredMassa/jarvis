asyncMap = require('async').map
pipes = require('./pipes').list
request = require 'request'

module.exports =
  match: (source, callback) ->
    options =
      method: "HEAD"
      url: source.url
      followAllRedirects: true

    # resolve all redirects
    request options, (error, info) ->
      return callback(error) if error?

      # resolved url
      source.url = info.request.href

      test = (pipe, matchCallback) ->
        pipe.match source.url, source.userId, (error, matched, requestedOptions) ->
          return matchCallback() if error?
          return matchCallback() if !matched
          matchCallback null, {
            pipe
            requestedOptions
          }

      asyncMap pipes, test, (err, results) ->
        sorted = results.sort (x,y) ->
          return x.pipe.weight < y.pipe.weight
        callback null, sorted[0]

