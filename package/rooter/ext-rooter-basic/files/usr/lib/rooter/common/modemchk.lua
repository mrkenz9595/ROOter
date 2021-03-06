#!/usr/bin/lua

local uvid = arg[1]
local upid = arg[2]
local dport = arg[3]
local cport = arg[4]

local modemfile = "/etc/config/modem.data"
local modemdata = {}
local count
local retval
local cretval

function process_line(xline, cnt)
	local data = {}
	local pline = xline
	local start = 1
	for i=1,3 do
		s, e = string.find(pline, " ")
		data[i] = string.sub(pline, start, s-1)
		pline = string.sub(pline, e+1)
	end
	data[4] = pline
	modemdata[cnt] = data
end

function read_modem()
	count = 0
	local file = io.open(modemfile, "r")
	if file == nil then
		return
	end
	repeat
		local line = file:read("*line")
		if line == nil then
			break
		end
		if string.len(line) < 5 then
			break
		end
		count = count + 1
		process_line(line, count)
	until 1==0
	file:close()
end

function process_port()
	for l=1,count do
		local mdata = modemdata[l]
		if mdata[1] == uvid and mdata[2] == upid then
			retval = 0
			if mdata[3] == "tty0" then
				retval =  1
			end
			if mdata[3] == "tty1" then
				retval =  2
			end
			if mdata[3] == "tty2" then
				retval =  3
			end
			if mdata[3] == "tty3" then
				retval =  4
			end
			if mdata[3] == "tty4" then
				retval =  5
			end
			if mdata[3] == "tty5" then
				retval =  6
			end

			cretval = 0
			if mdata[4] == "tty0" then
				cretval = 1
			end
			if mdata[4] == "tty1" then
				cretval = 2
			end
			if mdata[4] == "tty2" then
				cretval = 3
			end
			if mdata[4] == "tty3" then
				cretval = 4
			end
			if mdata[4] == "tty4" then
				cretval = 5
			end
			if mdata[4] == "tty5" then
				cretval = 6
			end

			break
		end
	end
end

if uvid == "12d1" then
	if upid == "14cc" or upid == "1464" or upid == "151b" then
		cport = "0"
	end
	if upid == "14ac" then
		cport = "1"
	end
	if upid == "140c" then
		cport = "1"
	end
end

read_modem()
retval = 0
cretval = 0
if count > 0 then
	process_port()
end
if retval > 0 then
	retval = retval - 1
else
	retval = tonumber(dport)
end
if cretval > 0 then
	cretval = cretval - 1
else
	cretval = tonumber(cport)
end

if uvid == "2001" and upid == "7e35" then
	cretval = 2
	retval = 1
end
--
-- may need    echo "2c7c 0125" > /sys/bus/usb/drivers/qmi_wwan/new_id
-- may need    echo "2c7c 0121" > /sys/bus/usb/drivers/qmi_wwan/new_id
-- may need    echo "2c7c 0306 ff" > /sys/bus/usb-serial/drivers/option1/new_id
--
if uvid == "2c7c" and (upid == "0121" or upid == "0125" or upid == "0306" or upid == "0296" or upid == "0512" or upid == "0620" or upid == "0800") then
	cretval = 2
	retval = 3
end
if uvid == "05c6" and upid == "9215" then
	cretval = 2
	retval = 3
end
if uvid == "1e0e" and upid == "9001" then
	cretval = 2
	retval = 3
end


dret = string.format("%d", retval)
cret = string.format("%d", cretval)
local file = io.open("/tmp/parmpass", "w")
file:write("DPORT=\"" .. dret .. "\"\n")
file:write("CPORT=\"" .. cret .. "\"\n")
file:close()

os.exit(retval)
