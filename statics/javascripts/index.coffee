$ = window.jQuery
_ = window._

$ ->
  # getStatisticsData 'mongodb'
  initEvent()

initEvent = ->
  $('#contentContainer .projectsSelect .dropdown-menu').on 'click', 'a', ->
    obj = $ @
    $('#contentContainer .projectsSelect .dropdown-toggle .app').text obj.text()

  $('#contentContainer .typeSelect').on 'click', '.btn', ->
    obj = $ @
    if !obj.hasClass 'btn-primary'
      obj.siblings('.btn-primary').add(obj).toggleClass 'btn-primary'

  $('#contentContainer .monitorViewOptions .go').click ->
    getStatisticsData()


  startDatePicker = $ '#contentContainer .monitorViewOptions .datePicker.start'
  endDatePicker = $ '#contentContainer .monitorViewOptions .datePicker.end'
  datePickerOptions =
    format : 'yyyy-mm-dd'
  startDatePicker.datepicker(datePickerOptions).on 'changeDate', ->
    startDatePicker.data('datepicker').hide()
  endDatePicker.datepicker(datePickerOptions).on 'changeDate', ->
    endDatePicker.data('datepicker').hide()

getQuery = ->
  errors = []
  types = _.map $('#contentContainer .monitorViewOptions .typeSelect .btn-primary'), (item) ->
    $(item).text()
  # errors.push '未选择类型' if types.length
  options =
    type : $('#contentContainer .monitorViewOptions .typeSelect .btn-primary').text()
    app : $('#contentContainer .projectsSelect .dropdown-toggle .app').text()
    date : [$('#contentContainer .monitorViewOptions .datePicker.start').val(), $('#contentContainer .monitorViewOptions .datePicker.end').val()]



convertElapsedTimeOptions = (data) ->
  options = {
    title : 
      text : '后台统计'
      x : -20
    subtitle :
      text : '大树工作室-墨鱼(耗时统计)'
      x : -20
    xAxis : 
      categories : data.categories
    yAxis : 
      title : 
        text : '总数量'
      plotLines : [
        {
          value : 0
          width : 1
          color: '#808080'
        }
      ]
    tooltip : 
      valueSuffix : '个'
    legend : 
      layout : 'vertical'
      align : 'right'
      verticalAlign : 'middle'
      borderWidth : 0
    series : data.series
  }

convertDistributionCurveOptions = (data) ->
  options = {
    title : 
      text : '后台统计'
      x : -20
    subtitle :
      text : '大树工作室-墨鱼(分布统计)'
      x : -20
    xAxis : 
      categories : data.categories
    yAxis : 
      title : 
        text : '总数量'
      plotLines : [
        {
          value : 0
          width : 1
          color: '#808080'
        }
      ]
    tooltip : 
      valueSuffix : '个'
    legend : 
      layout : 'vertical'
      align : 'right'
      verticalAlign : 'middle'
      borderWidth : 0
    series : data.series
  }

convertStatusCode = (data) ->
  options =
    title : 
      text : '后台统计'
      x : -20
    subtitle :
      text : '大树工作室-墨鱼(HTTP状态统计)'
      x : -20
    chart : 
      type : 'column'
    xAxis : 
      categories : data.categories
    yAxis : 
      title : 
        text : '总数量'
    tooltip : 
      valueSuffix : '个'
    plotOptions :
      column :
        pointPadding : 0.2
        borderWidth : 0
    series : data.series
    

getFrequencyTable = (data) ->
  htmlList = []
  htmlList.push '<h3 class="tac">次数统计表(出现次数最多的' + data.length + '条)</h3>'
  htmlList.push '<div class="tableView">'
  htmlList.push '<table class="table table-striped">'

  htmlList.push '<thead><tr><th style="width:90%">类别</th><th style="width:10%">出现次数</th></tr></thead>'
  htmlList.push '<tbody>'
  _.each data, (item) ->
    htmlList.push "<tr><td>#{item.name}</td><td>#{item.times}</td></tr>"

  htmlList.push '</tbody>'
  htmlList.push '</table>'
  htmlList.push '</div>'
  htmlList.join ''

getSlowestTable = (data) ->
  htmlList = []
  htmlList.push '<h3 class="tac">耗时统计表(耗时最长的' + data.length + '条)</h3>'
  htmlList.push '<div class="tableView">'
  htmlList.push '<table class="table table-striped">'

  htmlList.push '<thead><tr><th style="width:90%">类别</th><th style="width:10%">耗时(ms)</th></tr></thead>'
  htmlList.push '<tbody>'
  _.each data, (item) ->
    htmlList.push "<tr><td>#{item.name}</td><td>#{item.elapsedTime}</td></tr>"

  htmlList.push '</tbody>'
  htmlList.push '</table>'
  htmlList.push '</div>'
  htmlList.join ''

getStatisticsData =  ->
  $.ajax({
    url : "/statistics"
    type : 'post'
    dataType : 'json'
    data : getQuery()
  }).success((res) ->
    chartList = $('#chartList').empty()
    if res.elapsedTime
      elapsedTimeOptions = convertElapsedTimeOptions res.elapsedTime
      chart = $('<div class="chart" />').appendTo chartList
      chart.highcharts elapsedTimeOptions
    if res.statusCode
      statusCodeOptions = convertStatusCode res.statusCode
      chart = $('<div class="chart" />').appendTo chartList
      chart.highcharts statusCodeOptions
    if res.distributionCurve
      distributionCurveOptions = convertDistributionCurveOptions res.distributionCurve
      chart = $('<div class="chart" />').appendTo chartList
      chart.highcharts distributionCurveOptions

    if res.frequency
      table = $('<div class="tableContainer" />').appendTo chartList
      table.html getFrequencyTable res.frequency
    if res.slowest
      table = $('<div class="tableContainer" />').appendTo chartList
      table.html getSlowestTable res.slowest
  ).error (res) ->
