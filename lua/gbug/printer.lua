AddCSLuaFile()

Printers = Printers or {}
CustomPrinters = CustomPrinters or {}

function AddPrinter(typeid, mod)
	Printers[typeid] = mod
end

function AddCustomPrinter(id, check, mod)
	CustomPrinters[id] = {check, mod}
end

function Print(val, inline)
	if istable(val) then
		for _, v in pairs(CustomPrinters) do
			if v[1](val) then
				return RunPrinter(val, v[2])
			end
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

include("printers/printer_bool.lua")
include("printers/printer_string.lua")

AddPrinter(TYPE_BOOL, "Bool")
AddPrinter(TYPE_STRING, "String")
