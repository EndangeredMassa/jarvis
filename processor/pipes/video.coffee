video = require 'youtube-dl'
urlParse = require('url').parse

SITES = ['youtube', 'vimeo']

getSite = (url) ->
  host = urlParse(url).hostname
  found = null
  for site in SITES
    #CSR won't let us return here
    found=site if host.indexOf(site) > -1
  found

createEmbedCode = (site, id) ->
  switch site
    when 'youtube'
      """<iframe id="video-player-#{id}" type="text/html" width="640" height="390" src="http://www.youtube.com/embed/#{id}?autoplay=0" frameborder="0"></iframe>"""
    when 'vimeo'
      """<iframe src="//player.vimeo.com/video/#{id}" width="640" height="390" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>"""

module.exports =
  type: 'video'
  description: 'Presents an embedded youtube/vimeo/etc video with a download button.'
  weight: 50
  once: true
  example: 'http://www.youtube.com/watch?v=QH2-TGUlwu4'
  enabled: 1

  match: (source, user, callback) ->
    video.getInfo source, (error, info) ->
      return callback(error, false) if error?
      callback(null, true)

  process: (source, options, user, callback) ->
    video.getInfo source, (error, info) ->
      return callback(error, false) if error?

      item =
        url: source
        title: info.title
        content: createEmbedCode(getSite(source), info.id)
      callback(null, [item])

