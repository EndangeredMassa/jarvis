urlParse = require('url').parse
validUrl = require 'valid-url'
request = require 'request'
cheerio = require 'cheerio'
{unique, map} = require 'underscore'

module.exports =
  type: 'tweet'
  description: 'Extracts links from tweets and reprocesses them.'
  weight: 100
  once: true
  example: 'https://twitter.com/TheOnion/statuses/399245114360754176'
  enabled: 1

  match: (source, user, callback) ->
    host = urlParse(source).hostname
    match = host.indexOf('twitter') > -1
    callback(null, match)

  process: (source, options, user, callback) ->
    request source, (error, response, html) ->
      return callback(error) if error?

      $ = cheerio.load(html)

      image = $('.media img').attr('src')
      if image
        # TODO: resolve possible relative url
        userName = $('.permalink-header .username').text()
        item =
          title: "Twitter Image from #{userName}"
          url: source
          content: """<img src="#{image}" />"""
        return callback(null, [item])

      anchors = $('.tweet-text a')
      links = []
      anchors.each ->
        links.push $(this).attr('href')
      links = unique links
      callback(null, links)

