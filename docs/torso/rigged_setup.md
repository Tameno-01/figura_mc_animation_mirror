# Rigged torso setup

First, require the rigged torso maker like so:

```lua
local TorsoMaker = require("animation_mirror/body_maker/torso/rigged")
```

Then, make the torso like so:

```lua
local animation_mirror_torso = TorsoMaker.make(
	{hips, spine1, spine2 ...}, -- Make this table as big as you need to.
	top
)
```

Replace `hips`, `spine1`, `spine2`, etc. with all the joints of your torso (for example, `model.models.root.Hips`). They should be ordered from parent to child.

Replace `top` with your head `ModelPart`, or if it's not present, your neck. Alternatively, you can use an empty group places at the very top of your torso. 