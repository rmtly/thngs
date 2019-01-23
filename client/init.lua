function startup()
	print("Loading config.lua...")
	dofile("config.lua")
	print("Loaded config.lua.")

	-- config.lua must define `FILES`
	for n,f in pairs(FILES) do
		filename = f .. ".lua"
		print("Looking for " .. filename .. "...")
		if file.exists(filename) then
			print("Found " .. filename .. "; loading...")
			dofile(filename)
		else
			print("No file named " .. filename .. "; skipping.")
		end
	end
end

-- wait a bit so we can flash this thing out of a restart loop
tmr.alarm(0, 3000, 0, startup)