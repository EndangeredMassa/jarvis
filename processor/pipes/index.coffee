article = require './article'
dex = require './dex'
video = require './video'
rss = require './rss'
github = require './github'
tweet = require './tweet'
instagram = require './instagram'

module.exports =
  list: [
    article
    dex
    video
    rss
    github
    tweet
    instagram
  ]

  hash: {
    article
    dex
    video
    rss
    github
    tweet
    instagram
  }

