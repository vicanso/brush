JTMongoose = require 'jtmongoose'
_ = require 'underscore'
path = require 'path'
logger = require('./logger') __filename


clients = {}



mongodb =
  model : (dbName) ->
    client = clients[dbName]
    if !client
      throw new Error 'must be call init function before use model'
      return 
    client.model 'Statistics'
  getDBList : ->
    _.keys clients

init = (dbs) ->
  _.each dbs, (uri, name) ->
    options =
      db : 
        native_parser : true
      server :
        poolSize : 2
    client = new JTMongoose uri, options
    client.initModels path.join __dirname, '../models'
    clients[name] = client
    client.on 'log', (data) ->
      logger.info "db:#{name} #{data.method}"

init require '../dbs'


module.exports = mongodb  

