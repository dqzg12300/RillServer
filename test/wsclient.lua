package.cpath = "../luaclib/?.so"
package.path = "../skynet/lualib/?.lua;../lualib/?.lua;../examples/?.lua"

if _VERSION ~= "Lua 5.3" then
	error "Use lua 5.3"
end

local M = {}

local socket = require "clientwebsocket"
local json = require "cjson"
local tool = require "tool"

local fd = nil
local cb = nil
local cbt = nil
M.stop = false


function M.connect(ip, port, recvcb, timercb)
	cb = recvcb
	cbt = timercb
	fd = assert(socket.connect(ip or "127.0.0.1", port or 11798))
end

function M.sleep(t)
	socket.usleep(t)
end


local function request(name, args)
    local t = {
        _cmd = name,
		_check = 0,
    }
    if type(args) == "table" then
        for k, v in pairs(args) do
            t[k] = v
        end
    end
	local str = json.encode(t)
	print("request:" .. str)
    return str
end

local function send_package(fd, pack)
	socket.send(fd, pack)
end

local function recv_package()
	local r , istimeout= socket.recv(fd, 100)
	if not r then
		return nil
	end
	if r == ""  and istimeout == 0 then
		error "Server closed"
	end
	return r
end

local session = 0

function M.send(name, args)
	session = session + 1
	local str = request(name, args)
	send_package(fd, str)
	print("Request:", session)
end

local function dispatch_package()
	while true do
		local v
		v = recv_package()
		if not v  or v == "" then
			break
		end
		print("recv: " .. tool.dump(v)) 
        if cb then 
			local t = json.decode(v)
			cb(t)
		else
			print("cb == nil")
		end
	end
end

function M.start()
	while true do
		if M.stop then 
			break 
		end
		dispatch_package()
		if cbt then
			cbt()
		end
		socket.usleep(50)
	end
end

function CallBack(msg)
	print("error:"..msg.error)
end


function M.init(ip,port,hander)
	M.connect(ip,port,hander.CallBack,hander.CallBackTimer)
end

function M.login(account,password)
	M.send("login.login", {account = account, password = password})
end

function M.create_room(game_name)
	M.send("create_room", {game = game_name}) 
end

function M.enter_room(game,room_id)
	M.send("enter_room", {id=room_id,game=game})
end

function M.leave_room()
	M.send("leave_room",{})
end

return M
