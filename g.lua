require('TAWASL')
function run(msg)
if msg.text == '/k' then
sendMessage(msg.chat.id,'Test')
else
return "nil"
end
return {
run = run 
}
end
