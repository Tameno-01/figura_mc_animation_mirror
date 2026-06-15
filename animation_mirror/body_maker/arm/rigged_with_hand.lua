local Utils = require("./../core_utils")

local api = {}

function api.make(
	upper,
	lower,
	hand,
	is_right
)
	local upper_rest_mat = upper:getPositionMatrix()
	local lower_rest_mat = lower:getPositionMatrix()
	local hand_rest_mat = hand:getPositionMatrix()
	local hand_pose_mat_x = lower:getPivot() - upper:getPivot()
	local hand_name
	local bend_target_name
	local ik_start_dir
	if is_right then
		hand_name = "right_hand"
		bend_target_name = "right_arm_bend_target"
		ik_start_dir = vec(1, 0, 0)
	else
		hand_name = "left_hand"
		bend_target_name = "left_arm_bend_target"
		ik_start_dir = vec(-1, 0, 0)
		hand_pose_mat_x = -hand_pose_mat_x
	end
	local hand_pose_mat_z = vec(0, 0, 1)
	local hand_pose_mat_y = hand_pose_mat_z:crossed(hand_pose_mat_x)
	hand_pose_mat_z = hand_pose_mat_x:crossed(hand_pose_mat_y)
	local hand_pose_mat = matrices.mat3(
		hand_pose_mat_x:normalized(),
		hand_pose_mat_y:normalized(),
		hand_pose_mat_z:normalized()
	)
	local inv_hand_pose_mat = hand_pose_mat:inverted()
	local ik_params = Utils.precompute_ik_params(
		{
			{
				part = upper,
				leaf_twist = 0.25,
				leaf_twist_vect = vec(0, 0, 1),
				bend_twist = 0.5,
				bend_twist_vect = vec(0, 0, 1),
			},
			{
				part = lower,
				angle_multiplier = 1,
				leaf_twist = 1,
				leaf_twist_vect = vec(0, 0, 1),
			},
		},
		{
			leaf = hand:getPivot(),
			start_dir = ik_start_dir
		}
	)
	local output = {}
	function output.get_pose(root)
		local pose = {}
		pose.bend_target = Utils.get_root_space_mat_raw(lower, root):getColumn(4).xyz
		local global_hand_mat = Utils.get_root_space_mat_raw(hand, root)
		local global_hand_rot = global_hand_mat:deaugmented()
		global_hand_rot = global_hand_rot * hand_pose_mat
		global_hand_mat = matrices.mat4(
			global_hand_rot:getColumn(1):augmented(0),
			global_hand_rot:getColumn(2):augmented(0),
			global_hand_rot:getColumn(3):augmented(0),
			global_hand_mat:getColumn(4)
		)
		pose.hand = global_hand_mat
		return pose
	end
	function output.apply_pose(pose, root, start)
		Utils.do_ik(ik_params, pose[hand_name]:getColumn(4).xyz, pose[bend_target_name], pose[hand_name]:getColumn(3).xyz, root)
		local hand_parent_mat = Utils.get_root_space_mat_raw(hand:getParent(), root):deaugmented()
		Utils.set_part_mat(hand, (hand_parent_mat:inverted() * (pose[hand_name]:deaugmented() * inv_hand_pose_mat)):augmented())
	end
	function output.reset_pose()
		upper:setMatrix(upper_rest_mat)
		lower:setMatrix(lower_rest_mat)
		hand:setMatrix(hand_rest_mat)
	end
	return output
end

return api