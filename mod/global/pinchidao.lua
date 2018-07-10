local skynet = require "skynet"
local libcenter = require "libcenter"

----------------------------------注意修改module名-------------------------------------------
---------------------------------------注意修改module名--------------------------------------
local faci = require "faci.module"
local module = faci.get_module("pinchidao")  --$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 模块
local dispatch = module.dispatch
local forward = module.forward
local event = module.event
----------------------------------注意修改module名-------------------------------------------
---------------------------------------注意修改module名--------------------------------------

--移动游戏
--[[
	room_id 
	addr 
]]
--room_id -->roominfo
local Room_Map = {
}

function dispatch.create(room_id)
	local addr = skynet.newservice("room_pinchidao", "room_pcd", room_id)
	skynet.call(addr, "lua", "room_api.start", "hello world")
    Room_Map[room_id] = {room_id = room_id, addr = addr,}
    DEBUG("^^^^^^room_pinchidao create^^^^^^^^^^^", inspect(Room_Map))
end

function dispatch.enter(room_id, data)
    DEBUG("^^^^^^room_pinchidao enter^^^^^^^^^^^", room_id, inspect(Room_Map))
	local room = Room_Map[room_id]
	if not room then
		ERROR("pinchidao enter not room "..room_id)
		return false
	end
    
	local isok = skynet.call(room.addr, "lua", "room_api.enter", data)
	return isok, skynet.self(), room
end

function dispatch.leave(uid)
	local id = Player_Map[uid]
	local  room = Room_Map[id]
	if not room then
		skynet.error("movegame leave not room "..id)
		return false
	end

	return skynet.call(room.addr, "lua", "room_api.leave", uid)
end
