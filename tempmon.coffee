sensor = require 'ds18x20'
cfg    = require './conf/cfg.tempmon.json'

DEBUG = if cfg.verbose then true else false
available_sensors = []

init = () ->
  # initialize the temperature sensor
  sensor.isDriverLoaded (err, isLoaded)->
    if not isLoaded
      if DEBUG
        console.log "w1-gpio drivers are not loaded, try to load them immediately."
      try
        sensor.loadDriver()
      catch err
        console.error "Failed to load the driver: " + err
        console.error "You may need to load them manually before start this program, or run this program with root access."
        exit 1
    else
      if DEBUG
        console.log "w1-gpio drivers are loaded correctly."
    available_sensors = sensor.list()
    if DEBUG
      console.log "Available sensors:" + available_sensors

init()
