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
	skynet.call(addr,"lua","room_api.start","")
	Room_Map[room_id]={addr=addr,}
	DEBUG("------room_ddz create------",inspect(Room_Map))
end
