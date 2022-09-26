AddCSLuaFile()

Printers = Printers or {}
CustomPrinters = CustomPrinters or {}

function AddPrinter(typeid, mod)
	Printers[typeid] = mod

	include(string.format("printers/printer_%s.lua", string.lower(mod)))
end

function AddCustomPrinter(id, check, mod)
	CustomPrinters[id] = {check, mod}

	include(string.format("printers/printer_%s.lua", string.lower(mod)))
end

function Print(val, inline)
	for _, v in pairs(CustomPrinters) do
		if v[1](val) then
			return RunPrinter(val, v[2], inline)
		end
	end

	local mod = Printers[TypeID(val)]

	if mod then
		return RunPrinter(val, mod, inline)
	end

	return {gbug.Colors.Print, tostring(val)}
end

function RunPrinter(val, mod, inline)
	mod = gbug.Printer[mod]

	if not mod then
		return gbug.Colors.Print, tostring(val)
	end

	if inline and mod.Inline then
		return mod.Inline(val)
	else
		return mod.Print(val)
	end
end

local tableLimit = 140

function TablePrinter(val)
	local tab = istable(val) and val or val:GetTable()
	local count = table.Count(tab)

	if table.IsEmpty(tab) then
		return {color_white, "{}"}
	end

	local acc = {color_white, "{\n"}
	local width = 0

	local i = 0

	for k, v in SortedPairs(tab) do
		if i >= tableLimit then
			i = 0

			break
		end

		local key = tostring(k)

		if tonumber(key[1]) then
			key = "[" .. key .. "]"
		end

		width = math.max(width, #key)
		i = i + 1
	end

	local first = true

	for k, v in SortedPairs(tab) do
		if i >= tableLimit then
			table.Add(acc, {gbug.Colors.Comment, "\n", gbug.Indent, string.format("%s more...", count - tableLimit)})

			break
		end

		local prefix = {}

		if first then
			first = false
		else
			prefix = {color_white, ",\n"}
		end

		local key = {gbug.Indent, gbug.Colors.Value, string.format("%-" .. width .. "s", k), color_white, " = "}
		local value = gbug.Print(v, true)

		table.Add(acc, prefix)
		table.Add(acc, key)
		table.Add(acc, value)

		i = i + 1
	end

	table.Add(acc, {
		color_white, "\n}"
	})

	if not table.IsEmpty(tab) then
		table.Add(acc, {
			gbug.Colors.Comment, string.format("\n-- %s total %s.", count, count > 1 and "entries" or "entry")
		})
	end

	return acc
end

AddPrinter(TYPE_BOOL, "Bool")
AddPrinter(TYPE_STRING, "String")
AddPrinter(TYPE_FUNCTION, "Function")
AddPrinter(TYPE_ENTITY, "Entity")
AddPrinter(TYPE_VECTOR, "Vector")
AddPrinter(TYPE_ANGLE, "Angle")

AddCustomPrinter("player", function(val) return IsEntity(val) and val:IsPlayer() end, "Player")
AddCustomPrinter("color", IsColor, "Color")
