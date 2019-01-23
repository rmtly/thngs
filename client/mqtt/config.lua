-- required by init.lua
FILES = {"config_app", "pre", "main", "wifi", "app", "post"}

-----------------------
-- required by main.lua
MQTT_HOST = "thngs.rmtly.com"
MQTT_PORT = 1883
MQTT_SECURE = 0
MQTT_CA_CERT = [[
]]
MQTT_QOS = 2
MQTT_RETAIN = 1
MQTT_KEEPALIVE = 60

MQTT_BOOT_TOPIC_BASE = "/boot"
MQTT_LWT_TOPIC_BASE = "/lwt"
MQTT_LOG_TOPIC_BASE = "/log"
MQTT_PING_TOPIC_BASE = "/ping"
MQTT_PONG_TOPIC_BASE = "/pong"
MQTT_PING_PONG_ENABLED = true

-- timer to retry mqtt connection
CONNECT_TIMER = 1
CONNECT_DELAY = 5000
-- timer to check connection
CONNCHECK = false
CONNCHECK_TIMER = 2
CONNCHECK_DELAY = 60000
CONNCHECK_HOST = "mqtt"
CONNCHECK_URL = "http://" .. CONNCHECK_HOST .. "/ping.json"
-- timer to print memory stats
MEMCHECK = false
MEMCHECK_TIMER = 3
MEMCHECK_DELAY = 60000
