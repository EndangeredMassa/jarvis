store = require('../../store')
processor = require('../../processor')

exports.index = (req, res) ->
  store.getItems req.session.passport.user, (err, userItems) ->
    content =
      title: 'JARVIS'
      items: userItems.slice().reverse()
      pipes: processor.getPipeInfo()
    res.render 'index', content
