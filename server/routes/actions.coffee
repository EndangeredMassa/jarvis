store = require('../../store')
matcher = require('../../processor/matcher')
processor = require('../../processor')
log = require '../../processor/log'

exports.read = (req, res) ->
  userId = req.session.passport.user
  itemId = req.body.itemId
  store.readItem userId, itemId, () ->
    res.status(200)
    res.send()

exports.remove = (req, res) ->
  userId = req.session.passport.user
  itemId = req.body.itemId
  store.removeItem userId, itemId, () ->
    res.status(200)
    res.send()

qualify = (url) ->
  if url.indexOf('http') != 0
    url = 'http://' + url

  url

exports.add = (req, res) ->
  providedOptions = req.body.providedOptions
  url = qualify(req.body.url)
  userId = req.session.passport.user

  source = {
    url
    userId: req.session.passport.user
  }

  if providedOptions?
    # get for real
    source.type = 'rss'
    source.providedOptions = providedOptions

    processor.addSources([source])
    res.status(200)
    res.send()
  else
    matcher.match source, (err, matchedResult) ->
      if err
        log.error err
        res.status(400)
        res.send()
        return

      source.type = matchedResult.pipe.type
      if matchedResult.requestedOptions?
        res.status(200)
        res.send(matchedResult.requestedOptions)
      else
        processor.addSources([source])
        res.status(200)
        res.send()

