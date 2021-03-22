#!/usr/bin/luajit

local function tablelength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end

local function _exec(cmd)
  cmd = cmd .. ' 2>&1&'
  local file, err = io.popen(cmd)
  if file == nil then
    print('Command ' .. cmd .. ' failed')
    print('\t' .. err)
    return ''
  end
  local output = file:read('*all')
  file:close()
  return output
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
	local rc = _exec("bluetoothctl -- power on")
  if string.find(rc, "succeeded") == nil then
		msg_error('Failed to power on')
		return false
	end

  msg('Connecting to ' .. device)
	for _ = 0, 10 do
		rc =  _exec("bluetoothctl -- connect " .. device)
    if string.find(rc, "successful") ~= nil then
      msg("Connected")
			return true
		end
    os.execute("sleep 1")
	end

	msg_error('Failed to connect')
	return false
end

local function disconnect()
	msg('Disconnecting')
	for _ = 0, 10 do
		local rc = _exec("bluetoothctl -- disconnect")
		if string.find(rc, "Successful") ~= nil then
			break
		end
	end

	msg('Unpowering bluetooth')
	local rc = _exec("bluetoothctl -- power off")
	if string.find(rc, "succeeded") == nil then
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

  local rc = _exec("systemctl is-active 'bluetooth.service'")
  if string.find(rc, "active") == nil then
    msg_error("Bluetooth service is not active")
    return
  end

	if input == "connect" then
		connect_to(device)
	elseif input == "disconnect" then
		disconnect()
	else
		msg_error('Unrecognized command')
	end
end

main()
