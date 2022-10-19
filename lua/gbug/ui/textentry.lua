local PANEL = {}

function PANEL:Init()
	self:SetFont("gbug")

	self:SetHistoryEnabled(true)
	self:SetEnterAllowed(false) -- Handled in OnKeyCode

	local val = cookie.GetString("gbug.LastLine", "")

	if val != "" then
		table.insert(self.History, val)
	end
end

function PANEL:OnKeyCode(key)
	if key == KEY_ENTER then
		local val = self:GetValue()

		self:OnSubmit(val)

		if self.History[#self.History] != val then
			table.insert(self.History, val)
		end

		cookie.Set("gbug.LastLine", val)

		self.HistoryPos = 0
		self:SetText("")
	end
end

function PANEL:OnSubmit(val)
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(gbug.Colors.EntryBG)
	surface.DrawRect(0, 0, w, h)

	self:DrawTextEntryText(color_white, Color(68, 131, 181), color_white)
end

derma.DefineControl("gbugTextEntry", "A custom DTextEntry panel for gbug", PANEL, "DTextEntry")
