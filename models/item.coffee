mongoose = require("mongoose")
Schema = mongoose.Schema
_ = require("underscore")
authTypes = ["twitter", "facebook"]

ItemSchema = new Schema(
  title:
    type: String
    default: ""
  url:
    type: String
    default: ""
  content:
    type: String
    default: ""
  timestamp:
    type: Date
  read: 
    type: Boolean
    default: false 
)
Item = mongoose.model('item', ItemSchema)
module.exports = 
  Item: Item
  ItemSchema: ItemSchema
