local RoomDDZ=class("RoomDDZ")

local libcenter=require "libcenter"
local ddz_logic=require "room_ddz.ddz"
local tablex=require "pl.tablex"

function RoomDDZ:initialize()
	DEBUG("------RoomDDZ Init------")
	self._players={}
end

function RoomDDZ:broadcast(msg,filterUid)
	for k,v in ipairs(self._players) do
		if filterUid and filterUid~=k then
			libcenter.send2client(k,msg)
		end
	end
end


function RoomDDZ:gamestart()
	DEBUG("ddz game start")
	DEBUG(self)
	if self._players then
		DEBUG("ddz room play size:"..tablex.size(self._players))
	end

	local playcard=ddz_logic.game_start()
end

return RoomDDZ
