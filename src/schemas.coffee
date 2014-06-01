{mongoose, model} = require 'node-restful'
{Schema} = mongoose
{ObjectId} = Schema.Types
Auth = require './classes/auth'
config = require './config'
validateEmail = require 'rfc822-validate'

##
## SCHEMA DEFINITIONS
##

# Export Schemas.
schemas =

  # The User schema.
  User: Schema
    email:    type: String, required: true, unique: true, index: true, lowercase: true, validate: [
      validateEmail, "given email address is not valid"
    ]
    username: type: String, required: true, unique: true, index:true, lowercase: true, match: /^[\w-_]{4,48}$/
    password: type: String, required: true, select: false, match: /^.{4,128}$/
    friends:  type: [ObjectId], ref: 'user'

  # The Invitation schema.
  Invitation: Schema
    email:   type: String, required: true, unique: true, index: true, lowercase: true, validate: [
      validateEmail, "given email address is not valid"
    ]
    created: type: Date, default: Date.now
    status:  type: String, enum: ['awaiting', 'accepted', 'registered'], default: 'awaiting'
    author:  type: ObjectId, ref: 'user'
    user:    type: ObjectId, ref: 'user'
    token:   type: String, select: false

  # The Group schema.
  Group: Schema
    author:  type: ObjectId, ref: 'user', required: true, index: true
    members: type: [ObjectId], ref: 'user'

  # The Entry schema.
  Entry: Schema
    author:       type: ObjectId, ref: 'user', required: true, index: true
    created:      type: Date, default: Date.now
    lastModified: type: Date, default: Date.now
    userShare:    type: [ObjectId], ref: 'user'
    groupShare:   type: [ObjectId], ref: 'group'
    publicShare:  type: Boolean, default: false
    title:        type: String, trim: true, match: /^.{1,255}$/
    url:          type: String
    description:  type: String
    tags:         type: [ObjectId], ref: 'tag'

  # The Tag schema.
  Tag: Schema
    author: type: ObjectId, ref: 'user', index: true
    title:  type: String, trim: true, match: /^[\w\s]{1,255}$/
    color:  type: String, match: /^[0-9A-F]{6}$/
    # Warning! The following property can stale and should therefore not be relied upon.
    num:    type: Number, default: 0


##
## EXTRA
##

# Add user password hashing middleware.
schemas.User.pre 'save', Auth.Middleware.hashPassword()

# Get the number of invitations sent by this user.
schemas.User.method 'countInvitations', (cb) -> @model('invitation').count {author:this}, cb

# Add text indexes for text-search support.
schemas.Entry.index {title:'text', description:'text'}, {default_language: 'en'}

# This method can be relied upon to return the actual number of entries.
schemas.Tag.method 'countEntries', (cb) -> @model('tag').count {tags:@id}, cb

##
## MODELS
##

# Create and export models.
models = {mongoose}
models[key] = model key.toLowerCase(), schema for own key, schema of schemas
module.exports = models
