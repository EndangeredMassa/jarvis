urlParse = require('url').parse
cheerio = require 'cheerio'
request = require 'request'

getId = (url) ->
  if url[url.length - 1] == '/'
    url = url.substring(0, url.length - 1)
  parts = url.split('/')
  parts[parts.length - 1]

module.exports =
  type: 'instagram'
  description: 'Extracts the image from an instragram url'
  weight: 50
  once: true
  example: 'http://instagram.com/p/e0BaRqQ96b/'
  enabled: 1

  match: (source, user, callback) ->
    host = urlParse(source).hostname
    match = host.indexOf('instagram') > -1
    callback(null, match)

  process: (source, options, user, callback) ->
    request source, (error, response, html) ->
      return callback(error) if error?

      $ = cheerio.load(html)
      # TODO: look into api to get this info
      title = 'Instagram Photo'
      id = getId(source)

      # TODO: look into api to get this, including
      # height and width
      content = """
        <iframe src="//instagram.com/p/#{id}/embed/"
        width="612" height="710" frameborder="0" scrolling="no"
        allowtransparency="true"></iframe
      """

      item =
        url: source
        title: title
        content: content
      callback(null, [item])

