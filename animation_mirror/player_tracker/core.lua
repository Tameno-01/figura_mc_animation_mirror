local AnimationMirror = require("../core")

local api = {}

if host:isHost() then
	
	local trackers = {}

	local next_player = nil

	local players = world.avatarVars()
	
	function api.new(create_func, delete_func, render_func, tick_func)
		table.insert(trackers, {
			create_func = create_func,
			delete_func = delete_func,
			render_func = render_func,
			tick_func = tick_func,
			active_data = {},
		})
	end

	function events.world_render(delta)
		next_player = next(players, next_player)
		if next_player == nil then
			players = world.avatarVars()
			next_player = next(players, next_player)
		end
		local can_copy = (
			world.getEntity(next_player) ~= nil
			and next_player ~= avatar:getUUID()
			and AnimationMirror.can_copy(next_player)
			and AnimationMirror.get_source_player_uuid() ~= AnimationMirror.get_others_source_uuid(next_player)
		)
		for _, tracker in ipairs(trackers) do
			local data = tracker.active_data[next_player]
			local is_active = data ~= nil
			if can_copy ~= is_active then
				if can_copy then
					if tracker.create_func ~= nil then
						tracker.active_data[next_player] = tracker.create_func(next_player)
					else
						tracker.active_data[next_player] = false
					end
				else
					if tracker.delete_func ~= nil then
						tracker.delete_func(tracker.active_data[next_player])
					end
					tracker.active_data[next_player] = nil
				end
			end
		end
		for _, tracker in ipairs(trackers) do
			for _, data in pairs(tracker.active_data) do
				if tracker.render_func ~= nil then
					tracker.render_func(data, delta)
				end
			end
		end
	end
	
	function events.world_tick()
		for _, tracker in ipairs(trackers) do
			for _, data in pairs(tracker.active_data) do
				if tracker.tick_func ~= nil then
					tracker.tick_func(data)
				end
			end
		end
	end

else -- Not host

	function api.new() end

end

return api