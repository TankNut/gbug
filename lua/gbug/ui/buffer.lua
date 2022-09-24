local PANEL = {}

function PANEL:PerformLayout()
	self:SetFontInternal("gbug")
	self:SetFGColor(color_white)
end

function PANEL:SetWriteColor(col)
	self:InsertColorChange(col.r, col.g, col.b, col.a)
end

function PANEL:Write(indent, tab)
	local offset = string.rep(gbug.Indent, indent)

	self:AppendText(offset)

	for _, v in pairs(tab) do
		if isstring(v) then
			v = string.Replace(v, "\n", "\n" .. offset)
			v = string.Replace(v, "\t", gbug.Indent)

			self:AppendText(v)
		else
			self:SetWriteColor(v)
		end
	end

	self:SetWriteColor(color_white)
end

function PANEL:WriteLine(indent, tab)
	self:Write(indent, tab)
	self:AppendText("\n")
end

derma.DefineControl("gbugBuffer", "A custom RichText panel for gbug", PANEL, "RichText")
