--------------------------------------
-- overwatch.lua
-- Overwatch mod (Based on CSGO Replay)
--
-- @author x[N]ir
--------------------------------------

--> Init
if not ow then
	--> Executing every files
	for _, file in ipairs({'variables', 'hook', 'setup'}) do
		dofile('sys/lua/overwatch/'..file..'.lua')
	end
else
	print(string.char(169)..
		"25500000[ERROR]: Overwatch mod is already launched !")
end

