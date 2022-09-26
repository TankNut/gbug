AddCSLuaFile()

module("gbug.Printer.Entity", package.seeall)

function Print(val)
	return table.Add({
		gbug.Colors.Comment, string.format("-- %p\n", val),
		string.format("-- %s\n", val:GetClass()),
		string.format("-- %s\n", val:GetModel()),
		gbug.Colors.Value, "Entity", color_white, "(", gbug.Colors.Print, tostring(val:EntIndex()), color_white, ")\n"
	}, TablePrinter(val))
end

function Inline(val)
	return {
		gbug.Colors.Value, "Entity", color_white, "(", gbug.Colors.Print, tostring(val:EntIndex()), color_white, ") ",
		gbug.Colors.Comment, string.format("--[[ %s, %s ]]", val:GetClass(), val:GetModel())
	}
end
