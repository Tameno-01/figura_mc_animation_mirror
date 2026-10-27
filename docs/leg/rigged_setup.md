# Rigged leg setup

First, require the rigged leg maker:

```lua
local LegMaker = require("animation_mirror/body_maker/leg/rigged")
```

Then, make the legs like so:

```lua
local animation_mirror_left_leg = LegMaker.make(
	left_upper_leg, -- upper
	left_lower_leg, -- lower
	left_foot, -- foot
	false, -- is_right
	nil -- is foot real (bool, defaults to true)
)

local animation_mirror_right_leg = LegMaker.make(
	right_upper_leg, -- upper
	right_lower_leg, -- lower
	right_foot, -- foot
	true, -- is_right
	nil -- is foot real (bool, defaults to true)
)
```

Replace `left_upper_leg`, `left_lower_leg` and `left_foot` by the `ModelPart`s they correspond to (for example, `model.model.root.(...).LeftUpperLeg`).

If you don't have a left foot, set `left_foot` to the empty group you made in step 0 and set `is foot real` to `false`.

You must do all this for the right leg as well.
