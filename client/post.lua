-- set app handlers for mqtt events
m:on("offline", mqtt_on_offline)
m:on("message", mqtt_shim_on_message)
