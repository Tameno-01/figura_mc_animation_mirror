# Player Tracker

If you want to implement your own indicators for who's mirrorable, you first need to require the PlayerTracker:

```lua
local PlayerTracker = require("animation_mirror/player_tracker/core")
```

Then, you can use the `new()` function to make your own indicators:

```lua
PlayerTracker.new(
	create_func,
	delete_func,
	render_func,
	tick_func
)
```

To understand what all this functions do, we must first understand what PlayerTracker considers an "active" player.

An active player is any player who:

- Is mirrorable
- Is loaded
- Is not you
- Is not mirroring the person you're mirroring

PlayerTracker will call `create_func` when a player becomes active, passing their UUID as the first and only parameter, this function can return anything but `nil`, tho it is recommended to make it return a table.

While a player is active, PlayerTracker will call `rended_func` every frame (if present) and `tick_func` ever tick (if present), passing in whatever `create_func` returned as the first parameter, and in the case of `rended_func`, delta (see base Figura's render events to know what delta means) will be passed as the second parameter.

When a player stops being active, and `delete_func` is present, PlayerTracker tracker will call `delete_func` with whatever `create_func` returned for that player as the first parameter.

**IMPORTANT:** Calling `PlayerTracker.new()` only works on the host, otherwise, it does nothing.

For a practical example, see the `animation_mirror/player_tracker/mirror_me_text.lua` file. This is the built-in implementation that shows the "Mirror me" text next to anyone who's mirrorable.

