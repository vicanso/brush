program = require 'commander'
do ->
  program.version('0.0.1')
  .option('-p, --port <n>', 'listen port', parseInt)
  .option('--log <n>', 'the log file')
  .parse process.argv

JTCluster = require 'jtcluster'
JTMonitor = require 'jtmonitor'
logger = require('./helpers/logger') __filename
slaveTotal = require('os').cpus().length - 1

options = 
  # 检测的时间间隔
  interval : 60 * 1000
  # worker检测的超时值
  timeout : 5 * 1000
  # 连续失败多少次后重启
  failTimes : 5
  slaveTotal : require('os').cpus().length - 1
  slaveHandler : ->
    jtApp = require 'jtapp'
    path = require 'path'
    setting = 
      launch : [
        __dirname
      ]
      middleware : 
        mount : '/healthchecks'
        handler : ->
          (req, res) ->
            res.end 'success'
      port : program.port || 10000
    jtApp.init setting, (err, app) ->
      logger.error if err


  beforeRestart : (cbf) ->
    logger.info 'the server will be restart!'
    GLOBAL.setImmediate ->
      cbf null
if process.env.NODE_ENV == 'production'
  jtCluster = new JTCluster
  jtCluster.start options
  jtCluster.on 'error', (err) ->
    logger.error err if err
  jtCluster.on 'log', (log) ->
    logger.info log if log
else
  options.slaveHandler()

