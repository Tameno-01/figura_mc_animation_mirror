# Vanilla arm setup

First, require the vanilla arm maker:

```lua
local ArmMaker = require("animation_mirror/body_maker/arm/vanilla")
```

Then, make the arms like so:

```lua
local animation_mirror_left_arm = ArmMaker.make(
	left_arm,
	false, -- is right
	nil -- height (number, defaults to 9)
)

local animation_mirror_right_arm = ArmMaker.make(
	right_arm,
	true, -- is right
	nil -- height (number, defaults to 9)
)
```

Replaced `left_arm` and `right_arm` by the `ModelPart`s that correspond to your arms (for example, `models.model.root.LeftArm`).

`height` should be the distance you took note of in step 0.
