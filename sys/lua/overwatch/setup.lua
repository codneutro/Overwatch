--> Overwatch hooks
local hooks = {"join", "spawn", "say", 
	"team", "startround", "leave"}

--> Attach every hooks functions
for _, hook in pairs(hooks) do
	addhook(hook, 'ow.hook.'..hook)
end