require ("cord")
sh = require "stormsh"
d2 = storm.io.D2
d3 = storm.io.D3
d5 = storm.io.D5

addr = '169.229.223.190'
addrtemp = 'fe80::201:c0ff:fe15:8419'
addr6 = '2001:470:4956:1::1'
addrin = '2001:470:66:3f9::2'
port = 9666
notReceived = true


receiveCallback = function(payload, from, port)
	print(payload)
	notReceived = false
end

sock = storm.net.udpsocket(port, receiveCallback)
--storm.net.sendto(sock, payload, from, cport)

sendUntilReceived = function(payload)
	notReceived = true
	count = 0
	cord.new(function()
		while notReceived==true and count < 15 do
			packAndSend(payload)
			cord.await(storm.os.invokeLater, storm.os.SECOND)
			count = count + 1
		end
		notRecieved = true
	end)
end

packAndSend = function(payload)
	print(payload, addr6)
	pp = storm.mp.pack(payload)
	status = storm.net.sendto(sock, pp, addr6, port)
	print(status)
end

watch = {}
watch.OPEN = true
watch.CLOSED = false
watch.SAFETY = 0
watch.DELAY = 1
watch.MONITOR = 2
watch.usingAlarm = true

setup = function (pin)
        storm.io.set_mode(storm.io.INPUT, pin)
        storm.io.set_pull(storm.io.PULL_UP, pin)
end

soundAlarm = function()
	print("SOUND THE ALARM")
end

alarmOff = function( bool )
	if bool == nil then
		bool = false
	end
	watch.usingAlarm = bool
end

setOpen = function(callback, pin)
	storm.io.watch_all(storm.io.RISING, pin, safeCallback(callback, 1))
end

setClose = function(callback, pin)
	storm.io.watch_all(storm.io.FALLING, pin, safeCallback(callback, 0))
end


setToggle = function(callback, pin)
	storm.io.watch_all(storm.io.CHANGE, pin, callback)
end

safeCallback = function(callback, val)
	return function()
		if storm.io.get(d2) == val then
			callback()
		end
	end
end

makeSendState = function(pin, name, mode, place)
	return function()
		sendUntilReceived({storm.io.get(pin), name, mode, place})
	end
end

sendState = function()
	sendUntilReceived(storm.io.get(d2))
end


send1 = function()
	sendUntilReceived(1)
end

send0 = function()
	sendUntilReceived(0)
end


setLater = function(callback, pin, delay, startState)
	print("starting")
	watch.waiting = false
	watch.event = nil
	if storm.io.get(d2) == 1 then
		watch.state = watch.OPEN
	else
		watch.state = watch.CLOSED
	end
	print("finished calibrating")
	if startState == nil then 	-- set default start state to closed
	    startState = watch.CLOSED
	end
	newCallback = callbackMaker(callback, delay, startState)
	storm.io.watch_all(storm.io.CHANGE, pin, newCallback)
	print("end method call")
end


callbackHelp = function(callback, delay, startState)
	print("callback occured")
	print(watch.state, startState, watch.waiting)
	if not watch.waiting and watch.state == startState then
	    watch.event = storm.os.invokeLater(storm.os.SECOND*delay, callback)
	    watch.waiting = true
	    print("watching")
	elseif watch.event ~= nil then
	    cancel()
	    print("called off...")
	else
	    print("getting into correct state")
	end
	watch.state = not watch.state
end

callbackMaker = function(callback, delay, startState)
	print (callback, delay, startState)
	return function() callbackHelp(callback, delay, startState) end
end

cancel = function()
	storm.os.cancel(watch.event)
	watch.event = nil
	watch.waiting = false
end

------ app below/ library above

printhi = function()
	print(storm.io.get(d2))
	print('hi')
--	cancel()
end

printbye = function()
	print(storm.io.get(d2))
	print('bye')
--	cancel()
end

printcancel = function()
	printhi()
	cancel()
end
setup(d2)
setup(d3)
setup(d5)
--setLater(printcancel, d2, 5, watch.CLOSED)
--setOpen(printhi, d2)
--setClose(printbye, d2)
setToggle(makeSendState(d2, "Watch Box", 0, "Toms Room"), d2)
setToggle(makeSendState(d3, "Candy", 2, "Toms Room"), d3)
setToggle(makeSendState(d5, "Money Jar", 0, "Parents Room"), d5)

sh.start()
cord.enter_loop()
