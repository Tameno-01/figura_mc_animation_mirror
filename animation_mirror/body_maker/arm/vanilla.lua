local Utils = require("./../core_utils")

local api = {}

function api.make(
	arm,
	is_right,
	hand_vec,
	elbow_vec
)
	local arm_rest_mat = arm:getPositionMatrix()
	local arm_name
	local outward_x
	local hand_rotation_matrix
	if is_right then
		arm_name = "right_arm"
		outward_x = 1
		hand_rotation_matrix = matrices.mat3(
			vec(0, 1, 0),
			vec(-1, 0, 0),
			vec(0, 0, 1)
		)
	else
		arm_name = "left_arm"
		outward_x = -1
		hand_rotation_matrix = matrices.mat3(
			vec(0, -1, 0),
			vec(1, 0, 0),
			vec(0, 0, 1)
		)
	end
	local inv_hand_rotation_matrix = hand_rotation_matrix:inverted()
	hand_vec = hand_vec or vec(0, -9, 0)
	elbow_vec = elbow_vec or vec(outward_x, -4.5, 1)
	local output = {}
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
		--TODO
	end
	function output.reset_pose()
		upper:setMatrix(arm_rest_mat)
	end
	return output
end

return api