{mongoose, model} = require 'node-restful'
{Schema} = mongoose
{ObjectId} = Schema.Types
Auth = require './classes/auth'
config = require './config'

# Connect to the database.
mongoose.connect config.database


##
## SCHEMA DEFINITIONS
##

# Export Schemas.
schemas =
  
  # The User schema.
  User: Schema
    email:    type: String, required: true, unique: true, lowercase: true, match: /^.+?@[^@]+$/
    username: type: String, required: true, unique: true, match: /^[\w]{4,48}$/
    password: type: String, required: true, select: false
    friends:  type: [ObjectId], ref: 'user'
  
  # The Group schema.
  Group: Schema
    author:  type: ObjectId, ref: 'user', required: true
    members: type: [ObjectId], ref: 'user'
  
  # The Entry schema.
  Entry: Schema
    author:       type: ObjectId, ref: 'user', required: true, index: true
    created:      type: Date, default: Date.now
    lastModified: type: Date, default: Date.now
    userShare:    type: [ObjectId], ref: 'user'
    groupShare:   type: [ObjectId], ref: 'group'
    publicShare:  type: Boolean, default: false
    title:        type: String, trim: true, match: /^[\w\s]{1,255}$/
    url:          type: String, index: true
    description:  type: String
    tags:         type: [ObjectId], ref: 'tag'
  
  # The Tag schema.
  Tag: Schema
    author: type: ObjectId, ref: 'user'
    title:  type: String, trim: true, match: /^[\w\s]{1,255}$/
    color:  type: String, match: /^[0-9A-F]{6}$/


##
## MIDDLEWARE
##

# Add user password hashing.
schemas.User.pre 'save', Auth.Middleware.hashPassword()


##
## MODELS
##

# Create and export models.
models = {mongoose}
models[key] = model key.toLowerCase(), schema for own key, schema of schemas
module.exports = models
