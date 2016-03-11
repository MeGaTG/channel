package.path = package.path .. ';.luarocks/share/lua/5.2/?.lua'
  ..';.luarocks/share/lua/5.2/?/init.lua'
package.cpath = package.cpath .. ';.luarocks/lib/lua/5.2/?.so'
URL = require('socket.url')
JSON = require('@dev_mico')
HTTPS = require('ssl.https')
dofile('utilities.lua')
----config----
local bot_api_key = "144240146:AAG8vaek5Ix5fx_NZxN2OFtyVeaN1UTbUTM"
local you = 171114902 --your id
local BASE_URL = "https://api.telegram.org/bot"..bot_api_key

local nl = [[bye]]--put any welcome message between [[]]
----utilites----


function is_admin(msg)-- Check if user is admin or not
  local var = false
  local admins = you
  for k,v in pairs(admins) do
    if msg.from.id == v then
      var = true
    end
  end
  return var
end

function sendRequest(url)
  local dat, res = HTTPS.request(url)
  local tab = JSON.decode(dat)

  if res ~= 200 then
    return false, res
  end

  if not tab.ok then
    return false, tab.description
  end

  return tab

end

function getMe()
    local url = BASE_URL .. '/getMe'
  return sendRequest(url)
end
curlRequest = function(curl_command)
 -- Use at your own risk. Will not check for success.

	io.popen(curl_command)

end
function getUpdates(offset)

  local url = BASE_URL .. '/getUpdates?timeout=20'

  if offset then

    url = url .. '&offset=' .. offset

  end

  return sendRequest(url)

end

sendPhotoID = function(chat_id, file_id, caption, reply_to_message_id, disable_notification)

	local url = BASE_URL .. '/sendPhoto?chat_id=' .. chat_id .. '&photo=' .. file_id

	if caption then
		url = url .. '&caption=' .. URL.escape(caption)
	end

	if reply_to_message_id then
		url = url .. '&reply_to_message_id=' .. reply_to_message_id
	end

	if disable_notification then
		url = url .. '&disable_notification=true'
	end

	return sendRequest(url)

end

forwardMessage = function(chat_id, from_chat_id, message_id)

	local url = BASE_URL .. '/forwardMessage?chat_id=' .. chat_id .. '&from_chat_id=' .. from_chat_id .. '&message_id=' .. message_id

	return sendRequest(url)

end
function getUserProfilePhotos(user_id)
if user_id == nil then
return
else
local url = BASE_URL .. '/getUserProfilePhotos?user_id='..user_id
print(url)
return sendRequest(url)
end
end
function download_to_file(url, file_name, file_path)
  print("url to download: "..url)
  
  local respbody = {}
  local options = {
    url = url,
    sink = ltn12.sink.table(respbody),
    redirect = true
  }
  -- nil, code, headers, status
  local response = nil
    options.redirect = false
    response = {HTTPS.request(options)}
  local code = response[2]
  local headers = response[3]
  local status = response[4]
  if code ~= 200 then return nil end
  local file_path = file_name

  print("Saved to: "..file_path)
  
  file = io.open(file_path, "w+")
  file:write(table.concat(respbody))
  file:close()
  return file_path
end
--------

function sendMessage(chat_id, text, disable_web_page_preview, reply_to_message_id, use_markdown)

	local url = BASE_URL .. '/sendMessage?chat_id=' .. chat_id .. '&text=' .. URL.escape(text)

	if disable_web_page_preview == true then
		url = url .. '&disable_web_page_preview=true'
	end

	if reply_to_message_id then
		url = url .. '&reply_to_message_id=' .. reply_to_message_id
	end

	if use_markdown then
		url = url .. '&parse_mode=Markdown'
	end

	return sendRequest(url)

end


function bot_run()
	bot = nil
	while not bot do 
	
			bot = getMe()
	
	end
	if not add then
		add = load_data('MICO.db')
	end

	bot = bot.result

	local bot_info = "Username = @"..bot.username.."\nName = "..bot.first_name.."\nId = "..bot.id.." \nbased by @dev_mico\nyouId : "..you
	print(bot_info)

	last_update = last_update or 0

	is_running = true
	math.randomseed(os.time())
	math.random()


	last_cron = last_cron or os.date('%M', os.time()) -- the time of the last cron job,
	is_started = true -- and whether or not the bot should be running.
add.usernames = add.usernames or {} -- Table to cache usernames by user ID.
add.talk = add.talk or {}
end

function msg_processor(msg)

	if msg.date < os.time() - 5 then -- Ignore old msgs
		return
    end

if msg.text:match('/p (.*)')then
local matches = {string.match(msg.text,('/p (.*)'))}
local input = get_word(matches[1])
local lid = resolve_username(input)
local phl =  getUserProfilePhotos(tonumber(lid))
local file = phl.result.photos[1][1].file_id
print(file)
local url = BASE_URL .. '/getFile?file_id='..file
	local res = HTTPS.request(url)
 local jres = JSON.decode(res)
local caption = "his id :- "..lid

sendPhotoID(msg.chat.id,file,caption)
elseif msg.reply_to_message and msg.text == '/p' then
local lid = msg.reply_to_message.from.id
local phl =  getUserProfilePhotos(tonumber(lid))
local file = phl.result.photos[1][1].file_id
print(file)
local url = BASE_URL .. '/getFile?file_id='..file
	local res = HTTPS.request(url)
 local jres = JSON.decode(res)
local caption = "his id :- "..lid

sendPhotoID(msg.chat.id,file,caption)

elseif msg.text == '/p' then
local ph = getUserProfilePhotos(msg.from.id)
local file = ph.result.photos[1][1].file_id
local url = BASE_URL .. '/getFile?file_id='..file
	local res = HTTPS.request(url)
	local jres = JSON.decode(res)

if msg.from.username ~= nil then
msg.from.username = '@'..msg.from.username
elseif msg.from.username == nil then
msg.from.username = "you don't have"
end
local caption = 'your nam :- '..msg.from.first_name..'\nyour id :-'..msg.from.id..'\nyour username :- '..msg.from.username

	sendPhotoID(msg.chat.id,file,caption)
elseif msg.text:match('/id (.*)$') then
local matches = {string.match(msg.text,('/id (.*)'))}
		local input = get_word(matches[1])
  id = resolve_username(input)
sendMessage(msg.chat.id,id)
elseif msg.text:match('/w (.*) (.*)') then
local matches = {string.match(msg.text,('/w (.*) (.*)'))}
local lt = matches[1]:gsub("_"," ")
local lr = matches[2]:gsub("_"," ")
add.talk[lt]= lr
elseif msg.text and add.talk[msg.text] ~= nil then
local ion = add.talk[msg.text]
local out = ion:gsub("_"," ")
sendMessage(msg.chat.id,out,true,msg.message_id)
elseif msg.from.username then
		add.usernames[msg.from.username:lower()] = msg.from.id

end
end
bot_run() -- Run main function
while is_running do -- Start a loop 
	local response = getUpdates(last_update+1) -- Get the latest updates using getUpdates method
	if response and you ~= nil then
		for i,v in ipairs(response.result) do
			last_update = v.update_id
			msg_processor(v.message)
		end
	else
		print("Check api token or id")
--		return "conectin failed"
	end
	if last_cron ~= os.date('%M', os.time()) then -- Run cron jobs every minute.
		last_cron = os.date('%M', os.time())
		save_data('MICO.db', add) -- Save the database.

			end
end
save_data('MICO.db', add)
print("Bot halted")
