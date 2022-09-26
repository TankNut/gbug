AddCSLuaFile()

module("gbug.Printer.Player", package.seeall)

function Print(val)
	return {
		gbug.Colors.Comment, "-- player\n",
		string.format("-- %s\n", val:SteamID()),
		string.format("-- %s\n", val:Nick()),
		gbug.Colors.Value, "Player", color_white, "(", gbug.Colors.Print, tostring(val:UserID()), color_white, ")"
	}
end

function Inline(val)
	return {
		gbug.Colors.Value, "Player", color_white, "(", gbug.Colors.Print, tostring(val:UserID()), color_white, ")",
		gbug.Colors.Comment, string.format("--[[ %s, %s ]]", val:SteamID(), val:UserID())
	}
end
