local RoomDDZ=require "room_ddz.room_ddz_logic.room_init"
local libcenter=require "libcenter"

local tablex=require "pl.tablex"
local timer=require "timer"

function RoomDDZ:is_player_num_overload()
	return tablex.size(self._players)>=3
end

local t
local idx

function RoomDDZ:enter(data)
	local uid=data.uid
	local player={
		uid=uid,
		agent=data.agent,
		node=data.node,
	}
	self._players[uid]=player
	DEBUG("roomDDZ enter uid:"..uid)
	self:broadcast({_cmd="room_move.add",uid=uid,},uid)

	if self:is_player_num_overload() then
		t=timer:new()
		t:init()
		idx=t:register(3,self.gamestart,0,self)
		DEBUG("room player is overload")
	end

	DEBUG("player size:"..tablex.size(self._players))
	return SYSTEM_ERROR.success
end

function RoomDDZ:leave(uid)
	if not uid then
		ERROR("roomDDZ leave uid is nil")
		return SYSTEM_ERROR.error
	end
	self._players[uid]=nil
	self:broadcast({_cmd="movegame.leave",uid=uid},uid)
	DEBUG("ddz leave")
	DEBUG(t)
	DEBUG(idx)
	if t and idx then 
		t:unregister(idx)
		DEBUG("unregister:"..idx)
	end
	return SYSTEM_ERROR.success
end

return RoomDDZ
