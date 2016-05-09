--> Overwatch main table
ow = {
	hook = {}, --> Hooks container
	specs = {}, --> Spectator array
	players = {}, --> Alive players array
	enabled = false, --> Overwatch is globally enabled
}

-----------------------------------------------------------
-- Resets specs variables
--
-- @param number id player ID
-----------------------------------------------------------
function ow.resetspecvars(id)
	ow.specs[id] = {
		enabled = true,
		images = {},
		texts = {},
	};
end

-----------------------------------------------------------
-- Resets player array
--
-- @param number id player ID
-----------------------------------------------------------
function ow.resetplayervars(id)
	ow.players[id] = {health = 0, armor = 0, team = 0, 
		offset = 0, number = 0}
end

-----------------------------------------------------------
-- Displays a specified image
--
-- @param number id player ID
-- @param string key the image key
-- @param string path image's path
-- @param number x image's x position
-- @param number mode image's mode
-----------------------------------------------------------
function ow.displayimage(id, key, path, x, y, mode)
	ow.removeimage(id, key)
	ow.specs[id].images[key] = image(path, x, y, mode, id)
end

-----------------------------------------------------------
-- Removes a specifc image from a player
--
-- @param number id player ID
-- @param string key image's key
-----------------------------------------------------------
function ow.removeimage(id, key)
	--> The image is currently displayed and exists !!
	if (ow.specs[id].images[key]) then
		freeimage(ow.specs[id].images[key])
		ow.specs[id].images[key] = nil
	end
end

-----------------------------------------------------------
-- Scales up an image
--
-- @param number id player ID
-- @param string key image's key
-- @param number scaleX width factor
-- @param number scaleY height factor
-----------------------------------------------------------
function ow.scaleimage(id, key, scaleX, scaleY)
	if (ow.specs[id].images[key]) then
		imagescale(ow.specs[id].images[key], scaleX, scaleY)
	end
end

-----------------------------------------------------------
-- Shift an image at the specified position
--
-- @param number id player ID
-- @param string key image's key
-- @param number x image's coordinate
-- @param number y image's coordinate
-- @param number rot image's rotation
-----------------------------------------------------------
function ow.moveimage(id, key, x, y, rot)
	if (ow.specs[id].images[key]) then
		imagepos(ow.specs[id].images[key], x, y, rot)
	end
end

-----------------------------------------------------------
-- Displays a text at the specified position
--
-- @param number id player ID
-- @param number tid text's ID
-- @param string text a text
-- @param number x text's position (x in pixels)
-- @param number y text's position (y in pixels)
-- @param string color text's color (RGB)
-- @param number align (0 left / 1 center / 2 right)
-----------------------------------------------------------
function ow.displaytxt(id, tid, text, x, y, color, align)
	local color = string.char(169).. ("255255255" or color)
	parse('hudtxt2 '..id..' '..tid..' "'..color..text..'" '..x..' '..y..' '..(align or 0))
	ow.specs[id].texts[tid] = tid
end

-----------------------------------------------------------
-- Removes the specified text
--
-- @param number id player ID
-- @param number key text's ID
-----------------------------------------------------------
function ow.removetxt(id, key)
	if (ow.specs[id].texts[key]) then
		parse('hudtxt2 '..id..' '..ow.specs[id].texts[key])
		ow.specs[id].texts[key] = nil
	end
end

-----------------------------------------------------------
-- Display hud for a specified player (called on startround)
--
-- @param number id player ID
-----------------------------------------------------------
function ow.displayhud(id)
	--> All living players
	for pid, p in pairs(ow.players) do
		--> terrorist
		if(p.team == 1) then
			--> Images
			ow.displayimage(id, "bg"..pid, "gfx/overwatch/bg.png", 100, 200 + p.offset, 2)
			ow.displayimage(id, "tt"..pid, "gfx/overwatch/tt.png", 100, 200 + p.offset, 2)
			ow.scaleimage(id, "tt"..pid, p.health * 2, 1)

			--> Texts
			ow.displaytxt(id, p.number, player(pid, "name"), 30, 193 + p.offset)
			ow.displaytxt(id, (10 + p.number), itemtype(player(pid, "weapontype"),
				"name"), 205, 193 + p.offset)
			ow.displaytxt(id, (20 + p.number), p.health, 5, 193 + p.offset)
		else
			--> Images
			ow.displayimage(id, "bg"..pid, "gfx/overwatch/bg.png", 540, 200 + p.offset, 2)
			ow.displayimage(id, "ct"..pid, "gfx/overwatch/ct.png", 540, 200 + p.offset, 2)
			ow.scaleimage(id, "ct"..pid, p.health * 2, 1)

			--> Texts
			ow.displaytxt(id, p.number, player(pid, "name"), 600, 193 + p.offset, "255255255", 2)
			ow.displaytxt(id, (10 + p.number), itemtype(player(pid, "weapontype"),
				"name"), 435, 193 + p.offset, "255255255", 2)
			ow.displaytxt(id, (20 + p.number), p.health, 610, 193 + p.offset)
		end
	end
end

-----------------------------------------------------------
-- Update specs hud
--
-- @param number data
-----------------------------------------------------------
function ow.updatehud(data, pid, value)
	if (data:match('health')) then
		--> Scale health bar
		local hpDiff = 100 - value
		local healthX, healthY, hpX 
		local index = player(pid, "team")

		if (index == 1) then
			index = "tt"..pid
			healthX = 100 - hpDiff
			hpX = 5
		else
			index = "ct"..pid
			healthX = 540 + hpDiff
			hpX = 610
		end

		healthY = 200 + ow.players[pid].offset

		--> All specs
		for _, sid in pairs(player(0, "table")) do
			if (player(sid, "team") == 0) then
				if (ow.specs[sid].enabled) then
					ow.displaytxt(sid, (20 + ow.players[pid].number),
						value, hpX, 193 + ow.players[pid].offset)
					ow.moveimage(sid, index, healthX, healthY, 0)
					ow.scaleimage(sid, index, value * 2, 1)
				end
			end
		end
	elseif (data:match('weapon')) then
		--> All specs
		local align = 0
		local wpnX, wpnY

		wpnY = 193 + ow.players[pid].offset

		for _, sid in pairs(player(0, "table")) do
			if (player(sid, "team") == 0) then
				if (ow.specs[sid].enabled) then
					if (ow.players[pid].team == 1) then
						align = 0
						wpnX = 205 
					else
						align = 2
						wpnX = 435
					end

					ow.displaytxt(sid, (10 + ow.players[pid].number),
						value, wpnX, wpnY, "255255255", align)
				end
			end
		end
	end
end

--> Remove the specified player from all specs
function ow.removeFromSpecs(id)
	local index = player(id, "team")

	--> Constructs index depending on team
	if (index == 1) then
		index = "tt"..id
	else
		index = "ct"..id
	end

	--> Iterate over every spectator
	for _, sid in pairs(player(0, "table")) do
		if (player(sid, "team") == 0) then
			--> Remove all related data to the specified player
			if (ow.specs[sid].enabled) then
				ow.removeimage(sid, "bg"..id)
				ow.removeimage(sid, index)
				ow.removetxt(sid, ow.players[id].number)
				ow.removetxt(sid, 10 + ow.players[id].number)
				ow.removetxt(sid, 20 + ow.players[id].number)
			end
		end
	end
end

--> Removes text + images of the specified player
function ow.removeGUI(id)
	--> Remove all images
	for key, __ in pairs(ow.specs[id].images) do
		ow.removeimage(id, key)
	end

	--> Remove all texts
	for key, __ in pairs(ow.specs[id].texts) do
		ow.removetxt(id, key)
	end
end