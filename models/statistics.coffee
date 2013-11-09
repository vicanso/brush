module.exports = 
  schema : 
    type : 
      type : String
      require : true
      index : true
    date : 
      type : Date
      require : true
      index : true
    elapsedTime :
      type : Number
      require : true
      index : true
  options :
    strict : false