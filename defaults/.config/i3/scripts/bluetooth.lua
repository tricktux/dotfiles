#!/usr/bin/luajit

local function tablelength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end

local function msg(content)
  os.execute("notify-send 'Bluetooth' '" .. content .. "'")
end

local function msg_error(content)
  os.execute("notify-send 'Bluetooth' '" .. content .. "' -u critical")
end

local function connect_to(device)
	if device == nil then
		return false
	end

	msg('Powering on bluetooth')
	local rc = os.execute("bluetoothctl -- power on")
	if rc == false then
		msg_error('Failed to power on')
		return false
	end

	msg('Connecting to ' .. device)
	for _ = 0, 10 do
		rc = os.execute("bluetoothctl -- connect " .. device)
		if rc == true then
			return true
		end
	end

	msg_error('Failed to connect')
	return false
end

local function disconnect()
	msg('Disconnecting')
	for _ = 0, 10 do
		local rc = os.execute("bluetoothctl -- disconnect")
		if rc == true then
			break
		end
	end

	msg('Unpowering bluetooth')
	local rc = os.execute("bluetoothctl -- power off")
	if rc == false then
		msg_error('Failed to power off')
		return false
	end
end

local function main()
	local len = tablelength(arg) - 2

	if len < 1 then
		msg_error('Please specify which bluetooth to connect')
		return
	end

	local input = arg[1]
	local device = arg[2]

	if input == "connect" then
		connect_to(device)
	elseif input == "disconnect" then
		disconnect()
	else
		msg_error('Unrecognized command')
	end
end

main()
