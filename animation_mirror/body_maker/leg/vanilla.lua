local Utils = require("./../core_utils")

local api = {}

function api.make(
	leg,
	is_right,
	height,
	knee_vec
)
	height = height or 11
	local leg_rest_mat = leg:getPositionMatrix()
	local bend_target_name
	local foot_name
	if is_right then
		bend_target_name = "right_leg_bend_target"
		foot_name = "right_foot"
	else
		bend_target_name = "left_leg_bend_target"
		foot_name = "left_foot"
	end
	local foot_vec = vec(0, -height, 0)
	knee_vec = knee_vec or vec(0, -height / 2, -1)
	local output = {}
	function output.get_offset(hips)
		return leg:getPivot() - hips
	end
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
		Utils.do_vanilla_ik(
			leg,
			height,
			start:getColumn(4).xyz,
			pose[foot_name],
			pose[bend_target_name],
			vec(0, -1, 0),
			root
		)
	end
	function output.reset_pose()
		leg:setMatrix(leg_rest_mat)
	end
	return output
end

return api