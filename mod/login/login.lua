local skynet = require "skynet"

local libdb = require "libdbproxy"
local libcenter = require "libcenter"
local libagentpool = require "libwsagentpool"

local faci = require "faci.module"

local key_seq = 1

local module = faci.get_module("login")
local dispatch = module.dispatch
local forward = module.forward
local event = module.event

local login_auth = require "login.login_auth"
local login_result_code=require "loginresultcode"


function forward.login(fd, msg, source)
	local sdkid = msg.sdkid --ƽ̨ID
    local account = msg.account
	local password = msg.password

	local msgresult={}
	msgresult.account=msg.account
	msgresult._cmd=msg._cmd
	msgresult._check=msg._check
	--key
	key_seq = key_seq + 1
	local key = env.id*10000 + key_seq

	--login auth 
	local isok, uid = login_auth(sdkid, msg)
	if not isok then
		ERROR("+++++++++++ account: ",inspect(account), " login login_auth fail +++++++++")
		log.debug("%s login fail, wrong password ", account)
		msgresult.result = login_result_code.LOGIN_WRONG_PASSWORD
		return msgresult
	end

	--center
	local data = {
		node = skynet.getenv("nodename"),
		fd = fd,
		gate = source,
		key = key,
	}
	if not libcenter.login(uid, data) then
		ERROR("+++++++++++", uid, " login fail, center login +++++++++")
		msgresult.result = login_result_code.LOGIN_CENTER_FAIL
		return msgresult
	end
	--game
	data = {
		fd = fd,
		gate = source,
		account = {
			uid = uid,
			account = { 
				account = msg.account,
				password = msg.password,
			}
		}
	}
	local ret, agent = libagentpool.login(data)
	if not ret then
		libcenter.logout(uid, key)
		ERROR("++++++++++++", uid, " login fail, load data err +++++++++")
		msgresult.result = login_result_code.LOGIN_LOAD_DATA_FAIL
		return msgresult
	end
	--center
	local data = {
		agent = agent,
		key = key,
	}
	if not libcenter.register(uid, data) then
		libcenter.logout(uid, key)
		ERROR("++++++++++++", uid, " login fail, register center fail +++++++++")
		msgresult.result =login_result_code.LOGIN_REGISTER_CENTER_FAIL
		return msgresult
	end
	--gate
	local data = {
		uid = uid,
		fd = fd,
		agent = agent,
		key = key
	}
	if not skynet.call(source, "lua", "register", data) then
		libcenter.logout(uid, key)
		ERROR("++++++++++++", uid, " login fail, register gate fail +++++++++")
		msgresult.result = login_result_code.LOGIN_REGISTER_GATE_FILE
		return msgresult
	end
	msgresult.uid = uid
	msgresult.result = 0
	
	INFO("++++++++++++++++login success uid:", uid, "++++++++++++++++++")
	return msgresult
end