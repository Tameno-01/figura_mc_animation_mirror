local Utils = require("./../core_utils")

local api = {}

function api.make(
	upper,
	lower,
	foot,
	is_right,
	is_foot_real
)
	if is_foot_real == nil then
		is_foot_real = true
	end
	local upper_rest_mat = upper:getPositionMatrix()
	local lower_rest_mat = lower:getPositionMatrix()
	local foot_rest_mat = foot:getPositionMatrix()
	local upper_forward = Utils.perpendicular(vec(1, 0, 0), lower:getPivot() - upper:getPivot())
	local lower_forward = Utils.perpendicular(vec(1, 0, 0), foot:getPivot() - lower:getPivot())
	local lower_section
	if is_foot_real then
		lower_section = {
			part = lower,
			angle_multiplier = 1,
			leaf_twist = 0.66,
			leaf_twist_vect = lower_forward,
			bend_twist = 0.3,
			bend_twist_vect = lower_forward,
		}
	else
		lower_section = {
			part = lower,
			angle_multiplier = 1,
			leaf_twist = 1,
			leaf_twist_vect = lower_forward,
		}
	end
	local ik_params = Utils.precompute_ik_params(
		{
			{
				part = upper,
				leaf_twist = 0.25,
				leaf_twist_vect = upper_forward,
				bend_twist = 0.5,
				bend_twist_vect = upper_forward,
			},
			lower_section,
		},
		{
			leaf = foot:getPivot(),
			leaf_twist_vect = vec(0, 0, -1),
			leaf_forward_vect = vec(0, -1, 0),
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
	function output.get_offset(hips)
		return upper:getPivot() - hips
	end
	function output.get_pose(root)
		local pose = {}
		pose.bend_target = Utils.get_root_space_mat_raw(lower, root):apply(0, 0, -0.5)
		pose.foot = Utils.get_root_space_mat_raw(foot, root)
		return pose
	end
	function output.apply_pose(pose, root, start)
		if start ~= nil then
			local parent_mat = Utils.get_root_space_mat_raw(upper:getParent(), root)
			local mat = parent_mat:inverted() * start:copy():translate(-upper:getPivot())
			Utils.set_part_mat(upper, mat)
		end
		Utils.do_ik(ik_params, pose[foot_name], pose[bend_target_name], root, start ~= nil)
		if is_foot_real then
			local foot_parent_mat = Utils.get_root_space_mat_raw(foot:getParent(), root)
			Utils.set_part_mat(foot, (foot_parent_mat:deaugmented():inverted() * pose[foot_name]:deaugmented()):augmented())
		end
	end
	function output.reset_pose()
		upper:setMatrix(upper_rest_mat)
		lower:setMatrix(lower_rest_mat)
		if is_foot_real then
			foot:setMatrix(foot_rest_mat)
		end
	end
	output.should_detach = false
	return output
end

return api