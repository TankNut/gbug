local PANEL = {}

surface.CreateFont("gbug", {
	font = "Lucida Console",
	size = 14,
	weight = 400
})

local modes = {
	[gbug.TARGET_SELF]    = {"Self", gbug.Colors.Client},
	[gbug.TARGET_CLIENT]  = {"Player", gbug.Colors.Client, true},
	[gbug.TARGET_CLIENTS] = {"Players", gbug.Colors.Client},
	[gbug.TARGET_SERVER]  = {"Server", gbug.Colors.Server},
	[gbug.TARGET_GLOBAL]  = {"Global", gbug.Colors.Menu},
	[gbug.TARGET_SHARED]  = {"Shared", gbug.Colors.Menu}
}

local modeCommands = {
	["@me"] = gbug.TARGET_SELF,
	["@self"] = gbug.TARGET_SELF,
	["@ply"] = gbug.TARGET_CLIENT,
	["@cl"] = gbug.TARGET_CLIENTS,
	["@clients"] = gbug.TARGET_CLIENTS,
	["@server"] = gbug.TARGET_SERVER,
	["@sv"] = gbug.TARGET_SERVER,
	["@sh"] = gbug.TARGET_SHARED,
	["@shared"] = gbug.TARGET_SHARED,
	["@g"] = gbug.TARGET_GLOBAL,
	["@global"] = gbug.TARGET_GLOBAL
}

local localCommands = {
	[":cl"] = function(self)
		self.Buffer:SetText("")
	end
}

function PANEL:Init()
	self:SetSize(ScrW() * 0.8, ScrH() * 0.8)
	self:DockPadding(5, 5, 5, 5)

	self:BuildLayout()

	self.TargetMode = gbug.TARGET_SELF
	self.TargetArg = NULL
end

function PANEL:BuildLayout()
	self.Bottom = self:Add("DPanel")
	self.Bottom:SetTall(20)
	self.Bottom:Dock(BOTTOM)
	self.Bottom:SetPaintBackground(false)

	self.Buffer = self:Add("gbugBuffer")
	self.Buffer:Dock(FILL)

	-- Bottom

	self.Target = self.Bottom:Add("DPanel")
	self.Target:SetWide(80)
	self.Target:DockMargin(0, 0, 5, 0)
	self.Target:Dock(LEFT)

	self.Target.Paint = function(pnl, w, h)
		surface.SetDrawColor(gbug.Colors.EntryBG)
		surface.DrawRect(0, 0, w, h)

		local mode, arg = self:GetTargetMode()

		mode = modes[mode]

		if mode[3] then
			draw.SimpleText(IsValid(arg) and arg:Nick() or "Invalid", "gbug", 3, h * 0.5, IsValid(arg) and mode[2] or gbug.Colors.Error, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		else
			draw.SimpleText(mode[1], "gbug", 3, h * 0.5, mode[2], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
	end

	self.Entry = self.Bottom:Add("gbugTextEntry")
	self.Entry:Dock(FILL)

	self.Entry.OnSubmit = function(pnl, val)
		self:OnSubmit(val)
	end
end

function PANEL:Think()
	if input.IsKeyDown(KEY_ESCAPE) then
		gbug.Close()

		gui.HideGameUI()
	end
end

function PANEL:GetTargetMode()
	local val = self.Entry:GetValue()
	local mode, arg

	if val[1] == "@" then
		mode, arg = self:ParseTarget(string.Explode(" ", val)[1])
	end

	if not mode then
		return self.TargetMode, self.TargetArg
	end

	return mode, arg
end

function PANEL:ParseTarget(val)
	local args = string.Explode(":", val)
	local mode = args[1]
	local arg = args[2] or ""

	local command = modeCommands[mode]

	if not command then
		return
	end

	local config = modes[command]

	if config[3] then
		arg = Player(tonumber(arg) or 0)
	else
		arg = NULL
	end

	return command, arg
end

function PANEL:OnSubmit(val)
	local targetMode = self.TargetMode
	local targetArg = self.TargetArg

	if val[1] == ":" then
		local command = localCommands[val]

		self.Buffer:WriteLine(0, {val})

		if not command then
			self:HandleError("Unknown command")

			return
		end

		command(self)

		return
	elseif val[1] == "@" then
		local split = string.Explode(" ", val)

		local mode, arg = self:ParseTarget(split[1])

		if mode then
			targetMode = mode
			targetArg = arg
		end

		val = table.concat(split, " ", 2)
	end

	if #val == 0 then
		self.TargetMode = targetMode
		self.TargetArg = targetArg

		return
	end

	self.Buffer:WriteLine(0, {val})

	local mode = modes[targetMode]

	if mode[3] and not IsValid(targetArg) then
		self:HandleError("Invalid target")

		return
	end

	gbug.Submit(targetMode, targetArg, val)
end

function PANEL:WriteLine(from, tab)
	if from then
		local prefix

		if IsValid(from) then
			prefix = string.format("[%s (%s)] ", from:SteamID(), from:Nick())
		else
			prefix = "[SERVER] "
		end

		local writeData = {gbug.Colors.Received, prefix}

		table.Add(writeData, tab)

		self.Buffer:WriteLine(1, writeData)
	else
		self.Buffer:WriteLine(1, tab)
	end
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(0, 0, 0, 250)
	surface.DrawRect(0, 0, w, h)
end

derma.DefineControl("gbugMenu", "The menu used for gbug", PANEL, "EditablePanel")
