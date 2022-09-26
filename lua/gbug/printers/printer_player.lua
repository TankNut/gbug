AddCSLuaFile()

module("gbug.Printer.Player", package.seeall)



function Print(val)
	return table.Add({
		gbug.Colors.Comment, string.format("-- %p\n", val),
		"-- player\n",
		string.format("-- %s\n", val:SteamID()),
		string.format("-- %s\n", val:Nick()),
		gbug.Colors.Value, "Player", color_white, "(", gbug.Colors.Print, tostring(val:UserID()), color_white, ")\n"
	}, TablePrinter(val))
end

function Inline(val)
	return {
		gbug.Colors.Value, "Player", color_white, "(", gbug.Colors.Print, tostring(val:UserID()), color_white, ") ",
		gbug.Colors.Comment, string.format("--[[ %s, %s ]]", val:SteamID(), val:UserID())
	}
end
