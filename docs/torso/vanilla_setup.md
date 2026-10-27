# Vanilla torso setup

First, require the vanilla torso maker:

```lua
local TorsoMaker = require("animation_mirror/body_maker/torso/vanilla")
```

Then, make the torso like so:

```lua
local animation_mirror_torso = TorsoMaker.make(
	torso,
	bottom_pivot -- bool, mandatory
)
```

Replace `torso` with the `ModelPart` it corresponds to (for example, `models.model.root.Body`).

Replace `bottom_pivot` with `true` if the pivot of your torso is at its bottom or `false` if it isn't.
