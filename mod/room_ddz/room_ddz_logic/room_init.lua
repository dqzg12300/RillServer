local RoomDDZ=class("RoomDDZ")
local libcenter=require "libcenter"
local ddz_logic=require "room_ddz.ddz"
local tablex=require "pl.tablex"
local timer=require "timer"
local machine=require "statemachine"

local t=nil
local tidx=nil

local master=nil
local pre_master=nil
local uidIndex=nil
local uids={}
local fsm=nil
local game_hander={}

function RoomDDZ:broadcast(msg,filterUid)
	DEBUG("broadcast")
	for k,v in pairs(self._players) do
		if not filterUid or filterUid~=k then
			libcenter.send2client(k,msg)
		end
	end
end

function RoomDDZ:gamestart()
	DEBUG("roomddz gamestart")
	fsm:gamestart(self)
end


function RoomDDZ:waitallot()
	DEBUG("roomddz waitallot")
	fsm:waitallot(self)
end

function game_hander.ongamestart(fsmself,event,form,to,msg)
	DEBUG("ddz game start")
	if not msg._players then
		ERROR("ddz room play is nil")
		return
	end
	local play_count=tablex.size(msg._players)
	if play_count<3 then
		ERROR("ddz room play count :"..play_count)
		return
	end
	uids={}
	DEBUG("play count:"..play_count)
	for k,v in pairs(msg._players) do
		table.insert(uids,k)
	end
	uidIndex=math.random(1,3)	
	pre_master=uids[uidIndex]
	local playcard=ddz_logic.game_start(uids)
	msg._hand=playcard.hand
	for k,v in pairs(playcard.cards) do
		libcenter.send2client(k,{_cmd="game.card",card=playcard.cards[k]})
	end
	fsm:waitallot(msg)
end

function game_hander.onallot(fsmself,event,form,to,msg)
	DEBUG("onallot")
end

function game_hander.onwaitallot(fsmself,event,form,to,msg)
	DEBUG("game waitallot")
	msg:broadcast({_cmd="game.deal",master=uids[uidIndex]})
	uidIndex=uidIndex+1
	if uidIndex>3 then
		uidIndex=1
	end
	DEBUG(uidIndex)
	DEBUG(pre_master)
	DEBUG(uids[uidIndex])
	if pre_master==uids[uidIndex] then
		DEBUG("not user become master")
		tidx=t:register(10,msg.gamestart,0,msg)	
		return
	end
	tidx=t:register(10,msg.waitallot,0,msg)	
end

function game_hander.onwaitplay(fsmself,event,form,to,msg)
	DEBUG("game waitplay")
end

function game_hander.onplay(fsmself,event,form,to,msg)
	DEBUG("game play")
end

function game_hander.onover(fsmself,event,form,to,msg)
	DEBUG("game over")
end


function RoomDDZ:initialize()
	DEBUG("------RoomDDZ Init------")
	self._players={}
	self._hand={}
	t=timer:new()
	t:init()
	fsm=machine.create({
		initial="begin",
		events={
			{name="gamestart",from={"begin","become_master_wait"},to="game_init_data"},				 --游戏开始
			{name="waitallot",from={"game_init_data","become_master_wait"},to="become_master_wait"},	 --等待选地主
			{name="allot",from="become_master_wait",to="become_master"},			 --选地主
			{name="waitplay",from="become_master",to="game_play_wait"},			 --等待出牌
			{name="play",from="game_paly_wait",to="game_over"},				 --出牌
			{name="over",from="game_play",to="begin"},					 --游戏结束
		},	
		callbacks={
			ongamestart=game_hander.ongamestart,
			onallot=game_hander.onallot,
			onwaitallot=game_hander.onwaitallot,
			onwaitplay=game_hander.onwaitplay,
			ongameing=game_hander.ongameing,
			onover=game_hander.onover,
		}
	})	
end


return RoomDDZ
