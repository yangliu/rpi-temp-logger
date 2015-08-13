ds18x20 = require 'ds18x20'
moment  = require 'moment'
cfg     = require './conf/cfg.tempmon.json'

DEBUG = if cfg.verbose then true else false
available_sensors = []
sensor_timers = []

logTemp = (desc, time, temp, cb) ->
  err = ""

  cb err
  true

init = () ->
  # initialize the temperature sensor
  ds18x20.isDriverLoaded (err, isLoaded)->
    if not isLoaded
      if DEBUG
        console.log "w1-gpio drivers are not loaded, try to load them immediately."
      try
        ds18x20.loadDriver()
      catch err
        console.error "Failed to load the driver: " + err
        console.error "You may need to load them manually before start this program, or run this program with root access."
        exit 1
    else
      if DEBUG
        console.log "w1-gpio drivers are loaded correctly."

    # get all available sensors
    available_sensors = ds18x20.list()
    if DEBUG
      console.log "Available sensors:" + available_sensors

    # Monitor all sensors in the config file
    for sensor in cfg.sensors
      if sensor.id not in available_sensors
        if DEBUG
          console.log "[Warning] Sensor \"" + sensor.id + "\" is not available."
        continue
      sensor_timers.push setInterval ->
        ds18x20.get sensor.id, (err, temp) ->
          now = moment()
          if err
            console.error "[Error] [" + now.format("YYYY-MM-DD HH:mm") + "] Failed to get temmperature from sensor \"" + sensor.id + "\""
          else
            if DEBUG
              console.log "[INFO] [" + now.format("YYYY-MM-DD HH:mm") + "] Sensor \"" + sensor.id + "\": " + temp + "'C."
            logTemp sensor.description, now.format("X"), temp, (err) ->
              if err
                console.error "[Error] Log sensor data failed: " + err
              else
                if DEBUG
                  console.log "[INFO] [" + now.format("YYYY-MM-DD HH:mm") + "] Sensor \"" + sensor.id + "\" data is logged successfully."
      , sensor.interval*1000

init()

# gracefully kill myself :P
process.on 'SIGINT', ->
  console.log "Shutting down Temperature monitoring daemon..."
  for timer in sensor_timers
    clearInterval timer
  console.log "Exiting..."
  process.exit()
