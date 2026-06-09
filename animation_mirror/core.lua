pcall(require, "./debug_overrides")

log("If you see this log, lmk")

local api = {}

local current_state = "OFF"
local source_player_uuid = nil
local state_change_functions = {}
local source_change_functions = {}
local body

local function source_render()
	
end

local function copying_render()

end

local function change_state(to)
	local from = current_state
	current_state = to
	for func, _ in pairs(state_change_functions) do
		func(from, to)
	end
end

local function begin_being_source()
	events.RENDER:register(source_render)
end

local function stop_being_source()
	events.RENDER:remove(source_render)
	avatar:store("AnimationMirror_pose", nil)
end

local function can_copy(player_uuid)
	local player_vars = world.avatarVars()[player_uuid]
	if player_vars.AnimationMirror_pose ~= nil then
		return true
	elseif player_vars.AnimationMirror_source ~= nil then
		return true
	end
	return false
end

local function begin_copying(player_uuid)
	local prev_source_player_uuid = source_player_uuid
	local player_vars = world.avatarVars()[player_uuid]
	if player_vars.AnimationMirror_pose == nil then
		source_player_uuid = player_vars.AnimationMirror_source
	else
		source_player_uuid = player_uuid
	end
	if prev_source_player_uuid == source_player_uuid then
		return
	end
	if prev_source_player_uuid == nil then
		events.RENDER:register(copying_render)
	end
	avatar:store("AnimationMirror_source", player_uuid)
	if prev_source_player_uuid ~= nil then
		for func, _ in pairs(source_change_functions) do
			func(prev_source_player_uuid, source_player_uuid)
		end
	end
end

local function stop_copying()
	events.RENDER:remove(copying_render)
	avatar:store("AnimationMirror_source", nil)
end

function api.begin_being_source()
	if current_state == "SOURCE" then
		return
	elseif current_state == "COPYING" then
		stop_copying()
	end
	begin_being_source()
	change_state("SOURCE")
end

function api.begin_copying(player_uuid)
	if not can_copy(player_uuid) then
		return false
	elseif current_state == "SOURCE" then
		stop_being_source()
	end
	begin_copying(player_uuid)
	change_state("COPYING")
	return true
end

function api.stop()
	if current_state == "OFF" then
		return
	end
	if current_state == "SOURCE" then
		stop_being_source()
	elseif current_state == "COPYING" then
		stop_copying()
	end
	change_state("OFF")
end

function api.get_source_player_uuid()
	return source_player_uuid
end

function api.register_state_change_func(func)
	state_change_functions[func] = true
end

function api.remove_state_change_func(func)
	state_change_functions[func] = nil
end

function api.register_source_change_func(func)
	source_change_functions[func] = true
end

function api.remove_source_change_func(func)
	source_change_functions[func] = nil
end

local meta = {}

function meta.__newindex(_, k, v)
	if k == "state_change" then
		api.register_state_change_func(v)
	elseif k == "source_change" then
		api.register_source_change_func(v)
	end
end

setmetatable(api, meta)

return api