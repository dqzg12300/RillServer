local RoomDDZ=class("RoomDDZ")

local libcenter=require "libcenter"
local ddz_logic=require "room_ddz.ddz"
local tablex=require "pl.tablex"

function RoomDDZ:initialize()
	DEBUG("------RoomDDZ Init------")
	self._players={}
	self._hand={}
end

function RoomDDZ:broadcast(msg,filterUid)
	DEBUG("broadcast")
	for k,v in pairs(self._players) do
		if filterUid and filterUid~=k then
			libcenter.send2client(k,msg)
		end
	end
end


function RoomDDZ:gamestart()
	DEBUG("ddz game start")
	if not self._players then
		ERROR("ddz room play is nil")
		return
	end
	local play_count=tablex.size(self._players)
	if play_count<3 then
		ERROR("ddz room play count :"..play_count)
		return
	end
	DEBUG("play count:"..play_count)
	local uids={}
	for k,v in pairs(self._players) do
		table.insert(uids,k)
	end
	
	local playcard=ddz_logic.game_start(uids)
	self._hand=playcard.hand
	for k,v in pairs(playcard.cards) do
		libcenter.send2client(k,{_cmd="game.deal",card=playcard.cards[k]})
	end
end

return RoomDDZ
