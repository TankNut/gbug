AddCSLuaFile()

module("gbug", package.seeall)

Indent = "  "

include("detours.lua")
include("net.lua")
include("printer.lua")

TARGET_SELF    = 1
TARGET_CLIENT  = 2
TARGET_CLIENTS = 3
TARGET_SERVER  = 4
TARGET_SHARED  = 5
TARGET_GLOBAL  = 6

function CheckAccess(ply)
	return hook.Run("gbug.Access", ply) or ply:IsSuperAdmin()
end

if CLIENT then
	hook.Add("Initialize", "gbug", function()
		CreateUI()
	end)

	function CreateUI()
		if IsValid(Panel) then
			Panel:Remove()
		end

		Panel = vgui.Create("gbugMenu")
		Panel:MakePopup()
		Panel:Center()
		Panel:SetVisible(false)
	end

	function Open()
		Panel:SetVisible(true)
		Panel.Entry:RequestFocus()
	end

	function Close()
		Panel:SetVisible(false)
	end

	function Toggle()
		if Panel:IsVisible() then
			Close()
		else
			Open()
		end
	end

	concommand.Add("gbug_toggle", function() if not CheckAccess(LocalPlayer()) then return end Toggle() end)
	concommand.Add("gbug_reload", function() if not CheckAccess(LocalPlayer()) then return end CreateUI() end)

	function Submit(mode, arg, str)
		if not CheckAccess(LocalPlayer()) then
			return
		end

		if mode == TARGET_SELF or mode == TARGET_SHARED then
			Run(str)
		end

		if mode != TARGET_SELF then
			net.Start("gbug.Run")
				net.WriteUInt(mode, 3)
				net.WriteEntity(arg)
				net.WriteString(str)
			net.SendToServer()
		end
	end
end

MessageBuffer = {}

function WriteToBuffer(...)
	for _, v in pairs({...}) do
		MessageBuffer = MessageBuffer .. tostring(v)
	end
end

function FlushMessageBuffer(ply)
	if table.IsEmpty(MessageBuffer) then
		return
	end

	table.insert(MessageBuffer, 1, gbug.Colors.Print)

	HandleOutput(ply, MessageBuffer)

	table.Empty(MessageBuffer)
end

function ErrorOut(ply, err)
	local sub = string.find(err, "\n\t[C]: in function 'xpcall'", 1, true) -- Anything beyond this is irrelevant

	if sub then
		err = string.sub(err, 1, sub - 1)
	end

	HandleOutput(ply, {gbug.Colors.Error, err})
end

function HandleOutput(ply, tab)
	if IsValid(ply) then
		if CLIENT then
			net.Start("gbug.Output")
				net.WriteEntity(ply)
				NetWrite(tab)
			net.SendToServer()
		else
			net.Start("gbug.Output")
				net.WriteEntity(NULL)
				NetWrite(tab)
			net.Send(ply)
		end
	else
		Panel:WriteLine(ply, tab)
	end
end

function CreateEnv(func, ply)
	local env = {}

	env.gm = gmod.GetGamemode()

	local me = IsValid(ply) and ply or LocalPlayer()

	env.me = me
	env.sid = me:SteamID()

	env.here = me:GetPos()
	env.eye = me:EyePos()

	local tr = me:GetEyeTrace()

	env.tr = tr

	env.there = tr.HitPos
	env.this = tr.Entity

	if CLIENT then
		local lp = LocalPlayer()

		env.lp = lp
		env.lsid = lp:SteamID()

		env.lhere = lp:GetPos()
		env.leye = lp:EyePos()

		local ltr = lp:GetEyeTrace()

		env.ltr = ltr

		env.lthere = ltr.HitPos
		env.lthis = ltr.Entity
	end

	hook.Run("gbug.CreateEnv", env)

	setfenv(func, setmetatable(env, {
		__index = _G
	}))
end

function Compile(str)
	local compiled = CompileString("return " .. str, "gbug", false)

	if isstring(compiled) then
		compiled = CompileString(str, "gbug", false)

		if isstring(compiled) then -- Another error
			return nil, compiled
		end
	end

	return compiled, nil
end

function Run(str, ply)
	local func, compileError = Compile(str, "gbug")

	if not func then
		ErrorOut(ply, compileError)

		return
	end

	CreateEnv(func, ply)
	CreateDetours(ply)

	local ok, returnVal = xpcall(func, function(err)
		ErrorOut(ply, debug.traceback(err))
	end)

	RestoreDetours()
	FlushMessageBuffer(ply)

	if not ok then
		return
	end

	if returnVal != nil then
		HandleOutput(ply, Print(returnVal))
	end
end
