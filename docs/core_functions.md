# Animation Mirror (core) functions

For all these functions, assume we required Animation Mirror like so:

```lua
local AnimationMirror = require("animation_mirror/core")
```

## `AnimationMirror.set_body(body)`

| Parameter | Type | Description
| - | - | - |
| `body` | table | The body Animation Mmirror will use. |

Sets the body Animation Mirror will use. See the [how to use](how_to_use.md) guide for more info.

This function should only be called once, before any calls to `AnimationMirror.being_source()` and `AnimationMirror.being_copying()`. It is recommended to call this as early as possible.

## `AnimationMirror.set_allow_copy_func(func)`

| Parameter | Type | Description
| - | - | - |
| `func` | function | The function that determines whether someone is mirrorable. |

When someone tries to mirror you, Animation Mirror will run `func` with their UUID as its first parameter. If it returns `true`, that person will be able to mirror you, if it returns `false`, they won't.

This function may also be run if people check wether you're mirrorable by them using `AnimationMirror.can_copy()`.

If this function never gets called, the default behavior is to allow everyone to mirror you.

## `AnimationMirror.begin_being_source()`

Puts Animation Mirror in the `SOURCE` state, which allows other people to mirror you.

## `AnimationMirror.begin_copying(uuid)`

| Parameter | Type | Description
| - | - | - |
| `uuid` | string | The uuid of the person you want to mirror. |

Begins mirroring the person represented by `uuid`, putting Animation Mirror in the `COPYING` state.

Returns a `bool` which is `true` if the mirroring succeeded.

Calling this function on someone you're already mirroring will simply do nothing and return `false`.

**NOTE:** It is possible for mirroring to fail even if `AnimationMirror.can_copy()` returns `true`, this can happen if someone modified the code of Animation Mirror (or if there's a bug i missed). Depending on how late in the process the failure happened, Animation Mirror could be forced to change to the `OFF` state.

## `AnimationMirror.stop()`

Stops Animation Mirror, making you no longer mirrorable nor mirroring anyone. This puts Animation Mirror in the `OFF` state.

## `AnimationMirror.get_current_state()`

Returns a string that can be either `SOURCE`, `COPYING` or `OFF`, which represents the state Animation Mirror is in.

For more info, see, `AnimationMirror.begin_being_source()`, `AnimationMirror.begin_copying()` and `AnimationMirror.stop()`.

## `AnimationMirror.get_source_player_uuid()`

Returns the UUID of whoever you're mirroring, or `nil` if you're not mirroring anyone.

If you're currently in the `SOURCE` state, this function will return your own UUID.

## `AnimationMirror.can_copy(uuid)`

| Parameter | Type | Description
| - | - | - |
| `uuid` | string | The uuid of the person you want to check if you can mirror. |

Checks is the person represented by `uuid` is mirrorable by you.

**NOTE:** It is possible for calls to `AnimationMirror.begin_copying()` to fail even if this function returns `true`, this can happen if someone modified the code of Animation Mirror (or if there's a bug i missed).

## `AnimationMirror.get_others_source_uuid(uuid)`

| Parameter | Type | Description
| - | - | - |
| `uuid` | string | The uuid of the person you want to check who they're mirroring. |

Returns the UUID of whoever the person represented by `uuid` is mirroring, or `nil` if they're not mirroring anyone.

If that person is in the `SOURCE` state, this function will simply return whatever you passed in as `uuid`.