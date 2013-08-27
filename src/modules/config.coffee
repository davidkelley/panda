define [], ->

  configuration =
    #memory poll interval
    delay: 1000
    #UI grid display styling
    grid:
      fillStyle: 'rgba(255,255,255,1)',
      strokeStyle: 'rgba(0,0,0,.2)',
      verticalSections: 10,
      millisPerLine: 180
    #UI grid labels styling
    labels:
      fillStyle: 'rgba(0,0,0,1)'
    #UI grid line styling
    line:
      fillStyle: '#CCCCCC',
      strokeStyle: 'rgba(0,0,0,1)',
      lineWidth: 3
    #display properties of the UI windows
    panel:
      bounds:
        width: 400,
        height: 100
      resizable: false


  #return the configuration object from the module
  return configuration