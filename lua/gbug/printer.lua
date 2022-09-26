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

function TablePrinter(val)
	local tab = val:GetTable()

	if table.IsEmpty(tab) then
		return {color_white, "{}"}
	end

	local acc = {color_white, "{\n"}
	local width = 0

	for k, v in SortedPairs(tab) do
		local key = tostring(k)

		if tonumber(key[1]) then
			key = "[" .. key .. "]"
		end

		width = math.max(width, #key)
	end

	local first = true

	for k, v in SortedPairs(tab) do
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
	end

	table.Add(acc, {
		color_white, "\n}"
	})

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
