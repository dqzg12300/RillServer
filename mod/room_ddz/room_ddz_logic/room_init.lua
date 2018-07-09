local RoomDDZ=class("RoomDDZ")

local libcenter=require "libcenter"

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

return RoomDDZ
