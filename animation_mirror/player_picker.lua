local AnimationMirror = require("./core")

local api = {}

function pings.AnimationMirror_player_picked(uuid)
	AnimationMirror.begin_copying(uuid)
end

function api.pick_player()
	if not host:isHost() then
		return false, "NOT_HOST"
	end
	local start_pos = client:getCameraPos()
	local end_pos = start_pos + client:getCameraDir() * host:getReachDistance()
	local entity, _ = raycast:entity(start_pos, end_pos, function(entity)
		return entity ~= player
	end)
	if entity == nil then
		return false, "NO_ENTITY"
	end
	if not entity:isPlayer() then
		return false, "NOT_PLAYER", entity
	end
	local uuid = entity:getUUID()
	if not AnimationMirror:can_copy(uuid) then
		return false, "NOT_COPYABLE", entity
	end
	pings.AnimationMirror_player_picked(uuid)
	return true
end

return api