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
	DEBUG("ddz begin")
	local roomAddr=skynet.newservice("room_ddz","room_ddz",room_id)
	skynet.call(roomAddr,"lua","room_api.start","test")
	DEBUG("------room_ddz create------")
	Room_Map[room_id]={addr=roomAddr,}
	return true,skynet.self(),Room_Map[room_id]
end
