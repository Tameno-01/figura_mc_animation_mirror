local Utils = require("./../core_utils")

local api = {}

function api.make(
	arm,
	is_right,
	height,
	elbow_vec
)
	height = height or 9
	local arm_rest_mat = arm:getPositionMatrix()
	local bend_target_name
	local hand_name
	local outward_x
	local hand_rotation_matrix
	if is_right then
		bend_target_name = "right_arm_bend_target"
		hand_name = "right_hand"
		outward_x = 1
		hand_rotation_matrix = matrices.mat3(
			vec(0, 1, 0),
			vec(-1, 0, 0),
			vec(0, 0, 1)
		)
	else
		bend_target_name = "left_arm_bend_target"
		hand_name = "left_hand"
		outward_x = -1
		hand_rotation_matrix = matrices.mat3(
			vec(0, -1, 0),
			vec(1, 0, 0),
			vec(0, 0, 1)
		)
	end
	local inv_hand_rotation_matrix = hand_rotation_matrix:inverted()
	local hand_vec = vec(0, -height, 0)
	elbow_vec = elbow_vec or vec(outward_x, -height / 2, 1)
	local output = {}
	function output.get_offset(torso_top)
		return arm:getPivot() - torso_top
	end
	function output.get_pose(root)
		local pose = {}
		local arm_mat = Utils.get_root_space_mat_raw(arm, root)
		pose.bend_target = arm_mat:apply(elbow_vec)
		local hand_mat3 = arm_mat:deaugmented()
		hand_mat3 = hand_mat3 * inv_hand_rotation_matrix
		local hand_pos = arm_mat:apply(hand_vec)
		pose.hand = hand_mat3:augmented():translate(hand_pos)
		return pose
	end
	function output.apply_pose(pose, root, start)
		Utils.do_vanilla_ik(
			arm,
			height,
			start:getColumn(4).xyz,
			pose[hand_name],
			pose[bend_target_name],
			vec(outward_x, 0, 0),
			root
		)
	end
	function output.reset_pose()
		arm:setMatrix(arm_rest_mat)
	end
	output.should_detach = true
	return output
end

return api