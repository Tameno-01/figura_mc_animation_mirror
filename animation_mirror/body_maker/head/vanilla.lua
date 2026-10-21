local Utils = require("./../core_utils")

local api = {}

function api.make(
	head
)
	local head_rest_mat = head:getPositionMatrix()
	local output = {}
	function output.get_offset(torso_top)
		return head:getPivot() - torso_top
	end
	function output.get_pose(root)
		local pose = {}
		pose.head = Utils.get_root_space_mat_raw(head, root):deaugmented()
		return pose
	end
	function output.apply_pose(pose, root, start)
		local global_head_mat = pose.head:augmented():translate(start:getColumn(4).xyz)
		local parent = Utils.get_root_space_mat_raw_without_pivot_correction(head:getParent(), root)
		local head_mat = matrices.mat4()
		head_mat:translate(-head:getPivot())
		head_mat = global_head_mat * head_mat
		head_mat = parent:inverted() * head_mat
		head:setMatrix(head_mat)
	end
	function output.reset_pose()
		head:setMatrix(head_rest_mat)
	end
	output.should_detach = true
	return output
end

return api