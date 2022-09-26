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
			return RunPrinter(val, v[2])
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

AddPrinter(TYPE_BOOL, "Bool")
AddPrinter(TYPE_STRING, "String")
