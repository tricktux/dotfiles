#!/usr/bin/luajit

local function tablelength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end

local function connect_to(device)
	if device == nil then
		return false
	end

	print('==> Powering on bluetooth')
	local rc = os.execute("bluetoothctl -- power on")
	if rc == false then
		print('\tFailed to power on')
		return false
	end

	print('==> Connecting to ' .. device)
	for _ = 0, 10 do
		rc = os.execute("bluetoothctl -- connect " .. device)
		if rc == true then
			return true
		end
	end

	print('\tFailed to connect')
	return false
end

local function disconnect()
	print('==> Disconnecting')
	for _ = 0, 10 do
		local rc = os.execute("bluetoothctl -- disconnect")
		if rc == true then
			break
		end
	end

	print('==> Unpowering bluetooth')
	local rc = os.execute("bluetoothctl -- power off")
	if rc == false then
		print('\tFailed to power off')
		return false
	end
end

local function main()
	local len = tablelength(arg) - 2

	if len < 1 then
		print('Please specify which bluetooth to connect')
		return
	end

	local input = arg[1]
	local device = arg[2]

	if input == "connect" then
		connect_to(device)
	elseif input == "disconnect" then
		disconnect()
	else
		print('Unrecognized command')
	end
end

main()
