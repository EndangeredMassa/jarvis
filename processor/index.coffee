async = require('async')
createQueue = async.queue
asyncMap = async.map
{map, isObject, isString} = require 'underscore'
log = require './log'
matcher = require './matcher'
pipes = require './pipes'

# check items in queue with at least
# this much time between checks
ITEM_CHECK_INTERVAL = 1000 * 60

# number of sources to process at the same time
CONCURRENCY = 2

matchSources = (url, userId) ->
  source = {
    url
    userId
  }
  matcher.match source, (err, matchedResult) ->
    return log.error err if err?

    source.type = matchedResult.pipe.type
    processor.addSources([source])

processSource = (source, callback) ->
  source.lastCheck ?= Date.now() - ITEM_CHECK_INTERVAL - 5
  sinceLastCheck = Date.now() - source.lastCheck

  source.lastCheck = Date.now()

  if sinceLastCheck < ITEM_CHECK_INTERVAL
    setTimeout (->
      queue.push(source)
    ), ITEM_CHECK_INTERVAL+5
    return callback()

  pipe = pipes.hash[source.type]
  log.log "Processing Source: #{source.type} -> #{source.url}"
  pipe.process source.url, source.providedOptions || {}, source.user, (error, items) ->
    return callback(error) if error?
    return callback() if items.length == 0

    for item in items
      if isObject item
        if item.title && item.content
          processor.onItemsAdded source.userId, [item]
        else
          log.error "Incomplete/invalid item: #{JSON.stringify item}"
      else if isString item
        matchSources(item, source.userId)
      else
        log.error "Invalid type returned by processor #{pipe.type}: #{JSON.stringify item}"

    if !pipe.once
      queue.push source

    callback()

queue = createQueue processSource, CONCURRENCY

module.exports = processor =
  # consumer should override this
  onItemsAdded: (userId, items) ->
    log.error 'Warning: onItemsAdded is not being listened to!'

  addSources: (sources) ->
    if sources?.length
      queue.push sources

  getPipeInfo: () ->
    pipesInfo = []
    for pipe in pipes.list
      if pipe.enabled == 1
        pipesInfo.push({type: pipe.type, description: pipe.description, example: pipe.example})
    return pipesInfo

