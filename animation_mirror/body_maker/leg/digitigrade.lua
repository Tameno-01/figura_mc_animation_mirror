local Utils = require("./../core_utils")

local api = {}

function api.make(
	upper,
	lower_1,
	lower_2,
	foot,
	is_right
)
	local upper_rest_mat = upper:getPositionMatrix()
	local lower_1_rest_mat = lower_1:getPositionMatrix()
	local lower_2_rest_mat = lower_2:getPositionMatrix()
	local foot_rest_mat = foot:getPositionMatrix()
	local upper_forward = Utils.perpendicular(vec(1, 0, 0), lower_1:getPivot() - upper:getPivot())
	local lower_1_forward = Utils.perpendicular(vec(1, 0, 0), lower_2:getPivot() - lower_1:getPivot())
	local lower_2_forward = Utils.perpendicular(vec(1, 0, 0), foot:getPivot() - lower_2:getPivot())
	local ik_params = Utils.precompute_ik_params(
		{
			{
				part = upper,
				leaf_twist = 0.25,
				leaf_twist_vect = upper_forward,
				bend_twist = 0.5,
				bend_twist_vect = upper_forward,
			},
			{
				part = lower_1,
				angle_multiplier = 1,
				leaf_twist = 0.5,
				leaf_twist_vect = lower_1_forward,
				bend_twist = 0.3,
				bend_twist_vect = lower_1_forward,
			},
			{
				part = lower_2,
				angle_multiplier = -1,
				leaf_twist = 0.75,
				leaf_twist_vect = lower_2_forward,
				bend_twist = 0.3,
				bend_twist_vect = lower_2_forward,
			},
		},
		{
			leaf = foot:getPivot(),
			leaf_twist_vect = vec(0, 0, -1),
			leaf_forward_vect = vec(0, -1, 0),
			angle_multiplier = 180
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
		pose.bend_target = Utils.get_root_space_mat_raw(lower_1, root):getColumn(4).xyz
		pose.foot = Utils.get_root_space_mat_raw(foot, root)
		return pose
	end
	function output.apply_pose(pose, root)
		Utils.do_ik(ik_params, pose[foot_name], pose[bend_target_name], root)
		local hand_parent_mat = Utils.get_root_space_mat_raw(foot:getParent(), root)
		Utils.set_part_mat(foot, (hand_parent_mat:deaugmented():inverted() * pose[foot_name]:deaugmented()):augmented())
	end
	function output.reset_pose()
		upper:setMatrix(upper_rest_mat)
		lower_1:setMatrix(lower_1_rest_mat)
		lower_2:setMatrix(lower_2_rest_mat)
		foot:setMatrix(foot_rest_mat)
	end
	return output
end

return api