# Rigged head setup

First, require the rigged head maker:

```lua
local HeadMaker = require("animation_mirror/body_maker/head/rigged")
```

Then, make the head like so:

```lua
local animation_mirror_head = HeadMaker.make(
	head,
	neck
)
```

Replace `head` by the `ModelPart` it corresponds to (for example, `models.model.root.hips.(...).Head`)

Replace `neck` by the `ModelPart` it corresponds to, if you don't have a neck, set it to `nil`.
