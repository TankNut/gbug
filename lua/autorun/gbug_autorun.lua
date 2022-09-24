include("gbug/gbug.lua")
include("gbug/colors.lua")

AddCSLuaFile("gbug/ui/menu.lua")
AddCSLuaFile("gbug/ui/buffer.lua")
AddCSLuaFile("gbug/ui/textentry.lua")

if CLIENT then
	include("gbug/ui/menu.lua")
	include("gbug/ui/buffer.lua")
	include("gbug/ui/textentry.lua")
end
