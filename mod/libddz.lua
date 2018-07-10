local skynet = require "skynet"
local log = require "log"
local M = {}

local runconf = require(skynet.getenv("runconfig"))
local moveconf = runconf.ddz
local MAX_GLOBAL_COUNT = #moveconf.global


local function fetch_global(id)
    local index = id % MAX_GLOBAL_COUNT + 1
    return moveconf.global[index]
end

local function call(cmd, id, ...)
	local global = fetch_global(id)
	if not global then
		ERROE("cmd:"..cmd..",id:"..id.." is nil")
		return false
	end
	return skynet.call(global, "lua", cmd, id, ...)
end


function M.create(id)
	DEBUG("libddz begin")
	local ret=call("ddz.create", id)
	DEBUG("libddz end")
	return ret	
end

function M.enter(id, uid, data)
	return call("ddz.enter", id, uid, data)
end

function M.leave(id, uid)
	return call("ddz.leave", id, uid)
end

function M.get_forward(id)
	return fetch_global(id)
end


return M
