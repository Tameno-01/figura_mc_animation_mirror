local Utils = require("./../core_utils")

local api = {}

function api.make(
	spine,
	neck
)
	local spine_count = #spine
	local spine_center_idx = math.ceil(#spine / 2) + 1
	local start_part = spine[1]
	local center_part = spine[spine_center_idx]
	local end_part = spine[spine_count]
	local rest_poses = {}
	for i, v in ipairs(spine) do
		rest_poses[i] = v:getPositionMatrix()
	end
	local sections = {}
	for i, part in ipairs(spine) do
		local leaf_twist = (i - 1) / (spine_count - 1)
		sections[i] = {
			part = part,
			angle_multiplier = 1,
			leaf_twist = leaf_twist,
			leaf_twist_vect = vec(1, 0, 0),
		}
	end
	local ik_params = Utils.precompute_ik_params(sections, {
		leaf = neck:getPivot(),
		keep_pos = true,
	})
	local output = {}
	function output.get_pose(root)
		local pose = {}
		pose.hips = Utils.get_root_space_mat_raw(start_part, root)
		pose.bend_target = Utils.get_root_space_mat_raw(center_part, root):getColumn(4).xyz
		local top_pos = Utils.get_root_space_mat_raw(neck, root)
		local top_basis = Utils.get_root_space_mat_raw(end_part, root)
		pose.top = matrices.mat4(
			top_basis:getColumn(1),
			top_basis:getColumn(2),
			top_basis:getColumn(3),
			top_pos:getColumn(4)
		)
		return pose
	end
	function output.apply_pose(pose, root, offsets)
		local parent_mat = Utils.get_root_space_mat_raw(spine[1]:getParent(), root)
		Utils.set_part_mat(spine[1], parent_mat:inverted() * (pose.hips:copy():translate(-spine[1]:getPivot())))
		Utils.do_ik(ik_params, pose.torso_top:getColumn(4).xyz, pose.torso_bend_target, pose.torso_top:getColumn(1).xyz, root)
		local starts = {}
		starts.head = matrices.mat4()
		starts.left_arm = matrices.mat4()
		starts.right_arm = matrices.mat4()
		starts.left_leg = matrices.mat4()
		starts.right_leg = matrices.mat4()
		return starts
	end
	function output.reset_pose()
		for i, v in ipairs(spine) do
			v:setMatrix(rest_poses[i])
		end
	end
	function output.get_neck_pivot()
		return neck:getPivot()
	end
	return output
end

return api