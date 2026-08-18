local Utils = require("./../core_utils")

local api = {}

function api.make(
	head
)
	local head_rest_mat = head:getPositionMatrix()
	local output = {}
	function output.get_pose(root)
		local pose = {}
		pose.head = Utils.get_root_space_mat_raw(head, root):deaugmented()
		return pose
	end
	function output.apply_pose(pose, root)
		local parent_mat = Utils.get_root_space_mat_raw(head:getParent(), root):deaugmented()
		Utils.set_part_mat(head, (parent_mat:inverted() * pose.head):augmented())
	end
	function output.reset_pose()
		head:setMatrix(head_rest_mat)
	end
	return output
end

return api