
express = require('express')
routes = require('./routes')
auth = require('./routes/login')
http = require('http')
path = require('path')
passport = require('passport')
config = require('./config')
TwitterStrategy = require('passport-twitter').Strategy
FacebookStrategy = require('passport-facebook').Strategy
ensureLoggedIn = require('connect-ensure-login').ensureLoggedIn
actions = require('./routes/actions')
stubs = require('../store/stubs')
mongoose = require('mongoose')
app = express()

DEMO_USER_ID = ''
SESSION_SECRET = ''

isProduction = (process.env.NODE_ENV == 'production')
port = if isProduction then 80 else 8000

db = mongoose.connect(config.mongoURL)
models = {}
models.user = require('../models/user')
models.item = require('../models/item').Item
store = require('../store')
require('./passport-config') passport, config, db

app.set('port', port)
app.set('views', path.join(__dirname, 'views'))
app.set('view engine', 'jade')
app.use(express.favicon())
app.use(express.logger('dev'))
app.use(express.json())
app.use(express.urlencoded())
app.use(express.methodOverride())
app.use(express.cookieParser())
app.use(express.session({ secret: SESSION_SECRET }))
app.use(passport.initialize())
app.use(passport.session())
app.use (req, res, next) ->
  if req.session.passport.user
    res.locals.userId = req.session.passport.user
  else
    res.locals.userId = DEMO_USER_ID
  res.locals.session = req.session
  next()
app.use(app.router)
app.use(require('stylus').middleware(path.join(__dirname, 'public')))
app.use(express.static(path.join(__dirname, 'public')))
app.use(express.bodyParser())

passport.serializeUser (user, done) ->
  done null, user

passport.deserializeUser (obj, done) ->
  done null, obj

if ('development' == app.get('env'))
  app.use(express.errorHandler())

addStubs = (userId) ->
  for stub in stubs.items
    store.addItem userId, stub





app.get('/', routes.index)
app.post('/read', actions.read)
app.post('/remove', actions.remove)
app.post('/add', actions.add)
app.get('/login', auth.login)
app.get('/auth/twitter', passport.authenticate('twitter'))
app.get('/auth/facebook', passport.authenticate('facebook'))
app.get('/auth/twitter/callback', passport.authenticate('twitter', { successReturnToOrRedirect: '/', failureRedirect: '/login' }))
app.get('/auth/facebook/callback', passport.authenticate('facebook', { successRedirect: '/', failureRedirect: '/login' }))
server = http.createServer(app)
io = require('socket.io').listen(server, {log: false})
server.listen app.get('port'), ->
  console.log('Express server listening on port ' + app.get('port'))

sockets = {}
io.sockets.on 'connection', (socket) ->
  socket.on 'setup', (userId) ->
    sockets[userId] = socket

store.onItemAdded = (userId, item) ->
  sockets[userId]?.emit 'newItems', 'NEW ITEM'

# testing processor
processor = require('../processor')
processor.onItemsAdded = (userId, items) ->
  for item in items
    store.addItem userId, item

