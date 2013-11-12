request = require 'request'
FeedParser = require 'feedparser'

endsWithXml = (url) ->
  url.substr(url.length-4, 4) == '.xml'

isRss = (url, callback) ->
  request.head url, (error, response) ->
    return callback(error) if error?

    matched = response.headers['content-type'].indexOf('text/xml') == 0
    callback(null, matched)

parseRssItem = (rssItem) ->
  #timestamp: rssItem.pubDate
  {
    title: rssItem.title
    content: rssItem.description
    url: rssItem.link
  }

allowed = (item, filter) ->
  !!item.title.match(filter)

module.exports =
  type: 'rss'
  description: 'Grabs RSS content and creates items. Optionally provide a regex filter (with no start/end slashes) after you submit the rss url to filter the items that are added to your feed by title.'
  weight: 100
  once: false
  example: 'http://blog.nodeknockout.com/rss'
  enabled: 1

  match: (source, user, callback) ->
    requestedOptions = [
      key: 'filter'
      description: '[optional] a regex (NO START/END SLASHES) to filter rss items by title'
      type: 'input'
    ]
    match = endsWithXml(source)
    if match
      callback(null, match, requestedOptions)
    else
      isRss source, (error, match) ->
        return callback(error) if error?
        callback(null, match, requestedOptions)

  process: (source, options, user, callback) ->
    {filter} = options

    items = []
    parser = new FeedParser {feedurl:source}
    stream = request(source).pipe(parser)
    stream.on 'readable', ->
      while (rssItem = this.read())
        item = parseRssItem(rssItem)
        if allowed(item, filter)
          items.push item
    stream.on 'end', ->
      callback(null, items)
    stream.on 'error', (error) ->
      callback(error)

