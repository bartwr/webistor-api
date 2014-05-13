path = require 'path'
util = require 'util'
config = require '../_config'
Mail = require '../../src/classes/mail'
BatchMail = require '../../src/classes/batch-mail'

# Test the parent class first.
require './mail'

Mail.TEMPLATE_DIRECTORY = path.resolve __dirname, '../templates/mail'

onSuccess = (callback) -> (err, args...) ->
  console.log err if err
  throw err if err
  callback? args...

describe "BatchMail", ->

  describe "::batch", ->

    it "should set a batch handler function", ->

      mail = (new BatchMail).batch (recipient) ->
        recipient.must.be "test"
        return recipient

      mail._batch.must.be.a Function
      mail._batch('test').must.be 'test'


  describe "templating", ->

    it "should be able to generate batch-handler from templates", (done) ->

      mail = new BatchMail
      mail2 = new Mail

      mail.generate 'test-both', (recipient) ->
        this.must.be mail2
        return {body:"You are #{recipient}!"}

      .then ->
        mail._batch.must.be.a Function
        mail._batch.call(mail2, 'test').then ->
          mail2._text.must.contain "**You are test!**"

      .done done

  describe.skip "sending", ->

    it "should execute batch script and send individual mails", (done) ->

      @timeout 1000*60*5
      @slow 1000*10

      mail = (new BatchMail)
      .from 'bob'
      .to ['aldwin.vlasblom@gmail.com', 'aldwin@tuxion.nl', 'doomed-to-fail']
      .batch (recipient) ->
        @subject "Dear #{recipient}"
        @body "This is a test mail"
      .send()
      .then (result) ->
        result.done.must.have.length 2
        result.done[0].email.must.be 'aldwin.vlasblom@gmail.com'
        result.done[0].value.must.have.property 'messageId'
        result.failed.must.have.length 1
        result.failed[0].email.must.be 'doomed-to-fail'
        result.failed[0].must.have.property 'error'
      .done -> done()