urlParse = require('url').parse
cheerio = require 'cheerio'
request = require 'request'

module.exports =
  type: 'github'
  description: 'Extracts the README from a github repo.'
  weight: 50
  once: true
  example: 'https://github.com/joyent/node'
  enabled: 1

  match: (source, user, callback) ->
    host = urlParse(source).hostname
    match = host.indexOf('github') > -1
    callback(null, match)

  process: (source, options, user, callback) ->
    request source, (error, response, html) ->
      return callback(error) if error?

      $ = cheerio.load(html)
      title = $('title').text()
      $('#readme > .name').remove()
      content = $('#readme').html()

      item =
        url: source
        title: title
        content: content
      callback(null, [item])

