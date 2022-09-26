AddCSLuaFile()

module("gbug.Printer.Color", package.seeall)

function Print(val)
	return {
		gbug.Colors.Comment, string.format("-- %p\n", val),
		"-- ", val, "█\n",
		gbug.Colors.Value, "Color", color_white, "(",
		gbug.Colors.Print, tostring(math.Round(val.r)), color_white, ", ",
		gbug.Colors.Print, tostring(math.Round(val.g)), color_white, ", ",
		gbug.Colors.Print, tostring(math.Round(val.b)), color_white, ", ",
		gbug.Colors.Print, tostring(math.Round(val.a)), color_white, ")"
	}
end

function Inline(val)
	return {
		gbug.Colors.Value, "Color", color_white, "(",
		gbug.Colors.Print, tostring(math.Round(val.r)), color_white, ", ",
		gbug.Colors.Print, tostring(math.Round(val.g)), color_white, ", ",
		gbug.Colors.Print, tostring(math.Round(val.b)), color_white, ", ",
		gbug.Colors.Print, tostring(math.Round(val.a)), color_white, ")",
		gbug.Colors.Comment, " --[[", val, "█", gbug.Colors.Comment, "]]--"
	}
end
