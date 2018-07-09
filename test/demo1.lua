local ws=require "wsclient"

local Hander={}

function login_login(msg)
	print(msg.error)
	if msg.error=="login success" then
		ws.create_room("ddz")
		--os.execute("sleep "..1)	
		--ws.enter_room()
	else 
		print("account:"..msg.account..",login err:",msg.error)
	end

end


function Hander.CallBack(msg)
	print("error:"..msg.error)
	funcname=string.gsub(msg._cmd,"%.","_")		
	print(funcname)
	if _G[funcname] then 
		_G[funcname](msg)
	end
end

ws.init(nil,nil,Hander)
ws.login("king","111111")
ws.start()


