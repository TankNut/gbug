AddCSLuaFile()

function CreateDetours(ply)
	Detours = {}

	local function detour(func, callback)
		Detours[func] = _G[func]

		_G[func] = callback
	end

	detour("print", function(...)
		local tab = {...}

		for k, v in pairs(tab) do
			tab[k] = tostring(v)
		end

		HandleOutput(ply, {gbug.Colors.Print, table.concat(tab, Indent)})
	end)

	detour("MsgC", function(...)
		local tab = {...}

		for k, v in pairs(tab) do
			if not IsColor(v) then
				tab[k] = tostring(v)
			end
		end

		table.insert(tab, 1, gbug.Colors.Print)
		HandleOutput(ply, tab)
	end)

	detour("PrintTable", function(tab, indent, done)
		indent = indent or 0
		done = done or {}

		local keys = table.GetKeys(t)

		table.sort(keys, function(a, b)
			if isnumber(a) and isnumber(b) then
				return a < b
			end

			return tostring(a) < tostring(b)
		end)

		done[t] = true

		for i = 1, #keys do
			local key = keys[i]
			local value = t[key]

			WriteToBuffer(string.rep("\t", indent))

			if istable(value) and not done[value] then
				done[value] = true

				WriteToBuffer(key, ":\n")

				PrintTable(value, indent + 2, done)

				done[value] = nil
			else
				WriteToBuffer(key, "\t=\t", value, "\n")
			end
		end

		if indent == 0 then
			FlushMessageBuffer(ply)
		end
	end)
end

function RestoreDetours()
	for k, v in pairs(Detours) do
		_G[k] = v
	end
end