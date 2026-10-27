# Vanilla head setup

First, require the vanilla head maker:

```lua
local HeadMaker = require("animation_mirror/body_maker/head/vanilla")
```

Then, make the head like so:

```lua
local animation_mirror_head = HeadMaker.make(
	head
)
```

Replace `head` by the `ModelPart` it corresponds to (for example, `models.model.root.Head`).