AddCSLuaFile()

module("gbug.Printer.Vector", package.seeall)

function Print(val)
	return {
		gbug.Colors.Value, "Vector", color_white, "(",
		gbug.Colors.Print, tostring(math.Round(val.x, 6)), color_white, ", ",
		gbug.Colors.Print, tostring(math.Round(val.y, 6)), color_white, ", ",
		gbug.Colors.Print, tostring(math.Round(val.z, 6)), color_white, ")"
	}
end

function Inline(val)
	return {
		gbug.Colors.Value, "Vector", color_white, "(",
		gbug.Colors.Print, tostring(math.Round(val.x, 6)), color_white, ",",
		gbug.Colors.Print, tostring(math.Round(val.y, 6)), color_white, ",",
		gbug.Colors.Print, tostring(math.Round(val.z, 6)), color_white, ")"
	}
end
