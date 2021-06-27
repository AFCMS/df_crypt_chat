df_crypt_chat = {}

local string = string

local F = minetest.formspec_escape
local C = minetest.colorize

local prefix = minetest.settings:get("df_crypt_chat.prefix") or "ECR:"
local format = minetest.settings:get("df_crypt_chat.server_message_format")
local key = minetest.settings:get("df_crypt_chat.key")

if key == nil then
	key = "abcedfg"
end

minetest.register_on_mods_loaded(function()
	if key == "abcedfg" then
		minetest.display_chat_message(C("red", "[CryptChat] You are using the default crypt key! This isn't secure at all!"))
	end
end)

--minetest.send_chat_message(message)
--minetest.display_chat_message(message)
minetest.register_on_receiving_chat_message(function(message)
	local playername, crypted_msg = string.match(message, "<(.-)> "..prefix.."(.*)")
	if crypted_msg == nil then
		return false
	else
		if playername == minetest.localplayer:get_name() then
			return true
		else
			minetest.display_chat_message(C("blue", "[CryptChat] RECEIVING ("..playername.."): "..crypted_msg))
			return true
		end
	end
end)

local form = table.concat({
	"formspec_version[4]",
	"size[8,3]",
	"field[0.25,0.75;7.5,0.75;chat;"..F("CryptChat")..";]",
	"label[0.25,2.25;"..F("Crypt Key:").." "..key.."]"
})

minetest.register_on_formspec_input(function(formname, fields)
	if formname == "df_crypt_chat:chat_form" and fields.chat then
		df_crypt_chat.send_msg(fields.chat)
	end
end)

function df_crypt_chat.send_msg(msg)
	minetest.send_chat_message(prefix..msg:lower())
	minetest.display_chat_message(C("blue", "[CryptChat] SENDING: "..msg:lower()))
end

function df_crypt_chat.show_form()
	minetest.show_formspec("df_crypt_chat:chat_form", form)
end

minetest.register_chatcommand("crp", {
	params = "<msg>",
	description = "Crypt and send message",
	func = function(param)
		df_crypt_chat.send_msg(param)
	end,
})

minetest.register_cheat("CryptChat", "Chat", function()
	df_crypt_chat.show_form()
end)