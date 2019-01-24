function connect_error(err_num, string)
  print("EUS ERROR: " .. err_num .. " " .. string)
end

function connect_debug(string)
  print("EUS DEBUG: " .. string)
end

enduser_setup.start(connect_mqtt, connect_error, connect_debug)
