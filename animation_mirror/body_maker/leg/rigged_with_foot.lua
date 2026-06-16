local Utils = require("./../core_utils")

local api = {}

function api.make(
	upper,
	lower,
	foot,
	is_right
)
	local upper_rest_mat = upper:getPositionMatrix()
	local lower_rest_mat = lower:getPositionMatrix()
	local foot_rest_mat = foot:getPositionMatrix()
	local ik_params = Utils.precompute_ik_params(
		{
			{
				part = upper,
				leaf_twist = 0.25,
				leaf_twist_vect = vec(1, 0, 0),
				bend_twist = 0.5,
				bend_twist_vect = vec(0, 0, -1),
			},
			{
				part = lower,
				angle_multiplier = 1,
				leaf_twist = 0.75,
				leaf_twist_vect = vec(1, 0, 0),
				bend_twist = 0.5,
				bend_twist_vect = vec(0, 0, -1),
			},
		},
		{
			leaf = foot:getPivot(),
		}
	)
	local foot_name
	local bend_target_name
	if is_right then
		foot_name = "right_foot"
		bend_target_name = "right_leg_bend_target"
	else
		foot_name = "left_foot"
		bend_target_name = "left_leg_bend_target"
	end
	local output = {}
	function output.get_pose(root)
		local pose = {}
		pose.bend_target = Utils.get_root_space_mat_raw(lower, root):getColumn(4).xyz
		pose.foot = Utils.get_root_space_mat_raw(foot, root)
		return pose
	end
	function output.apply_pose(pose, root, start)
		Utils.do_ik(ik_params, pose[foot_name]:getColumn(4).xyz, pose[bend_target_name], pose[foot_name]:getColumn(1).xyz, root)
		local hand_parent_mat = Utils.get_root_space_mat_raw(foot:getParent(), root)
		Utils.set_part_mat(foot, (hand_parent_mat:deaugmented():inverted() * pose[foot_name]:deaugmented()):augmented())
	end
	function output.reset_pose()
		upper:setMatrix(upper_rest_mat)
		lower:setMatrix(lower_rest_mat)
		foot:setMatrix(foot_rest_mat)
	end
	return output
end

return api