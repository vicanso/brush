config = require '../config'
pageContentHandler = require '../helpers/page_content_handler'


routeInfos = [
  {
    route : '/'
    template : 'index'
    handler : pageContentHandler.index
  }
  {
    route : '/statistics'
    type : 'post'
    handler : pageContentHandler.statistics
  }
]

module.exports = routeInfos