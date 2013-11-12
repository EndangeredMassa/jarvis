mongoose = require("mongoose")
Schema = mongoose.Schema
_ = require("underscore")
authTypes = ["twitter", "facebook"]
ItemSchema = require('./item').ItemSchema

UserSchema = new Schema(
  name:
    type: String
    default: ""
  items: [ItemSchema]
  providers: [String]
  facebook:
    authToken:
      type: String
      default: ""
    id:
      type: String
      default: ""
    profile: {}
  twitter:
    authToken:
      type: String
      default: ""
    id:
      type: String
      default: ""
    profile: {}
)
User = mongoose.model('user', UserSchema)
module.exports = User
