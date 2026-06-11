local Utils = require("./core_utils")

local api = {}

local current_state = "OFF"
local source_player_uuid = nil
local state_change_functions = {}
local source_change_functions = {}
local body = nil

-- this function will be given a body later in this script
local stop_copying

local function change_state(to)
	local from = current_state
	current_state = to
	for func, _ in pairs(state_change_functions) do
		func(from, to)
	end
end

local function source_render()
	local pose = body.get_pose()
	local avar = {}
	Utils.add_mat3_to_avar("head", pose, avar)
	Utils.add_mat4_to_avar("torso_top", pose, avar)
	Utils.add_mat4_to_avar("hips", pose, avar)
	Utils.add_mat4_to_avar("left_hand", pose, avar)
	Utils.add_mat4_to_avar("right_hand", pose, avar)
	Utils.add_mat4_to_avar("left_foot", pose, avar)
	Utils.add_mat4_to_avar("right_foot", pose, avar)
	Utils.add_vec_to_avar("torso_ik_target", pose, avar)
	Utils.add_vec_to_avar("left_arm_ik_target", pose, avar)
	Utils.add_vec_to_avar("right_arm_ik_target", pose, avar)
	Utils.add_vec_to_avar("left_leg_ik_target", pose, avar)
	Utils.add_vec_to_avar("right_leg_ik_target", pose, avar)
	avatar:store("AnimationMirror_pose", avar)
end

local function copying_render()
	local avars = world.avatarVars()[source_player_uuid]
	if avars == nil then
		stop_copying()
		change_state("OFF")
		return
	end
	local avar = avars.AnimationMirror_pose
	if avar == nil or type(avar) ~= "table" then
		stop_copying()
		change_state("OFF")
		return
	end
	local pose = {}
	Utils.add_mat3_from_avar("head", avar, pose)
	Utils.add_mat4_from_avar("torso_top", avar, pose)
	Utils.add_mat4_from_avar("hips", avar, pose)
	Utils.add_mat4_from_avar("left_hand", avar, pose)
	Utils.add_mat4_from_avar("right_hand", avar, pose)
	Utils.add_mat4_from_avar("left_foot", avar, pose)
	Utils.add_mat4_from_avar("right_foot", avar, pose)
	Utils.add_vec_from_avar("torso_ik_target", avar, pose)
	Utils.add_vec_from_avar("left_arm_ik_target", avar, pose)
	Utils.add_vec_from_avar("right_arm_ik_target", avar, pose)
	Utils.add_vec_from_avar("left_leg_ik_target", avar, pose)
	Utils.add_vec_from_avar("right_leg_ik_target", avar, pose)
	body.apply_pose(pose)
end

local function begin_being_source()
	body.root.postRender = source_render
end

local function stop_being_source()
	body.root.postRender = nil
	avatar:store("AnimationMirror_pose", nil)
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

-- "local" is missing because we declared "stop_copying" earlier
function stop_copying()
	events.RENDER:remove(copying_render)
	avatar:store("AnimationMirror_source", nil)
end

function api.begin_being_source()
	if body == nil then
		error("AnimationMirror: No body was provided")
	end
	if current_state == "SOURCE" then
		return
	elseif current_state == "COPYING" then
		stop_copying()
	end
	begin_being_source()
	change_state("SOURCE")
end

function api:can_copy(player_uuid)
	local player_vars = world.avatarVars()[player_uuid]
	if player_vars.AnimationMirror_pose ~= nil then
		return true
	elseif player_vars.AnimationMirror_source ~= nil then
		return true
	end
	return false
end

function api.begin_copying(player_uuid)
	if body == nil then
		error("AnimationMirror: No body was provided")
	end
	if not api.can_copy(player_uuid) then
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

function api.get_current_state()
	return current_state
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