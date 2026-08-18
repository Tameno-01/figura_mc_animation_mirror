local Utils = require("./../core_utils")

local api = {}

function api.make(
	neck,
	head
)
	local neck_rest_mat = neck:getPositionMatrix()
	local head_rest_mat = head:getPositionMatrix()
	local output = {}
	function output.get_pose(root)
		local pose = {}
		pose.head = Utils.get_root_space_mat_raw(head, root):deaugmented()
		return pose
	end
	function output.apply_pose(pose, root)
		local parent_mat = Utils.get_root_space_mat_raw(neck:getParent(), root):deaugmented()
		Utils.set_part_mat(neck, (parent_mat:inverted() * pose.head):augmented())
	end
	function output.reset_pose()
		neck:setMatrix(neck_rest_mat)
		head:setMatrix(head_rest_mat)
	end
	return output
end

return api