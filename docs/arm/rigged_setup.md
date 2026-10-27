# Rigged arm setup

First, require the rigged arm maker:

```lua
local ArmMaker = require("animation_mirror/body_maker/arm/rigged")
```

Then, make the arms like so:

```lua
local animation_mirror_left_arm = ArmMaker.make(
	left_upper_arm,
	left_lower_arm,
	left_hand,
	false, -- is right
	nil -- is hand real (bool, defaults to true)
)

local animation_mirror_right_arm = ArmMaker.make(
	right_upper_arm,
	right_lower_arm,
	right_hand,
	true, -- is right
	nil -- is hand real (bool, defaults to true)
)
```

Replace `left_upper_arm`, `left_lower_arm` and `left_hand` by the `ModelPart`s they correspond to (for example, `model.model.root.(...).LeftUpperArm`).

If you don't have a left hand, set `left_hand` to the empty group you made in step 0 and set `is hand real` to `false`.

You must do all this for the right arm as well.
