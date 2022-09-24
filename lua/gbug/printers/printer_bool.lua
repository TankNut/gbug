AddCSLuaFile()

module("gbug.Printer.Bool", package.seeall)

function Print(val)
	return {gbug.Colors.Bool, tostring(val)}
end
