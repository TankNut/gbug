AddCSLuaFile()

module("gbug.Printer.Angle", package.seeall)

function Print(val)
	return {
		gbug.Colors.Value, "Angle", color_white, "(",
		gbug.Colors.Print, tostring(math.Round(val.p, 6)), color_white, ", ",
		gbug.Colors.Print, tostring(math.Round(val.y, 6)), color_white, ", ",
		gbug.Colors.Print, tostring(math.Round(val.r, 6)), color_white, ")"
	}
end

function Inline(val)
	return {
		gbug.Colors.Value, "Angle", color_white, "(",
		gbug.Colors.Print, tostring(math.Round(val.p, 6)), color_white, ",",
		gbug.Colors.Print, tostring(math.Round(val.y, 6)), color_white, ",",
		gbug.Colors.Print, tostring(math.Round(val.r, 6)), color_white, ")"
	}
end
