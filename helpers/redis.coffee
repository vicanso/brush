jtRedis = require 'jtredis'

redis = 
  init : (setting) ->
    jtRedis.configure setting
  getClient : (name) ->
    jtRedis.getClient name
module.exports = redis