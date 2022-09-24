AddCSLuaFile()

module("gbug.Printer.String", package.seeall)

function Print(val)
	return {
		gbug.Colors.Comment, string.format("-- %s\n", string.NiceSize(#val)),
		gbug.Colors.String, "\"", val, "\""
	}
end

function Inline(val)
	return {gbug.Colors.String, "\"", val, "\""}
end
