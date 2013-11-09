_ = require 'underscore'
async = require 'async'
mongodb = require './mongodb'
moment = require 'moment'

pageContentHandler = 
  index : (req, res, cbf) ->
    
    async.waterfall [
      (cbf) ->
        mongodb.model('wardrobe').find {type : 'http'}, null, {limit : 100}, cbf
      (docs, cbf) ->
        cbf null, {
          title : 'brush后台管理'
          viewData : 
            typeList : ['mongodb', 'http', 'monitor']
            today : moment().format 'YYYY-MM-DD'
            projects : mongodb.getDBList()
        }
    ], cbf

  statistics : (req, res, cbf) ->
    data = req.body
    start = moment(data.date[0], 'YYYY-MM-DD').valueOf()
    end = moment(data.date[1], 'YYYY-MM-DD').valueOf()
    if start > end
      tmp = start
      start = end
      end = tmp
    end += 24 * 3600 * 1000
    start = new Date start
    end = new Date end
    app = data.app
    type = data.type
    async.waterfall [
      (cbf) ->
        query = 
          type : type
          date : 
            '$gt' : start
            '$lt' : end
        mongodb.model(app).find query, cbf
      (docs, cbf) ->
        docs = _.map docs, (item) ->
          item.toObject()
        cbf null, getStatisticsData docs
        # console.dir docs.length
        # return 
        # splitSecond = 10
        # result = _.countBy docs, (item) ->
        #   Math.floor(item.elapsedTime / splitSecond) * splitSecond
        # console.dir result
        # cbf null, {
        #   xAxis : _.keys result
        #   series : [
        #     {
        #       name : 'HTTP'
        #       data : _.values result
        #     }
        #   ]
        # }
    ], cbf

getStatisticsData = (docs) ->
  firstItem = _.first docs
  result = {}
  if firstItem
    result.elapsedTime = getElapsedTime docs if firstItem.elapsedTime
    result.statusCode = getStatusCode docs if firstItem.statusCode
    result.frequency = getOccurrenceFrequency docs if firstItem.params
    result.slowest = getSlowest docs if firstItem.elapsedTime
    result.distributionCurve = getDistributionCurve docs
  result

getOccurrenceFrequency = (docs, max = 100) ->

  getName = (item) ->
    if item.type == 'mongodb'
      "#{item.collection}  #{item.method}  #{item.params}"
    else
      "#{item.method}  #{item.params}"
  frequency = _.countBy docs, (item) ->
    getName item 
  result = []
  _.each frequency, (times, name) ->
    result.push {name : name, times : times}
  result = _.sortBy result, (item) ->
    -item.times
  result.length = max if result.length > max
  result

getElapsedTime = (docs, splitSecond = 30) ->
  elapsedTimeList = _.uniq _.map docs, (item) ->
    Math.ceil(item.elapsedTime / splitSecond) * splitSecond
  elapsedTimeList = _.sortBy elapsedTimeList, (item) ->
    item
  groupByData = _.groupBy docs, (item) ->
    moment(item.date).format 'YYYY-MM-DD'
  series = []
  _.each groupByData, (value, key) ->
    countByResult = _.countBy value, (item) ->
      Math.ceil(item.elapsedTime / splitSecond) * splitSecond
    result = _.map elapsedTimeList, (elapsedTime) ->
      countByResult[elapsedTime]
    series.push {
      name : key
      data : result
    }
  {
    categories : elapsedTimeList
    series : series
  }

getStatusCode = (docs) ->
  statusCodeList = _.uniq _.pluck docs, 'statusCode'
  groupByData = _.groupBy docs, (item) ->
    moment(item.date).format 'YYYY-MM-DD'
  series = []
  _.each groupByData, (value, key) ->
    countByResult = _.countBy value, (item) ->
      item.statusCode
    result = _.map statusCodeList, (statusCode) ->
      countByResult[statusCode]
    series.push {
      name : key
      data : result
    }
  {
    categories : statusCodeList
    series : series
  }

getSlowest = (docs, max = 100) ->
  getName = (item) ->
    if item.type == 'mongodb'
      "#{item.collection}  #{item.method}  #{item.params}"
    else
      "#{item.method}  #{item.params}"

  docs = _.sortBy docs, (item) ->
    -item.elapsedTime
  docs.length = max if docs.length > max
  docs = _.map docs, (item) ->
    {
      name : getName item
      elapsedTime : item.elapsedTime
    }
getDistributionCurve = (docs) ->
  groupByData = _.groupBy docs, (item) ->
    moment(item.date).format 'YYYY-MM-DD'
  series = []
  countByResultList = []
  indexList = []
  _.each groupByData, (value, key) ->
    date = moment(key, 'YYYY-MM-DD').valueOf()
    offset = 10 * 60 * 1000
    countByResult = _.countBy value, (item) ->
      Math.floor (item.date.getTime() - date) / offset
    indexList.push _.keys countByResult
    countByResultList.push {
      date : key
      data : countByResult
    }
  indexList = _.uniq _.flatten indexList
  indexList = _.sortBy indexList, (index) ->
    +index
  _.each countByResultList, (countByResult) ->
    data = countByResult.data
    result = _.map indexList, (index) ->
      data[index]
    series.push {
      name : countByResult.date
      data : result
    }
  categories = _.map indexList, (index) ->
    index *= 10
    hours = Math.floor index / 60
    minutes = index % 60
    if hours < 10
      hours = '0' + hours
    if minutes < 10
      minutes = '0' + minutes
    "#{hours}:#{minutes}"
  {
    categories : categories
    series : series
  }




module.exports = pageContentHandler