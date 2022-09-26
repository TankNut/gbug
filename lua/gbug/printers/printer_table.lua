AddCSLuaFile()

module("gbug.Printer.Table", package.seeall)

function Print(val)
	return table.Add({
		gbug.Colors.Comment, string.format("-- %p\n", val)
	}, TablePrinter(val))
end

function Inline(val)
	if table.IsEmpty(val) then
		return {color_white, "{}"}
	end

	return {
		color_white, "{", gbug.Colors.Comment, string.format("--[[ table: %p ]]", val)
	}
end
