fs = require 'fs'
path = require 'path'
_ = require 'underscore'
logger = require('./helpers/logger') __filename

getStaticConfig = ->
  if isProductionMode
    staticMaxAge = 48 * 3600 * 1000
    staticVersion = fs.readFileSync path.join __dirname, '/version'
    convertExts = 
      src : ['.coffee', '.styl']
      dst : ['.js', '.css']
  config =
    path : "#{__dirname}/statics"
    urlPrefix : '/static'
    mergePath : "#{__dirname}/statics/temp"
    mergeUrlPrefix : 'temp'
    maxAge : staticMaxAge
    version : staticVersion
    convertExts : convertExts
    headers : 
      'v-ttl' : '1800s'
    mergeList : [
      ['/javascripts/utils/underscore.js', '/javascripts/utils/async.js']
    ]

isProductionMode = process.env.NODE_ENV == 'production'


config = 
  init : (app) ->
    logger.info "server is running..."
  static : getStaticConfig()
  express : 
    set : 
      'view engine' : 'jade'
      'trust proxy' : true
      views : "#{__dirname}/views"
  route : ->
    require './routes'


module.exports = config

