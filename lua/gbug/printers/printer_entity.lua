AddCSLuaFile()

module("gbug.Printer.Entity", package.seeall)

function Print(val)
	if not IsValid(val) and val != game.GetWorld() then
		return {
			gbug.Colors.Comment, string.format("-- %p\n", val),
			gbug.Colors.Value, "NULL"
		}
	end

	local mdl = val:GetModel()

	return table.Add({
		gbug.Colors.Comment, string.format("-- %p\n", val),
		string.format("-- %s\n", val:GetClass()),
		mdl and string.format("-- %s\n", val:GetModel()) or "",
		gbug.Colors.Value, "Entity", color_white, "(", gbug.Colors.Print, tostring(val:EntIndex()), color_white, ")\n"
	}, TablePrinter(val))
end

function Inline(val)
	local comment = "--[[ NULL ]]"

	if IsValid(val) then
		local mdl = val:GetModel()

		comment = mdl and string.format("--[[ %s, %s ]]", val:GetClass(), val:GetModel()) or string.format("--[[ %s ]]", val:GetClass())
	end

	return {
		gbug.Colors.Value, "Entity", color_white, "(", gbug.Colors.Print, tostring(val:EntIndex()), color_white, ") ",
		gbug.Colors.Comment, comment
	}
end
