AddCSLuaFile()

module("gbug", package.seeall)

Indent = "    "

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
		table.insert(MessageBuffer, tostring(v))
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
	env.GM = env.gm
	env.GAMEMODE = env.gm

	-- Player vars

	local me = IsValid(ply) and ply or LocalPlayer()

	env.me = me

	if CLIENT then
		env.lp = LocalPlayer()
	end

	local function playerEnv(key, callback)
		env[key] = callback(me)

		if CLIENT then
			env["l" .. key] = callback(LocalPlayer(), true)
		end
	end

	playerEnv("sid", function(p) return p:SteamID() end)
	playerEnv("here", function(p) return p:GetPos() end)
	playerEnv("eye", function(p) return p:EyePos() end)
	playerEnv("tr", function(p) return p:GetEyeTrace() end)
	playerEnv("there", function(_, l) return env[l and "ltr" or "tr"].HitPos end)
	playerEnv("this", function(_, l) return env[l and "ltr" or "tr"].Entity end)
	playerEnv("gun", function(p) return p:GetActiveWeapon() end)
	playerEnv("swep", function(p) return p:GetActiveWeapon() end)

	-- Functions

	env.Console = function(str)
		RunConsoleCommand(unpack(string.Explode(" ", str)))
	end

	env.Sine = function(min, max, rate)
		return ((min - max) * math.sin(CurTime() * (rate or 1)) + max + min) * 0.5
	end

	env.Sound = function(str)
		return sound.GetProperties(str)
	end

	env.FindSounds = function(str)
		local tab = {}

		str = string.lower(str)

		for _, v in pairs(sound.GetTable()) do
			if string.find(string.lower(v), str) then
				tab[#tab + 1] = v
			end
		end

		return tab
	end

	if SERVER then
		env.CreateEntity = function(class, pos, ang, kv)
			local ent = ents.Create(class)

			ent:SetPos(pos or vector_origin)
			ent:SetAngles(ang or angle_zero)

			if kv then
				for k, v in pairs(kv) do
					ent:SetKeyValue(k, v)
				end
			end

			ent:Spawn()
			ent:Activate()

			return ent
		end

		env.NamedEntities = function(filter)
			filter = filter or ""

			local tab = {}

			for _, v in pairs(ents.GetAll()) do
				local name = v:GetName()

				if not v:IsPlayer() and name != "" and string.find(name, filter) then
					tab[name] = v
				end
			end

			if table.Count(tab) == 1 then
				local _, val = next(tab)

				return val
			end

			return tab
		end
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

	local res = {xpcall(func, function(err)
		ErrorOut(ply, debug.traceback(err))
	end)}

	RestoreDetours()
	FlushMessageBuffer(ply)

	if not res[1] then
		return
	end

	if res[2] != nil then
		for k, v in pairs(res) do
			if k == 1 then
				continue
			end

			HandleOutput(ply, Print(v))
		end
	end
end
