#
# - rename files with video titles
# - only check for new videos
# - run on a periodic check (configurable 5mins?)
# - add DAS feed: https://www.destroyallsoftware.com/screencasts/feed
# - add Railscasts feed: http://feeds.feedburner.com/railscasts
# - add twitchtv support
#   - grab the id from: http://www.twitch.tv/totalbiscuit/b/319150803
#   - and hit: http://api.justin.tv/api/clip/show/319150803.xml
#   - and grab objects>object>video_file_url
#   - and download that directly
#

# Setup
youtubedl = require('youtube-dl')
uri       = require('url')
request   = require('request')
FeedParser = require('feedparser')
parser = new FeedParser()

youtubeArgs = [
  '--max-quality=102'
  '-o%(stitle)s.%(ext)s'
]
feedUrl = 'http://gdata.youtube.com/feeds/base/users/EndangeredMassa/newsubscriptionvideos?client=ytapi-youtube-user&v=2'


# Helpers

getFeed = (url) ->
  parser.parseUrl(url)

  reqObj =
    'uri': url
    #'If-Modified-Since' : '',
    #'If-None-Match' : ''

  request reqObj, (err, response, body) ->
    parser.parseString body, (error, meta, articles) ->
      #NOTE: Trimed results for testing purposes
      articles = articles.splice(0, 3)

      downloadNext(articles)

  downloadNext = (articles) ->
    article = articles.shift()
    if !article
      process.exit(0)

    console.log()
    console.log('%s - %s (%s)', article.title, article.date, article.link)

    download article.link, ->
      downloadNext(articles)

download = (url, callback) ->
  if DEBUG
    callback?()
    return

  dl = youtubedl.download(url, './videos', youtubeArgs)

  dl.on 'download', (data) ->
    console.log('Download started')
    console.log('filename: ' + data.filename)
    console.log('size: ' + data.size)

  dl.on 'progress', (data) ->
    process.stdout.write(data.eta + ' ' + data.percent + '% at ' + data.speed + '\r')

  dl.on 'error', (err) ->
    throw err

  dl.on 'end', (data) ->
    console.log('\nDownload finished!')
    console.log('Filename: ' + data.filename)
    console.log('Size: ' + data.size)
    console.log('Time Taken: ' + data.timeTaken)
    console.log('Time Taken in ms: ' + data.timeTakenms)
    console.log('Average Speed: ' + data.averageSpeed)
    console.log('Average Speed in Bytes: ' + data.averageSpeedBytes)
    callback() if callback


# Work
DEBUG = false

if process.argv.length > 2
  download process.argv[2]
else
  getFeed(feedUrl)

