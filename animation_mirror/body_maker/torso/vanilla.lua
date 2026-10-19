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
	local torso_to_middle_vec
	local output = {}
	if bottom_pivot then
		bend_target_vec = bend_target_vec or vec(0, height / 2, 1)
		torso_to_middle_vec = vec(0, -height / 2, 0)
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
		function output.get_top_pivot()
			return torso:getPivot() + vec(0, height, 0)
		end
		function output.get_hips_pivot()
			return torso:getPivot()
		end
	else
		bend_target_vec = bend_target_vec or vec(0, -height / 2, 1)
		torso_to_middle_vec = vec(0, height / 2, 0)
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
		function output.get_top_pivot()
			return torso:getPivot()
		end
		function output.get_hips_pivot()
			return torso:getPivot() + vec(0, -height, 0)
		end
	end
	function output.apply_pose(pose, root)
		local middle = (pose.hips:getColumn(4).xyz + pose.torso_top:getColumn(4).xyz) / 2
		local y = (pose.torso_top:getColumn(4).xyz - pose.hips:getColumn(4).xyz):normalized()
		local z = (pose.hips:getColumn(3).xyz + pose.torso_top:getColumn(3).xyz) / 2
		local x = Utils.perpendicular(y, z)
		z = Utils.perpendicular(x, y)
		local torso_mat3 = matrices.mat3(x, y, z)
		local global_torso_mat = torso_mat3:augmented():translate(middle + torso_mat3 * torso_to_middle_vec)
		local parent = Utils.get_root_space_mat_raw_without_pivot_correction(torso:getParent(), root)
		local torso_mat = matrices.mat4()
		torso_mat:translate(-torso:getPivot())
		torso_mat = global_torso_mat * torso_mat
		torso_mat = parent:inverted() * torso_mat
		torso:setMatrix(torso_mat)
	end
	function output.reset_pose()
		torso:setMatrix(torso_rest_mat)
	end
	output.should_detach = true
	return output
end

return api