wifi.setmode(wifi.STATION)
wifi.sta.config({ssid=WIFI_SSID,pwd=WIFI_PASSWD})
wifi.sta.connect()
