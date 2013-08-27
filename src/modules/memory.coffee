define ['system'], (system) ->

  #create prototype to convert bytes to megabytes
  Number.prototype.toMB = ->
    return (@/1024/1024).toFixed(2)

  class Memory
    #construct the memory class
    constructor: (@update) ->

    #grab chrome system memory or empty object
    memory: system.memory or {}

    #start polling chrome memory statistics at @interval
    start: (@interval) ->
      #set polling interval
      @intervalID = setInterval =>
        #call chrome memory api
        @memory.getInfo (info) =>
          #set data for latest poll
          @data =
            capacity: info.capacity.toMB(),
            available: info.availableCapacity.toMB()

          #callback
          @update @data if typeof @update is "function"
      #poll for data at interval
      , @interval

    #get the last polled stats
    last: ->
      @data

    #modify the callback object for polling
    onUpdate: (@update) ->

    #stop polling for memory statistics
    stop: ->
      #clear the interval
      clearInterval @intervalID

  #return the Memory class object
  return Memory