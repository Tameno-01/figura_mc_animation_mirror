local Utils = require("./../core_utils")

local api = {}

function api.make(
	torso,
	bottom_pivot,
	height,
	bend_target_vec
)
	local torso_rest_mat = torso:getPositionMatrix()
	height = height or 12
	local output = {}
	if bottom_pivot then
		bend_target_vec = bend_target_vec or vec(0, 6, 1)
		function output.get_pose(root)
			local pose = {}
			local torso_mat = Utils.get_root_space_mat_raw(torso, root)
			pose.hips = torso_mat
			local top_pos = torso_mat:apply(vec(0, height, 0))
			local top_mat = torso_mat:deaugmented():augmented():translate(top_pos)
			pose.top = top_mat
			pose.bend_target = torso_mat:apply(bend_target_vec)
			return pose
		end
		function output.get_neck_pivot()
			return torso:getPivot() + vec(0, height, 0)
		end
	else
		bend_target_vec = bend_target_vec or vec(0, -6, 1)
		function output.get_pose(root)
			local pose = {}
			local torso_mat = Utils.get_root_space_mat_raw(torso, root)
			pose.top = torso_mat
			local hips_pos = torso_mat:apply(vec(0, -height, 0))
			local hips_mat = torso_mat:deaugmented():augmented():translate(hips_pos)
			pose.hips = hips_mat
			pose.bend_target = torso_mat:apply(bend_target_vec)
			return pose
		end
		function output.get_neck_pivot()
			return torso:getPivot()
		end
	end
	function output.apply_pose(pose, root)
		--TODO
	end
	function output.reset_pose()
		upper:setMatrix(torso_rest_mat)
	end
	return output
end

return api