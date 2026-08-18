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
		local mat = pose.head:augmented()
		mat:translate(start:getColumn(4).xyz)
		mat:translate(-head:getPivot())
		mat = Utils.get_root_space_mat_raw(head:getParent(), root):inverted() * mat
		Utils.set_part_mat(head, mat)
	end
	function output.reset_pose()
		head:setMatrix(head_rest_mat)
	end
	return output
end

return api