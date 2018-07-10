local skynet=require "skynet"
local libcenter=require "libcenter"

--init module--
local faci=require "faci.module"
local module=faci.get_module("ddz")
local dispatch=module.dispatch
local forward=module.forward
local event=module.event


local Room_Map={}

function dispatch.create(room_id)
	local roomAddr=skynet.newservice("room_ddz","room_ddz",room_id)
	skynet.call(roomAddr,"lua","room_api.start","test")
	DEBUG("------room_ddz create------")
	Room_Map[room_id]={addr=roomAddr,}
	return true,skynet.self(),Room_Map[room_id]
end

function dispatch.enter(room_id,data)
	DEBUG("------room_ddz enter------")
	local room=Room_Map[room_id]
	if not room then
		ERROR("------ddz enter not room------"..room_id)
		return false
	end
	DEBUG("room is ok")
	local isok=skynet.call(room.addr,"lua","room_api.enter",data)
	return isok,skynet.self(),room
end

function dispatch.leave(room_id,uid)
	local room=Room_Map[room_id]
	if not room then
		ERROR("ddz leave not room "..room_id)
		return false
	end
	DEBUG("ddz leave roomid:"..room_id..",uid:"..uid)	
	local isok=skynet.call(room.addr,"lua","room_api.leave",uid)
	return isok,skynet.self()
end
