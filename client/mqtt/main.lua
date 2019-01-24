-------------
-- MQTT

-- Create a client
m = mqtt.Client(MQTT_CLIENT_ID, MQTT_KEEPALIVE, MQTT_CLIENT_ID, MQTT_API_SECRET, true, 1024)

function ping_topic()
	return MQTT_PING_TOPIC_BASE .. "/" .. MQTT_CLIENT_ID
end

function pong_topic()
	return MQTT_PONG_TOPIC_BASE .. "/" .. MQTT_CLIENT_ID
end

function mqtt_log(msg)
	print("LOG " .. msg)
	mqtt_publish(MQTT_LOG_TOPIC, msg)
end

function mqtt_on_offline(m, t, pl)
	print("MAIN: Offline! Reconnecting MQTT...")
	tmr.alarm(CONNECT_TIMER, CONNECT_DELAY, tmr.ALARM_AUTO, connect_mqtt)
end

function mqtt_on_connect_failure(client, reason)
	print("MQTT connect failed: " .. reason)
	tmr.alarm(CONNECT_TIMER, CONNECT_DELAY, tmr.ALARM_AUTO, connect_mqtt)
end

function mqtt_shim_on_message(m, t, pl)
  print("Topic: ", t, ", Message: ", pl)
	if t == ping_topic() then
		print("Handling ping...")
		mqtt_publish(pong_topic(), {state=true})
	else
		if sjson then
			ok, pl_table = pcall(sjson.decode, pl)
		elseif cjson then
			ok, pl_table = pcall(cjson.decode, pl)
		end
		mqtt_on_message(m, t, pl, pl_table)
	end
end

function mqtt_connected(client)
	print("mqtt connected; stopping connect timer.")
	-- Serial status message
	print ("\n\n", MQTT_CLIENT_ID, " connected to MQTT host ", MQTT_HOST,
		" on port ", MQTT_PORT, "\n\n")
	-- publish boot message
	m:publish(MQTT_BOOT_TOPIC, MQTT_CLIENT_ID, MQTT_QOS, 0,	function(m) 
		print("Published on ", MQTT_BOOT_TOPIC, ".")
	end)
	-- publish lwt
	m:lwt(MQTT_LWT_TOPIC, MQTT_CLIENT_ID, 0, 0)
	-- subscribe for pings
	if MQTT_PING_PONG_ENABLED then
		print("Subscribing to " .. ping_topic() .. " for pings...")
		m:subscribe(ping_topic(), MQTT_QOS, function(m) print("Subscribed to " .. ping_topic() .. " for pings") end)
	end
	-- subscribe to configured topics
	for x,t in pairs(MQTT_SUB_TOPICS) do
		print("Subscribing to ", t, "...")
			m:subscribe(t, MQTT_QOS, function(m) print("Subscribed to ", t) end)
	end
	-- app must define handler
	mqtt_on_connect()
end

-- connect mqtt if we have an ip
function connect_mqtt()
	ip = wifi.sta.getip()
	print("IP: ", ip)
	if ip then
		if not tmr.stop(CONNECT_TIMER) then
			print('Unable to stop timer ', CONNECT_TIMER)
		end

		if CONNCHECK then
			print("Starting conncheck timer...")
			tmr.alarm(CONNCHECK_TIMER, CONNCHECK_DELAY, 1, conncheck)
		end

		print("Connecting MQTT...", MQTT_HOST, MQTT_PORT, MQTT_SECURE)
		-- m:on("connect", mqtt_connected)
		m:connect(MQTT_HOST, MQTT_PORT, MQTT_SECURE, mqtt_connected, mqtt_on_connect_failure)
		-- m:connect(MQTT_HOST, MQTT_PORT, MQTT_SECURE)
	end
end

-- apps should use this to encode tables for publishing
function encode_for_publish(data)
	data['clientid'] = MQTT_CLIENT_ID
	if sjson then
		ok, msg = pcall(sjson.encode, data)
	elseif cjson then
		ok, msg = pcall(cjson.encode, data)
	else
		print("ERROR: neither `sjson` nor `cjson` available; can't encode data for publishing!")
		return false
	end
	if ok then
		print("Encoded data as:")
		print(msg)
		return msg
	else
		print("Unable to encode: " .. table.concat(data, " "))
		return nil
	end
end

-- apps should use this to publish, by passing a string msg
function mqtt_publish_encoded(topic, msg, qos, retain, callback)
	if not qos then
		qos = MQTT_QOS
	end
	if not retain then
		retain = MQTT_RETAIN
	end
	if not callback then
		callback = mqtt_on_publish
	end
	m:publish(topic, msg, qos, retain, callback)
end

-- backwarfs compatibility
function mqtt_publish(topic, data, qos, retain, callback)
	if not (type(data) == "table") then
		tbl = {}
		tbl["msg"] = data
		data = tbl
	end
	msg = encode_for_publish(data)
	if msg then
		mqtt_publish_encoded(topic, msg, qos, retain, callback)
	else
		print("Encoding failed; not publishing.")
	end
end

------
-- lib

function print_table(t)
	for key,value in pairs(t) do print("-> ",key,value) end
end

-------------------
-- Connection check
function conncheck()
	print("Checking connection...")
	http.get(CONNCHECK_URL, nil, function(code, data)
	    if (code < 0) then
			print("HTTP request failed; offline...")
			mqtt_on_offline()
		else
			print(code, data)
		end
	end)
	m:publish(MQTT_LOG_TOPIC, '{"msg":"conncheck","clientid":"' .. MQTT_CLIENT_ID .. '"}', MQTT_QOS, 0, function(m) print("sent ping") end)
end

-----
-- Go
if MQTT_SECURE == 1 then
	print("Setting CA cert...")
	tls.cert.verify(MQTT_CA_CERT)
	tls.cert.verify(true)
else
	print("Not using secure MQTT connection; not setting cert.")
end

print("Starting connect timer...")
tmr.alarm(CONNECT_TIMER, CONNECT_DELAY, tmr.ALARM_AUTO, connect_mqtt)
