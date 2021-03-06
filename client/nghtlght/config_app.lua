
-- app config
MQTT_CLIENT_ID_BASE = "nghtlght_"
MQTT_TOPIC_BASE = "/dev/nghtlght"

-- calculate all the mqtt things
MQTT_CLIENT_ID = MQTT_CLIENT_ID_BASE .. node.chipid()
print("Client ID is ===[ " .. MQTT_CLIENT_ID .. " ]===")
MQTT_BOOT_TOPIC = MQTT_BOOT_TOPIC_BASE .. "/" .. MQTT_CLIENT_ID
MQTT_LWT_TOPIC = MQTT_LWT_TOPIC_BASE .. "/" .. MQTT_CLIENT_ID
MQTT_LOG_TOPIC = MQTT_LOG_TOPIC_BASE .. "/" .. MQTT_CLIENT_ID
MQTT_SUB_TOPIC_DEVTYPE = MQTT_TOPIC_BASE .. "/cmd"
MQTT_SUB_TOPIC_DEVICE = MQTT_SUB_TOPIC_DEVTYPE .. "/" .. MQTT_CLIENT_ID
MQTT_SUB_TOPICS = {
  MQTT_SUB_TOPIC_DEVTYPE,
  MQTT_SUB_TOPIC_DEVICE
}
MQTT_PUB_TOPIC = MQTT_TOPIC_BASE .. "/state/" .. MQTT_CLIENT_ID

-- initial config for lights
NUM_LEDS = 5
DEFAULT_COLOUR = {
  128, 128, 0
}
LED_BRIGHTNESS = 128
LED_STATE = {
  colour=DEFAULT_COLOUR,
  brightness=LED_BRIGHTNESS
}
COLOUR_BALANCE_FACTORS = {
  1,
  0.5,
  0.2
}

