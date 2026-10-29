# Animation Mirror (core) events.

For this page, assume we required Animation Mirror like so:

```lua
local AnimationMirror = require("animation_mirror/core")
```

The easiest way to hook into events is like so:

```lua
function AnimationMirror.events.state_change(new, old)
	if new == "COPYING" then
		print("I just started mirroring someone!")
	end
end
```

It is also valid to use this syntax several times:

```lua
function AnimationMirror.events.state_change(new, old)
	print("This will print when the event fires.")
end

function AnimationMirror.events.state_change(new, old)
	print("This will ALSO print when the event fires.")
end
```

Alternatively, you can use `register()`, which can also be used several times for the same event.

```lua
AnimationMirror.events.state_change.register(func(new, old)
	print("This will print when the event fires.")
end)
```

You can use `remove()` to unregister functions from events.

```lua
local function state_change_func(new, old)
	print("this will never print.")
end

AnimationMirror.events.state_change.register(state_change_func)

AnimationMirror.events.state_change.remove(state_change_func)
```

**NOTE:** Never have the same function registered to the same event more then once.

## `state_change(new, old)`

| Parameter | Type | Description
| - | - | - |
| `new` | string | The state Animation Mirror has switched to. |
| `old` | string | The state Animation Mirror was previously in. |

This event gets fired when Animation Mirror changes its state, this is caused by calling `AnimationMirror.begin_being_source()`, `AnimationMirror.begin_copying()` or `AnimationMirror.stop()`.

`new` and `old` can be either `SOURCE`, `COPYING` or `OFF`.

`new` and `old` can never be the same. If you, for example, call `AnimationMirror.begin_being_source()` while Animation Mirror is already in the `SOURCE` state, this event will not fire.

## `source_change(new, old)`

| Parameter | Type | Description
| - | - | - |
| `new` | string | The UUID of the person you're now mirroring. |
| `old` | string | The UUID of the person you were previously mirroring. |

This event gets fired when you change who you're mirroring.

`new` and `old` can never be the same. If you try to mirror someone you're already mirroring, this event won't fire.

`new` and `old` can never be the `nil`. This event does not fire is you start mirroring someone without already in the `COPYING` state, nor when stopping Animation Mirror or switching to the `SOURCE` state.