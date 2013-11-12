log = require '../processor/log'

DEMO_USER_ID = ''

users = []
mongoose = require('mongoose')
User = require('../models/user')
Item = require('../models/item').Item
_ = require('underscore')

module.exports = actions =
  # callback(userId)
  addUser: (userData, callback) ->
    userData.items ?= []
    users.push userData
    callback(users.length - 1)

  # callback(error, userItems)
  getItems: (userId, callback) ->
    userId = DEMO_USER_ID if not userId?
    User.findOne _id: userId, (err, user) ->
      return callback(err)  if err
      unless user
        callback 'user not found'
      else
        callback(null, user.items)

  # callback(error, userItems)
  addItem: (userId, item, callback) ->
    userId = DEMO_USER_ID if not userId?
    User.findOne _id: userId, (err, user) ->
      return callback(err)  if err
      unless user
        callback 'user not found'
      else
        item.timestamp = new Date()
        exists = false
        _.each user.items, (it) ->
          if(it.url == item.url)
            exists = true
        if !exists
          user.items.push(item)
          user.save (err) ->
            actions.onItemAdded(userId, item)
            console.log err  if err
            callback?(err, user.items)
        else
          callback?('already exists')

  # consumer must overwrite
  onItemAdded: (userId, item) ->
    log.error 'Warning: onItemAdded is not being listened to!'

  # callback(error)
  readItem: (userId, itemId, callback) ->
    userId = DEMO_USER_ID if not userId?
    User.findOne _id: userId, (err, user) ->
      return callback(err)  if err
      unless user
        callback 'user not found'
      else
        _.each user.items, (item) ->
          if(item.id == itemId)
            item.read = true
            user.save()
            callback?()

  removeItem: (userId, itemId, callback) ->
    userId = DEMO_USER_ID if not userId?
    User.findOne _id: userId, (err, user) ->
      return callback(err)  if err
      unless user
        callback 'user not found'
      else
        count = 0
        _.each user.items, (item) ->
          if(item.id == itemId)
            user.items.splice(count, 1)
            user.save()
            callback?()
          else
            count++

