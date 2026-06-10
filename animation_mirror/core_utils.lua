pcall(require, "./debug_overrides")

local api = {}

local function make_mat4_valid(mat)
	local x = mat:getColumn(1).xyz
	local y = mat:getColumn(2).xyz
	local z = mat:getColumn(3).xyz
	x = x:normalized()
	y = z:crossed(x):normalized()
	z = x:crossed(y):normalized()
	return matrices.mat4(
		x:augmented(0),
		y:augmented(0),
		z:augmented(0),
		mat:getColumn(4).xyz:augmented(1)
	)
end

function api.add_vec_to_avar(name, input, output)
	local vect = input[name]
	output[name] = {vect.x, vect.y, vect.z}
end

function api.add_mat4_to_avar(name, input, output)
	local mat = input[name]
	local x = mat:getColumn(1)
	local y = mat:getColumn(2)
	local z = mat:getColumn(3)
	local w = mat:getColumn(4)
	output[name] = {
		x.x, x.y, x.z,
		y.x, y.y, y.z,
		z.x, z.y, z.z,
		w.x, w.y, w.z,
	}
end

function api.add_vec_from_avar(name, input, output)
	local vec_table = input[name]
	if not type(vec_table) == "table" then
		output[name] = vec(0, 0, 0)
		return
	end
	if #vec_table ~= 3 then
		output[name] = vec(0, 0, 0)
		return
	end
	output[name] = vec(vec_table[1], vec_table[2], vec_table[3])
end

function api.add_mat4_from_avar(name, input, output)
	local mat_table = input[name]
	if not type(mat_table) == "table" then
		output[name] = matrices.mat4()
		return
	end
	if #mat_table ~= 12 then
		output[name] = matrices.mat4()
		return
	end
	local mat = matrices.mat4(
		vec(mat_table[1], mat_table[2], mat_table[3], 0),
		vec(mat_table[4], mat_table[5], mat_table[6], 0),
		vec(mat_table[7], mat_table[8], mat_table[9], 0),
		vec(mat_table[10], mat_table[11], mat_table[12], 1)
	)
	mat = make_mat4_valid(mat)
	output[name] = mat
end

return api