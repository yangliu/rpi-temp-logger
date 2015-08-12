sensor = require 'ds18x20'

init = () ->
  # initialize the temperature sensor
  sensor.isDriverLoaded (err, isLoaded)->
    if not isLoaded
      try
        sensor.loadDriver()
      catch err
        console.error "Failed to load the driver: " + err
        console.error "You may need to load them manually before start this program, or run this program with root access."
