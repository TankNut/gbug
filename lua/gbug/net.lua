AddCSLuaFile()

if SERVER then
	util.AddNetworkString("gbug.Run")
	util.AddNetworkString("gbug.Output")
end

function NetWrite(tab)
	local data = {}

	local lookup = {}
	local atlas = {}

	local lastColor = false

	for k, v in pairs(tab) do
		if IsColor(v) then
			local hash = string.format("%i %i %i", v.r, v.g, v.b)

			if lookup[hash] then
				table.insert(data, lookup[hash])
			else
				local index = table.insert(atlas, v)

				table.insert(data, index)

				lookup[hash] = index
			end

			lastColor = true
		else
			if not lastColor then
				data[#data] = data[#data] .. v
			else
				lastColor = false

				table.insert(data, v)
			end
		end
	end

	net.WriteUInt(#atlas, 8) -- If you manage to find a use case for more than 255 colors at once then please seek professional help

	for _, v in pairs(atlas) do
		net.WriteColor(v, false)
	end

	net.WriteBool(isnumber(data[1])) -- Color first?
	net.WriteUInt(#data, 10)

	for _, v in pairs(data) do
		if isnumber(v) then
			net.WriteUInt(v, 8)
		else
			net.WriteString(v)
		end
	end
end

function NetRead()
	local atlas = {}

	for i = 1, net.ReadUInt(8) do
		atlas[i] = net.ReadColor(false)
	end

	local colorNext = net.ReadBool()
	local data = {}

	for i = 1, net.ReadUInt(10) do
		if colorNext then
			table.insert(data, atlas[net.ReadUInt(8)])
		else
			table.insert(data, net.ReadString())
		end

		colorNext = not colorNext
	end

	return data
end

function NetRelay()
	local atlas = net.ReadUInt(8)

	net.WriteUInt(atlas, 8)

	for i = 1, atlas do
		net.WriteColor(net.ReadColor(false), false)
	end

	local colorNext = net.ReadBool()
	local count = net.ReadUInt(10)

	net.WriteBool(colorNext)
	net.WriteUInt(count, 10)

	for i = 1, count do
		if colorNext then
			net.WriteUInt(net.ReadUInt(8), 8)
		else
			net.WriteString(net.ReadString())
		end

		colorNext = not colorNext
	end
end

if CLIENT then
	net.Receive("gbug.Run", function()
		local ply = net.ReadEntity()
		local code = net.ReadString()

		gbug.Run(code, ply)
	end)

	net.Receive("gbug.Output", function()
		local from = net.ReadEntity()
		local data = gbug.NetRead()

		gbug.Panel:WriteLine(from, data)
	end)
else
	net.Receive("gbug.Run", function(_, ply)
		if not gbug.CheckAccess(ply) then
			return
		end

		local mode = net.ReadUInt(3)
		local target = net.ReadEntity()
		local code = net.ReadString()

		if mode == gbug.TARGET_SERVER or mode == gbug.TARGET_SHARED or mode == gbug.TARGET_GLOBAL then
			gbug.Run(code, ply)
		end

		if mode == gbug.TARGET_CLIENT and IsValid(target) then
			net.Start("gbug.Run")
				net.WriteEntity(ply)
				net.WriteString(code)
			net.Send(target)
		elseif mode == gbug.TARGET_CLIENTS or mode == gbug.TARGET_GLOBAL then
			net.Start("gbug.Run")
				net.WriteEntity(ply)
				net.WriteString(code)
			net.Broadcast()
		end
	end)

	net.Receive("gbug.Output", function(_, ply)
		local target = net.ReadEntity()

		if not gbug.CheckAccess(target) then
			return
		end

		net.Start("gbug.Output")
			net.WriteEntity(ply)
			gbug.NetRelay()
		net.Send(target)
	end)
end
