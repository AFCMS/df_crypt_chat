df_crypt_chat = {}

local string = string
local table = table
local math = math

local pairs = pairs

local F = minetest.formspec_escape
local C = minetest.colorize

local prefix = minetest.settings:get("df_crypt_chat.prefix") or "ECR:"
local format = minetest.settings:get("df_crypt_chat.server_message_format")
local key = minetest.settings:get("df_crypt_chat.key")

if key == nil then
	key = "abcedfg" --default key
end

minetest.register_on_mods_loaded(function()
	if key == "abcedfg" then
		minetest.display_chat_message(C("red", "[CryptChat] You are using the default crypt key! This isn't secure at all!"))
	end
end)

local char_mapping = {
	a = 1,
	b = 2,
	c = 3,
	d = 4,
	e = 5,
	f = 6,
	g = 7,
	h = 8,
	i = 9,
	j = 10,
	k = 11,
	l = 12,
	m = 13,
	n = 14,
	o = 15,
	p = 16,
	q = 17,
	r = 18,
	s = 19,
	t = 20,
	u = 21,
	v = 22,
	w = 23,
	x = 24,
	y = 25,
	z = 26,
	[" "] = 27,
	["0"] = 28,
	["1"] = 29,
	["2"] = 30,
	["3"] = 31,
	["4"] = 32,
	["5"] = 33,
	["6"] = 34,
	["7"] = 35,
	["8"] = 36,
	["9"] = 37,
}

local function is_allowed(str)
	for i = 1, #str do
		local char = string.sub(str, i, i)
		if not char_mapping[char] then
			return false
		end
	end
	return true
end

local function add_chars(char1, char2)
	local nb1 = char_mapping[char1]
	local nb2 = char_mapping[char2]
	local nb = nb1 + nb2
	if nb > 37 then
		nb = nb - 37
	end
	for name,int in pairs(char_mapping) do
		if int == nb then return name end
	end
end

local function substract_chars(char1, char2)
	local nb1 = char_mapping[char1]
	local nb2 = char_mapping[char2]
	local nb = nb1 - nb2
	if nb < 0 then
		nb = nb + 37
	end
	for name,int in pairs(char_mapping) do
		if int == nb then return name end
	end
end

local function key_to_string(lengh)
	return string.rep(key, math.ceil(lengh/#key))
end

function df_crypt_chat.encrypt(msg)
	local ecr_table = {}
	local key_string = key_to_string(#msg)
	for i = 1, #msg do
		local char1 = string.sub(msg, i, i)
		local char2 = string.sub(key_string, i, i)
		table.insert(ecr_table, add_chars(char1, char2))
	end
	--ecr_table = {"a", "b", "c"}
	return table.concat(ecr_table)
end

function df_crypt_chat.decrypt(msg)
	local ecr_table = {}
	local key_string = key_to_string(#msg)
	for i = 1, #msg do
		local char1 = string.sub(msg, i, i)
		local char2 = string.sub(key_string, i, i)
		table.insert(ecr_table, substract_chars(char1, char2))
	end
	--ecr_table = {"a", "b", "c"}
	return table.concat(ecr_table)
end

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
			local decrypted = df_crypt_chat.decrypt(crypted_msg)
			minetest.display_chat_message(C("blue", "[CryptChat] RECEIVING ("..playername.."): "..decrypted))
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
	if msg == "" then
		minetest.display_chat_message(C("red", "[CryptChat] MESSAGE IS EMPTY:"))
	elseif is_allowed(msg) then
		local encrypted = df_crypt_chat.encrypt(msg)
		minetest.send_chat_message(prefix..encrypted)
		minetest.display_chat_message(C("blue", "[CryptChat] SENDING: "..msg))
	else
		minetest.display_chat_message(C("red", "[CryptChat] MESSAGE CONTAINS BAD CHARS: "..msg))
	end
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