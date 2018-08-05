local cardtype=require "room_ddz.card_type"
local M={}
local card={}

local function shuffle()
	for i=1,#card do
		local tmp=math.random(1,#card)
		local data=card[tmp]
		card[tmp]=card[i]
		card[i]=data
	end
end

local function card_init()
	local min=cardtype.min_card
	local max=cardtype.max_card
	card={}
	for i=1,4 do
		for y=min,max do
			table.insert(card,{data=y,color=i})
		end
	end
	table.insert(card,{data=cardtype.min_joker,color=1})
	table.insert(card,{data=cardtype.max_joker,color=1})
end

local function show_card()
	for i,k in ipairs(card)do 
		print(i..",card:"..k.data..",color:"..k.color)
	end
end

local function licensing(uids)
	local c1=uids[1]
	local c2=uids[2]
	local c3=uids[3]
	local play_card={cards={},hand={}}
	play_card.cards[c1]={}
	play_card.cards[c2]={}
	play_card.cards[c3]={}

	for i=1,#card do
		if i<=#card-3 then
		--派发
			if i%3==0 then
				table.insert(play_card.cards[c1],card[i])
			elseif i%2==0 then
				table.insert(play_card.cards[c2],card[i])
			else
				table.insert(play_card.cards[c3],card[i])
			end
		else
			table.insert(play_card.hand,card[i])
		end
	end
	return play_card
end

function M.game_start(uids)
	shuffle()
	return licensing(uids)
end

card_init()	

return M
