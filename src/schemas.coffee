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
    username: type: String, required: true, unique: true, index:true, lowercase: true, validate: [
      /^[\w-_]{4,48}$/
      "Username must be between 4 and 48 characters and only contain letters, numbers dashes and underscores."
    ]
    password: type: String, required: true, select: false, validate: [
      /^.{4,128}$/, "Password must be between 4 and 128 characters."
    ]
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
    title:        type: String, trim: true, validate: [
      /^.{0,255}$/, "The entry title can not be longer than 255 characters."
    ]
    url:          type: String
    description:  type: String
    tags:         type: [ObjectId], ref: 'tag'

  # The Tag schema.
  Tag: Schema
    author: type: ObjectId, ref: 'user', index: true
    title:  type: String, trim: true, validate: [
      /^.{1,48}$/, "A tag must contain between one and 48 characters."
    ]
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
schemas.Tag.index {title:'text'}, {default_language: 'en'}

# This method can be relied upon to return the actual number of entries.
schemas.Tag.method 'countEntries', (cb) -> @model('tag').count {tags:@id}, cb

##
## MODELS
##

# Create and export models.
models = {mongoose}
models[key] = model key.toLowerCase(), schema for own key, schema of schemas
module.exports = models
