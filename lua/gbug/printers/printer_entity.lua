AddCSLuaFile()

module("gbug.Printer.Entity", package.seeall)

function Print(val)
	if not IsValid(val) then
		return {
			gbug.Colors.Comment, string.format("-- %p\n", val),
			gbug.Colors.Value, "NULL"
		}
	end

	return table.Add({
		gbug.Colors.Comment, string.format("-- %p\n", val),
		string.format("-- %s\n", val:GetClass()),
		string.format("-- %s\n", val:GetModel()),
		gbug.Colors.Value, "Entity", color_white, "(", gbug.Colors.Print, tostring(val:EntIndex()), color_white, ")\n"
	}, TablePrinter(val))
end

function Inline(val)
	local comment = "--[[ NULL ]]"

	if IsValid(val) then
		local mdl = val:GetModel()

		if mdl then
			comment = string.format("--[[ %s, %s ]]", val:GetClass(), val:GetModel())
		else
			comment = string.format("--[[ %s ]]", val:GetClass())
		end
	end

	return {
		gbug.Colors.Value, "Entity", color_white, "(", gbug.Colors.Print, tostring(val:EntIndex()), color_white, ") ",
		gbug.Colors.Comment, comment
	}
end
