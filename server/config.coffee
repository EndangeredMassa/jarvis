config = {
  mongoURL: ''
}

if process.env.NODE_ENV == 'production'
  config.TWITTER_CONSUMER_KEY = ''
  config.TWITTER_CONSUMER_SECRET = ''
  config.TWITTER_CALLBACK_URL = ''
  config.FACEBOOK_APP_ID = ''
  config.FACEBOOK_APP_SECRET = ''
  config.FACEBOOK_CALLBACK_URL = ''
else
  config.TWITTER_CONSUMER_KEY = ''
  config.TWITTER_CONSUMER_SECRET = ''
  config.TWITTER_CALLBACK_URL = ''
  config.FACEBOOK_APP_ID = ''
  config.FACEBOOK_APP_SECRET = ''
  config.FACEBOOK_CALLBACK_URL = ''

module.exports = config
