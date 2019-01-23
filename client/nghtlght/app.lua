----------------
-- mqtt handlers
function mqtt_on_connect()
  print("app.lua: connected")
end

function mqtt_on_message(m, t, pl, pl_table)
  if not pl_table then
    mqtt_log("Couldn't read table from msg; ignoring...")
    return
  end

  if pl_table['colour'] then
    led_state['colour'] = pl_table['colour']
  end

  if pl_table['brightness'] then
    led_state['brightness'] = pl_table['brightness']
  end

  print(unpack(led_state))
  update_leds(led_state)

  print(unpack(led_state))
  mqtt_publish(MQTT_PUB_TOPIC, led_state)
end

function mqtt_on_publish(m)
end

------
-- lib

function update_leds(state)
  raw_colour = map_rgb_to_grb(balance_colour(state['colour']))
  print(unpack(raw_colour))
  print(unpack(get_led_values_from_colour(raw_colour)))
  ws2812.write(string.char(unpack(get_led_values_from_colour(raw_colour))))

  memcheck()
end

function get_led_values_from_colour(colour)
  values = {}
  for i=1, NUM_LEDS do
    for j=1, #colour do
      table.insert(values, colour[j])
    end
  end
  return values
end

function map_rgb_to_grb(colour)
  mapped_colour = {}
  for i=1, #colour, 3 do
    mapped_colour[i] = colour[i+1]
    mapped_colour[i+1] = colour[i]
    mapped_colour[i+2] = colour[i+2]
  end
  return mapped_colour
end

function balance_colour(colour)
  balanced_colour = {}
  for i=1, #colour do
    balanced_colour[i] = colour[i] * COLOUR_BALANCE_FACTORS[(i%3)+1]
  end
  return balanced_colour
end

function memcheck()
  print(node.heap())
end

function init()
  ws2812.init(ws2812.MODE_SINGLE)
  update_leds(led_state)
  if MEMCHECK then
    tmr.alarm(MEMCHECK_TIMER, MEMCHECK_DELAY, tmr.ALARM_AUTO, memcheck)
  end
end

-------
-- main
led_state = LED_STATE
init()
