# Vanilla leg setup

First, require the vanilla leg maker:

```lua
local LegMaker = require("animation_mirror/body_maker/leg/vanilla")
```

Then, make the legs like so:

```lua
local animation_mirror_left_leg = LegMaker.make(
	left_leg,
	false, -- is right
	nil -- height (number, defaults to 11)
)

local animation_mirror_right_leg = LegMaker.make(
	right_leg,
	true, -- is right
	nil -- height (number, defaults to 11)
)
```

Replaced `left_leg` and `right_leg` by the `ModelPart`s that correspond to your arms (for example, `models.model.root.LeftLeg`).

`height` should be the distance you took note of in step 0.
