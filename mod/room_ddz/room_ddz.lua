local RoomDDZ=require "room_ddz.room_ddz_logic.room_init"

local tablex=require "pl.tablex"

function RoomDDZ:is_player_num_overload()
	return tablex.size(self._players)>=4
end


function RoomDDZ:enter(data)
	local uid=data.uid
	local player={
		uid=uid,
		agent=data.agent
		node=data.node
	}
	self._players[uid]=player
	self:broadcast({cmd="room_move.add",uid=uid,},uid)
	return SYSTEM_ERROR.success
end

function RoomDDZ:leave(uid)
	self._players[uid]=nil
	self:broadcast({cmd="movegame.leave",uid=uid},uid)
	return SYSTEM_ERROR.success
end

return RoomDDZ
