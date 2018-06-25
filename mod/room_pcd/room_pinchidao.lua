
local libsetup = require "libsetup"

-- local cfg = libsetup.pinchidao[id]



local RoomPinChiDao = require "room_pcd.room_pinchidao_logic.room_init" 


local tablex = require "pl.tablex"


function RoomPinChiDao:is_player_num_overload()
    return tablex.size(self._players) >= 4
end 

function RoomPinChiDao:enter(data)
	local uid = data.uid
	local player = {
		uid = uid,
		agent = data.agent,
		node = data.node,
    }
    
    self._players[uid] = player
    self:broadcast({cmd="movegame.add", uid = uid,}, uid)
    return SYSTEM_ERROR.success
end 

function RoomPinChiDao:leave(uid)
    self._players[uid] = nil
    self:broadcast({cmd="movegame.leave", uid=uid,}, uid)

    return SYSTEM_ERROR.success
end 


return RoomPinChiDao

