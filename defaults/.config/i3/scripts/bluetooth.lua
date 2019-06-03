#!/usr/bin/lua

function tablelength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end

function connect_to(device)
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
	for i = 0, 10 do
		local rc = os.execute("bluetoothctl -- connect " .. device)
		if rc == true then
			return true
		end
	end

	print('\tFailed to connect')
	return false
end

function disconnect_from(device)
	if device == nil then
		return false
	end

	print('==> Disconnecting from ' .. device)
	for i = 0, 10 do
		local rc = os.execute("bluetoothctl -- disconnect " .. device)
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

function main()
	local len = tablelength(arg) - 2

	if len < 1 then
		print('Please specify which bluetooth to connect')
		return
	end

	local input = arg[1]

	print(input)
	if input == "w" then
		connect_to("04:5D:4B:EA:9C:B2")
	elseif input == "W" then
		disconnect_from("04:5D:4B:EA:9C:B2")
	else
		print('Unrecognized command')
	end
end

main()
