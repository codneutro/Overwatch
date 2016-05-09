-----------------------------------------------------------
-- Displays a welcome message on join
--
-- @param number id player ID
-----------------------------------------------------------
function ow.hook.join(id)
	msg2(id, string.char(169).."255255255Welcome "..player(id, "name").." !")
	msg2(id, string.char(169).."255255255This server uses Overwatch mod")
	msg2(id, string.char(169).."255255255Command: <!overwatch> on spec")
	ow.resetspecvars(id)

	if (player(id, "exist") and not player(id, "bot") and ow.enabled) then
		ow.displayhud(id)
	end
end

-----------------------------------------------------------
-- Reset player state on spawn
--
-- @param number id player ID
-----------------------------------------------------------
function ow.hook.spawn(id)
	ow.resetspecvars(id)
end

-----------------------------------------------------------
-- Update a player for specs
--
-- @param number id player ID
-- @param number src player ID (origin of the hit)
-- @param number wpn weapon id/type
-- @param number hpdmg health damages
-- @param number apdmg armor damages
-- @param number rawdmg raw damages
-- @param number oid object id
-----------------------------------------------------------
function ow.hook.hit(id, src, wpn, hpdmg, apdmg, rawdmg, oid)
	--> Update living player hp
	local hp = player(id, "health") - hpdmg
	ow.players[id].health = hp

	--> Update hud for specs
	if (ow.enabled) then
		ow.updatehud("health", id, hp)
	end
end

-----------------------------------------------------------
-- Displays overwatch on startround
--
-- @param number mode startround mode
-----------------------------------------------------------
function ow.hook.startround(mode)
	--> No more than 10 living because of performance issue
	if (#player(0, "tableliving") <= 10) then
		--> Enable overwatch + Adding hooks
		if (not ow.enabled) then
			for __, hook in ipairs({"hit", "select"}) do
				freehook(hook, "ow.hook."..hook)
				addhook(hook, "ow.hook."..hook)
			end

			ow.enabled = true
		end

		--> Re-compute everything (kick / teamchange etc.)
		ow.players = {}
		local ttOffset = 0
		local ctOffset = 0
		local number = 0

		--> Every living player
		for _, pid in pairs(player(0, "tableliving")) do
			ow.players[pid] = {}
			ow.players[pid].team = player(pid, "team")
			ow.players[pid].health = player(pid, "health")
			ow.players[pid].armor = player(pid, "armor")
			ow.players[pid].number = number

			--> Updating offset
			if (player(pid, "team") == 1) then
				ow.players[pid].offset = ttOffset
				ttOffset = ttOffset + 25
			else
				ow.players[pid].offset = ctOffset
				ctOffset = ctOffset + 25
			end

			number = number + 1
		end

		--> Display hud for spectator
		for _, pid in pairs(player(0, "table")) do
			if (player(pid, "team") == 0 and not player(pid, "bot")) then
				ow.removeGUI(pid)
				if (ow.specs[pid].enabled) then
					ow.displayhud(pid)
				end
			end
		end
	else
		ow.enabled = false

		--> Removing hooks
		for _, hook in ipairs({"hit", "select"}) do
			freehook(hook, "ow.hook."..hook)
		end

		--> Disable hud for spectator
		for _, pid in pairs(player(0, "table")) do
			if (player(pid, "team") == 0) then
				if (ow.specs[pid].enabled) then
					ow.removeGUI(pid)
				end
			end
		end
	end
end

-----------------------------------------------------------
-- Enable/Disable overwatch for a spectator
--
-- @param number id player ID
-- @param string message a message
-----------------------------------------------------------
function ow.hook.say(id, message)
	if(message == '!overwatch') then
		ow.specs[id].enabled = not ow.specs[id].enabled

		if (ow.specs[id].enabled) then
			msg2(id, string.char(169).."255255255[INFO]: Overwatch is now enabled")
		else
			msg2(id, string.char(169).."255255255[INFO]: Overwatch is now disabled")
			ow.removeGUI(id)
		end

		return 1
	end
end

-----------------------------------------------------------
-- Reset payer state on team change
--
-- @param number id player ID
-- @param number team player team (0 spec / 1 tt / 2 ct)
-- @param number look skin number
-----------------------------------------------------------
function ow.hook.team(id, team, look)
	if (team == 0) then
		ow.resetspecvars(id)
	else
		ow.resetplayervars(id)
		ow.players[id].team = team
	end
end

-----------------------------------------------------------
-- Updates specs hud on weapon change
--
-- @param number id player ID
-- @param number type weapon type
-- @param number mode weapon mode
-----------------------------------------------------------
function ow.hook.select(id, type, mode)
	if (ow.enabled) then
		ow.updatehud("weapon", id, itemtype(type, "name"))
	end
end

-----------------------------------------------------------
-- Remove a player from overwatch
--
-- @param number id player ID
-- @param number reason (kick/leave etc.)
-----------------------------------------------------------
function ow.hook.leave(id, reason)
	if (ow.enabled) then
		if (player(id, "team") == 0) then
			ow.removeGUI(id)
		else
			ow.removeFromSpecs(id)
		end
	end

	ow.players[id] = nil
	ow.specs[id] = nil
end
