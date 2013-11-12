readability = require 'node-readability'

module.exports =
  type: 'article'
  description: 'Extracts an article from an HTML page.'
  weight: 0
  once: true
  example: 'http://www.theonion.com/articles/scientists-recommend-having-earth-put-down,34034/'
  enabled: 1

  match: (source, user, callback) ->
    # this can always match
    # rely on higher weight pipes to do
    # custom logic
    callback(null, true)

  process: (source, options, user, callback) ->
    readability.read source, (error, article) ->
      return callback(error) if error?

      item =
        url: source
        title: article.getTitle()
        content: article.getContent()
      callback(null, [item])

