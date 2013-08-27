(->
  #load packaged application configuration
  require ['config'], (config) ->
    #execute when the application is launched
    #draw window and graph
    onLaunch = (window) ->
      #window.contentWindow.addEventListener 'load', ->
      window.contentWindow.onload = ->
        #load the memory module
        require ['memory'], (Memory) ->
          #get document object
          canvas = window.contentWindow.document.getElementById('memory')

          #create a smoothie chart object
          smoothie = new window.contentWindow.SmoothieChart({
            grid: config.grid,
            labels: config.labels,
            yRangeFunction: ->
              return { min: 0, max: 100 }
          })

          #create tracking line
          percentage = new TimeSeries()

          #stream to the canvas memory element
          smoothie.streamTo canvas, config.delay

          #add the line to the graph
          smoothie.addTimeSeries percentage, config.line

          #create the memory object
          memory = new Memory (info) ->
            #get current timestamp
            epoch = new Date().getTime()
            #calculate percentage of usage
            percentage.append epoch, (100 / info.capacity) * info.available

          #start polling memory stats
          memory.start config.delay

    #app launched, display UI panels
    chrome.app.runtime.onLaunched.addListener ->
      chrome.app.window.create 'index.html', config.panel, onLaunch

).call @