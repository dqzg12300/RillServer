local M = {}



local SuitType = {
    Spade =1, --黑桃
    Heart =2, --红桃
    Club =3, --梅花
    Diamond = 4, --方块
	Joker = 5,  --大小王
}

local CardDisplay = {
	"A","2","3","4","5","6","7","8","9","10","J","Q","K","Kinglet","King",
}


--花色
local function get_suit(id)  
	local bigType = nil
	if id >= 1 and id <= 13 then
		bigType = suittype.Diamond
	elseif id >= 14 and id <= 26 then
		bigType = suittype.Club
	elseif id >= 27 and id <= 39 then
		bigType = suittype.Heart
	elseif id >= 40 and id <= 52 then
		bigType = suittype.Spade 
	elseif id == 53 or id == 54 then
		bigType = suittype.Joker
	end
	return bigType
end

--牌号
local function getdisplay(id)  
	local display = nil
	if id >= 1 and id <= 52 then
		display = CardDisplay[(id-1) % 13 + 1]
	elseif id == 53 then
		display = CardDisplay[14]
	elseif id == 54 then
		display = CardDisplay[15]
	end
	return display
end

local function getgrade(id)  --权级
	local grade = 0
	if id == 53 then --小王
		grade = 16
	elseif id == 54 then 	--大王
		grade = 17
	else 
		local modResult = id % 13
		if modResult == 1 then -- A
			grade = 14
		elseif modResult == 2 then -- 2
			grade = 15
		elseif modResult >= 3 and modResult < 13 then  -- 3到Q
			grade = modResult
		elseif modResult == 0 then --K
			grade = 13
		end
    end
    return grade
end 

local function getupcard(display)  
	-- local display = nil
	-- if id >= 1 and id <= 52 then
	-- 	display = CardDisplay[(id-1) % 13 + 1]
	-- elseif id == 53 then
	-- 	display = CardDisplay[14]
	-- elseif id == 54 then
	-- 	display = CardDisplay[15]
	-- end
	-- return display
end



local function getgrade(id)  --权级
	local grade = 0
	if id == 53 then --小王
		grade = 16
	elseif id == 54 then 	--大王
		grade = 17
	else 
		local modResult = id % 13
		if modResult == 1 then -- A
			grade = 14
		elseif modResult == 2 then -- 2
			grade = 15
		elseif modResult >= 3 and modResult < 13 then  -- 3到Q
			grade = modResult
		elseif modResult == 0 then --K
			grade = 13
		end
    end
    return grade
end

--所有的牌 6副牌

local Card_UIN = 10000
local CardsUIN_Map = {}  --唯一ID -- 牌信息
local CardId_Map = {} -- 牌型 cardId -- uin
-- local Cards_Lst = {}  -- 每副牌的信息 用于洗牌
local PinChiDaoRule ={
    paigroup = 6, -- 几副牌
    painum = 81, --每人81张牌
}


--[[
    cards[uid] = {
        display 
        grade
        num
        --具体牌信息
        lst ={

        }
    }
]]

--是否墩
local function is_dun(num)
    return num >= 7
end

--是否炸弹
local function is_bomb(num)
    return num >=4
end

local tablex = require "pl.tablex"

--判断是否可以出牌 
local function check_finesse_cards(cards, me_cards)
    --是否是允许的出牌
    local finess = {}
    local display = nil
    local grade = nil 
    for n=1, #cards do
        local c = me_cards[cards[n]]
        if not c then
            return 1
        end 
        
        display = getdisplay(c.cardId)
        grade = c.grade
        if not finess[display] then
            finess[display] = {}
        end 

        table.insert(finess[display], cards[n])
    end 

    local num = tablex.size(finess)

    if num == 1 then --默认1种花色可以打
    elseif num == 2 then --只有再 盾的时候才会可能出现 大小王
        local c_num = 0
        display = "King" --如果是炸 系统认为是 大王
        grade = 17

        for k,v in pairs(finess) do 
            if k ~= "Kinglet" or k ~= "King" then
                return 2
            end 
            c_num = c_num + 1
        end 

        if not is_bomb(c_num) then 
            return false 
        end 

    else
        return 3 --不允许出现3中不同牌号
    end

    return 0, {cards = {display= display, grade =grade, num = #cards, lst = cards}, }
end 

-- --找出 下家 可以吃 cards 打出的牌 
-- local function find_swallow_cards(bcards, turn_cards)
--     --如果是临牌 可以检查相关是否是对应的临牌
--     local can_swallow = {}

--     --如果不是盾的话 且不是大王 可以在相同临牌中优先找
--     if not is_bomb(bcards.num) then
--         if bcards.display ~= "King" then

--         end 
--     end 
-- end 

--需要 临时保留 上一次出的牌信息
--判断是否可以吃上家 lcards
local function check_swallow_cards(other_cards, me_cards, me_map)
    local res, me_allow = check_finesse_cards(cards, me_cards)
    if res ~= 0 then
        return res 
    end 

    if is_bomb(me_allow.num) then
        if me_allow.num > other_cards.num then
            return 0
        else 
            if me_allow.num == other_cards.num and  me_allow.grade > other_cards.grade then
                return 0
            end 
        end 

    else 
        if not is_bomb(me_allow.num) then 
            if me_allow.num == other_cards.num and  me_allow.grade > other_cards.grade then
                return 0
            end 
        end 
    end 

    return 4
end 

-- --TODO:计算分数
-- local function cal_dun_score(cards)
--     local score = 0
--     if is_dun(cards.num) then
        
--     end 
--     return score
-- end

--发牌
--盾 没人 2分 每种盾对应不同盾次数
-- 捡分 10分 对应本局结束1积分

-- 洗牌
local function shuffle(t)
    for i=#t,2,-1 do
        local tmp = t[i]
        local index = math.random(1, i - 1)
        t[i] = t[index]
        t[index] = tmp
    end
end

function M.create()
    for n=1, PinChiDaoRule.paigroup do 
        for i=1,54 do
            Card_UIN = Card_UIN + 1
            local pai = {
                card_uin = Card_UIN,
                cardId = i,
                grade=getgrade(i),
                suit = get_suit(i),
                display = getdisplay(i),
            }

            if not CardId_Map[pai.cardId] then
                CardId_Map[pai.cardId] = {}
            end 
            
            CardId_Map[pai.cardId][pai.card_uin] = pai.card_uin
            -- table.insert(CardId_Map[pai.cardId], card_uin)
            -- table.insert(Cards_Lst, card_uin)
            CardsUIN_Map[pai.card_uin] = pai
        end 
    end 
end 

local function gen_tbl(cardids_info, num, out_info)
    for k, v in pairs(cardids_info) do 
        assert(CardsUIN_Map[k]) 

        out_info[k] = CardsUIN_Map[k] --TODO:判断是否已经超过 81张
        cardids_info[k] = nil
        num = num -1
        if num <=0 then
            return 
        end 
    end 
end 

--指定发牌
local function pre_tbl(players)
    for _, player in pairs(players) do
        for _, v in ipairs(player.ex) do
            
            local cardids_info = CardId_Map[v.cardId]
            if cardids_info then
                local cardids_num = tablex.size(cardids_info)
                if cardids_num < v.num then
                    v.num = cardids_num
                end 

                gen_tbl(cardids_info, num, v.cards)
            end 
        end 
    end 
end 

local function pack_pai(shuffle_pai)
    for _, card in pairs(CardId_Map) do
        table.insert(shuffle_pai, card)
    end 
end 

local function fapai_tbl(players, shuffle_pai)
    for _, player in pairs(players) do
        local num = tablex.size(v.cards)
        for n=num, PinChiDaoRule.painum do 
            local carduin = table.remove(shuffle_pai, 1)
            assert(CardsUIN_Map[carduin]) 
            player.cards[carduin] = CardsUIN_Map[carduin] 
        end 
    end 
end 

--发牌结束之后的一些汇总 和检查是否牌合理
local function fix_pai(players)
    for _, player in pairs(players) do
        assert(tablex.size(v.cards) == PinChiDaoRule.painum)
        -- for _, v in pairs(players.cards) do
        --     displays
        -- end
    end 
end 

--控制胜率 假设是8成 初步想法 同步实现配置好 部分好牌的数据 发给特定玩家 假设本次房卡局数10次那随机8次
function M.puke_fapai(players)
    --{uin  , ex ={ {cardId, num}, }, displays牌型  cards = {carduin = cardInfo, }
    pre_tbl(players)
    
    --组合出洗牌需要的数据
    local shuffle_pai = {}
    pack_pai(shuffle_pai)
    --洗牌
    shuffle(shuffle_pai)

    fapai_tbl(players, shuffle_pai)

    --检查是否发的牌符合规则
    assert(#shuffle_pai == 0)
    CardId_Map = nil
end 




return M