local Utils = require("./../core_utils")

local api = {}

function api.make(
	leg,
	is_right,
	foot_vec,
	knee_vec
)
	local leg_rest_mat = leg:getPositionMatrix()
	local leg_name
	if is_right then
		leg_name = "right_leg"
	else
		leg_name = "left_leg"
	end
	foot_vec = foot_vec or vec(0, -11, 0)
	knee_vec = knee_vec or vec(0, -4.5, -1)
	local output = {}
	function output.get_pose(root)
		local pose = {}
		local leg_mat = Utils.get_root_space_mat_raw(leg, root)
		pose.bend_target = leg_mat:apply(knee_vec)
		local foot_mat3 = leg_mat:deaugmented()
		local foot_pos = leg_mat:apply(foot_vec)
		pose.foot = foot_mat3:augmented():translate(foot_pos)
		return pose
	end
	function output.apply_pose(pose, root, start)
		--TODO
	end
	function output.reset_pose()
		upper:setMatrix(leg_rest_mat)
	end
	return output
end

return api