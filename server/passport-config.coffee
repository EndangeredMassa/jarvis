mongoose = require('mongoose')
TwitterStrategy = require('passport-twitter').Strategy
FacebookStrategy = require('passport-facebook').Strategy
config = require('./config')
User = require('../models/user')

module.exports = (passport, config, db) ->
  # serialize sessions
  passport.serializeUser (user, done) ->
    done null, user.id

  passport.deserializeUser (id, done) ->
    User.findOne _id: id , (err, user) ->
      done err, user


  passport.use new TwitterStrategy {
    consumerKey: config.TWITTER_CONSUMER_KEY
    consumerSecret: config.TWITTER_CONSUMER_SECRET
    callbackURL: config.TWITTER_CALLBACK_URL
  }, (token, tokenSecret, profile, done) ->
    User.findOne {'twitter.id': profile.id}, (err, user) ->
      return done(err)  if err
      unless user
        user = new User(
          name: profile.displayName
          twitter: {
            id: profile.id
            profile: profile._json
            authToken: token
          }
        )
        user.providers.push('twitter')
        user.items = []
        user.save (err) ->
          console.log err  if err
          done err, user
      else
        done err, user
  passport.use new FacebookStrategy {
    clientID: config.FACEBOOK_APP_ID
    clientSecret: config.FACEBOOK_APP_SECRET
    callbackURL: config.FACEBOOK_CALLBACK_URL
  }, (token, tokenSecret, profile, done) ->
    User.findOne {'facebook.id': profile.id}, (err, user) ->
      return done(err)  if err
      unless user
        user = new User(
          name: profile.displayName
          facebook: {
            id: profile.id
            profile: profile._json
            authToken: token
          }
        )
        user.providers.push('facebook')
        user.items = []
        user.save (err) ->
          console.log err  if err
          done err, user
      else
        done err, user

