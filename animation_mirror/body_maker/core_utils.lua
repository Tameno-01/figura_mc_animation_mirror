local Utils = require("./../core_utils")

local api = {}

local function test_ik_angle(vects, angles, axis, multiplier)
	local result = vects[1]
	local total_angle = 0
	for i, vect in ipairs(vects) do
		if i ~= 1 then
			local idx = i - 1
			local angle = angles[idx] * multiplier
			total_angle = total_angle + angle
			result = result + vectors.rotateAroundAxis(total_angle, vect:copy(), axis)
		end
	end
	return result:length()
end

local function compute_ik_angle_multiplier(vects, angles, axis, target_distance, max_distance)
	if target_distance > max_distance then
		return 0
	end
	local multiplier = 0
	local multiplier_test_diff = 0.5
	for _ = 1, 10 do
		local distance = test_ik_angle(vects, angles, axis, multiplier)
		if distance < target_distance then
			multiplier = multiplier - multiplier_test_diff
		else
			multiplier = multiplier + multiplier_test_diff
		end
		multiplier_test_diff = multiplier_test_diff / 2
	end
	return multiplier
end

function api.perpendicular(a, b)
	if Utils.is_zero_approx(a) or Utils.is_zero_approx(b) then
		return vec(1, 0, 0)
	end
	local output = a:crossed(b)
	if Utils.is_zero_approx(output) then
		if Utils.is_zero_approx(vec(0, a.y, a.z)) then
			return a:crossed(vec(0, 1, 0)):normalized()
		else
			return a:crossed(vec(1, 0, 0)):normalized()
		end
	else
		return output:normalized()
	end
end

function api.angle_between(a, b)
	if Utils.is_zero_approx(a) or Utils.is_zero_approx(b) then
		return 0
	end
	local dot = a:normalized():dot(b:normalized())
	local output = math.deg(math.acos(dot))
	if output ~= output then -- NaN check. Thanks, lua.
		return 0
	end
	return output
end

function api.flatten_vect(vect, plane_normal)
	local projection_offset = vect:dot(plane_normal)
	return vect - plane_normal * projection_offset
end

function api.mat3_rotated_around_axis(angle, mat, axis)
	return matrices.mat3(
		vectors.rotateAroundAxis(angle, mat:getColumn(1), axis),
		vectors.rotateAroundAxis(angle, mat:getColumn(2), axis),
		vectors.rotateAroundAxis(angle, mat:getColumn(3), axis)
	)
end

function api.mat3_augmented_with_pos(mat, pos)
	return matrices.mat4(
		mat:getColumn(1):augmented(0),
		mat:getColumn(2):augmented(0),
		mat:getColumn(3):augmented(0),
		pos:augmented(1)
	)
end

function api.set_part_mat(part, mat)
	local actual_mat = matrices.mat4()
	actual_mat:translate(-part:getPivot())
	actual_mat:multiply(mat:deaugmented():augmented())
	actual_mat:translate(part:getPivot())
	actual_mat:translate(mat:getColumn(4).xyz)
	part:setMatrix(actual_mat)
end

function api.get_root_space_mat_raw(part, root)
	if part == root then
		return matrices.mat4()
	end
	local part_mat = part:getPositionMatrixRaw()
	local part_mat3 = part_mat:deaugmented()
	local mat_pos = part_mat:getColumn(4).xyz
	local pivot = part:getPivot()
	local local_pivot = pivot - part:getParent():getPivot()
	local part_base_pos = pivot - part_mat3 * pivot
	local mat_offset = mat_pos - part_base_pos
	local final_pos = local_pivot + mat_offset
	local pivot_mat = api.mat3_augmented_with_pos(part_mat3, final_pos)
	return api.get_root_space_mat_raw(part:getParent(), root) * pivot_mat
end

function api.precompute_ik_params(sections, config)
	local params = {}
	params.section_count = #sections
	local total_angle_multiplier = 0
	for i, section in ipairs(sections) do
		if i ~= 1 then
			total_angle_multiplier = total_angle_multiplier + section.angle_multiplier
		end
	end
	local total_angle = 360 - 360 / params.section_count
	local angle_to_multiply = total_angle / total_angle_multiplier
	params.sections = {}
	params.vects = {}
	params.angles = {}
	for i, section in ipairs(sections) do
		local angle = nil
		if i ~= 1 then
			angle = section.angle_multiplier * angle_to_multiply
			params.angles[i - 1] = angle
		end
		if i == params.section_count then
			params.vects[i] = config.leaf - section.part:getPivot()
		else
			params.vects[i] = sections[i + 1].part:getPivot() - section.part:getPivot()
		end
		table.insert(params.sections, {
			part = section.part,
			leaf_twist = section.leaf_twist,
			leaf_twist_vect = section.leaf_twist_vect,
			bend_twist = section.bend_twist,
			bend_twist_vect = section.bend_twist_vect,
			angle = angle,
		})
	end
	params.last_to_leaf = params.vects[params.section_count]
	params.rest_dir = sections[params.section_count].part:getPivot() - sections[1].part:getPivot() + params.last_to_leaf
	params.max_dist = params.rest_dir:length()
	if config.keep_pos == true then
		params.keep_pos = true
	else
		params.keep_pos = false
	end
	if config.start_dir ~= nil then
		local axis = api.perpendicular(params.rest_dir, config.start_dir)
		local angle = api.angle_between(params.rest_dir, config.start_dir)
		params.pre_ik_mat = api.mat3_rotated_around_axis(angle, matrices.mat3(), axis)
		params.post_adjust_rest_dir = config.start_dir
	else
		params.pre_ik_mat = matrices.mat3()
		params.post_adjust_rest_dir = params.rest_dir
	end
	params.leaf_twist_vect = config.leaf_twist_vect
	params.leaf_forward_vect = config.leaf_forward_vect
	return params
end

function api.do_ik(params, target, bend_target, root)
	local first_part = params.sections[1].part
	local parent_mat = api.get_root_space_mat_raw(first_part:getParent(), root):deaugmented()
	local inv_parent_mat = parent_mat:inverted()
	local starting_mat = inv_parent_mat * params.pre_ik_mat
	local local_start_pos = vec(0, 0, 0)
	if params.keep_pos then
		local_start_pos = first_part:getPositionMatrixRaw():apply(first_part:getPivot()) - first_part:getPivot()
	end
	local start = api.get_root_space_mat_raw(first_part, root):getColumn(4).xyz
	local diff = target:getColumn(4).xyz - start
	local dir = diff:normalized()
	local first_axis = api.perpendicular(params.post_adjust_rest_dir, dir)
	local first_angle = api.angle_between(params.post_adjust_rest_dir, dir)
	local first_part_mat = api.mat3_rotated_around_axis(first_angle, starting_mat, inv_parent_mat * first_axis)
	api.set_part_mat(first_part, api.mat3_augmented_with_pos(first_part_mat, local_start_pos))
	local accumulated_mat = parent_mat * first_part_mat
	local bend_target_vect = bend_target - start
	local global_axis = api.perpendicular(bend_target_vect, diff)
	local deagumented_target = target:deaugmented()
	local leaf_twist_vect = deagumented_target * params.leaf_twist_vect
	local leaf_forward_vect = deagumented_target * params.leaf_forward_vect
	local leaf_bend_angle = api.angle_between(leaf_forward_vect, dir)
	local leaf_bend_axis = api.perpendicular(leaf_forward_vect, dir)
	local perpendicular_leaf_twist_vect = vectors.rotateAroundAxis(leaf_bend_angle, leaf_twist_vect:copy(), leaf_bend_axis)
	local flattened_bend_twist_vect = api.flatten_vect(bend_target_vect, dir)
	local vects = {}
	local twist_matrices = {}
	for i, section in ipairs(params.sections) do
		local twist_matrix = matrices.mat3()
		if section.leaf_twist ~= nil then
			local part_leaf_twist_vect = accumulated_mat * section.leaf_twist_vect
			local leaf_twist = api.angle_between(part_leaf_twist_vect, perpendicular_leaf_twist_vect)
			leaf_twist = leaf_twist * math.sign(dir:dot(api.perpendicular(part_leaf_twist_vect, perpendicular_leaf_twist_vect)))
			leaf_twist = leaf_twist * section.leaf_twist
			twist_matrix = api.mat3_rotated_around_axis(leaf_twist, twist_matrix, params.rest_dir)
		end
		if section.bend_twist ~= nil then
			local part_bend_twist_vect = accumulated_mat * twist_matrix * section.bend_twist_vect
			local bend_twist = api.angle_between(part_bend_twist_vect, flattened_bend_twist_vect)
			bend_twist = bend_twist * math.sign(dir:dot(api.perpendicular(part_bend_twist_vect, flattened_bend_twist_vect)))
			bend_twist = bend_twist * section.bend_twist
			twist_matrix = api.mat3_rotated_around_axis(bend_twist, twist_matrix, params.rest_dir)
		end
		twist_matrices[i] = twist_matrix
		accumulated_mat = accumulated_mat * twist_matrix
		vects[i] = accumulated_mat * params.vects[i]
	end
	local angle_multiplier = compute_ik_angle_multiplier(
		vects,
		params.angles,
		global_axis,
		diff:length(),
		params.max_dist
	)
	first_part_mat = first_part_mat * twist_matrices[1]
	api.set_part_mat(first_part, api.mat3_augmented_with_pos(first_part_mat, local_start_pos))
	accumulated_mat = parent_mat * first_part_mat
	for i, section in ipairs(params.sections) do
		if i ~= 1 then
			local angle = section.angle * angle_multiplier
			local part_mat = api.mat3_rotated_around_axis(angle, twist_matrices[i], accumulated_mat:inverted() * global_axis)
			api.set_part_mat(section.part, part_mat:augmented())
			accumulated_mat = accumulated_mat * part_mat
		end
	end
	local post_ik_point = api.get_root_space_mat_raw(params.sections[params.section_count].part, root):apply(params.last_to_leaf)
	local post_ik_diff = post_ik_point - start
	local post_ik_axis = api.perpendicular(post_ik_diff, diff)
	local post_ik_angle = api.angle_between(post_ik_diff, diff)
	first_part_mat = api.mat3_rotated_around_axis(post_ik_angle, first_part_mat, inv_parent_mat * post_ik_axis)
	api.set_part_mat(first_part, api.mat3_augmented_with_pos(first_part_mat, local_start_pos))
end

return api