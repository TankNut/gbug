AddCSLuaFile()

module("gbug.Printer.Function", package.seeall)

function Print(val)
	local info = debug.getinfo(val, "S")
	local native = info.linedefined == -1

	return {
		gbug.Colors.Comment, string.format("-- %p\n", val),
		native and "-- Native\n" or string.format("-- %s: %s-%s\n", info.short_src, info.linedefined, info.lastlinedefined),
		gbug.Colors.Function, "function", color_white, "(...) ", gbug.Colors.Function, "end"
	}
end

function Inline(val)
	local info = debug.getinfo(val, "S")
	local native = info.linedefined == -1

	return {
		gbug.Colors.Function, "function", color_white, "(...) ", gbug.Colors.Function, "end ",
		gbug.Colors.Comment, native and "--[[ Native ]]" or string.format("--[[ %s: %s-%s ]]", info.short_src, info.linedefined, info.lastlinedefined),
	}
end
