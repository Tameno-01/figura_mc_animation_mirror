# Player picker

PlayerPicker is a simple utility to get the UUID of whoever you're looking at. if you already have a system for getting peoples's UUIDs, you don't need this utility and can delete the `animation_mirror/player_picker.lua` file.

To use it, first require PlayerPicker:

```lua
local PlayerPicker = require("animation_mirror/player_picker")
```

Then, you can get the uuid of whoever you're looking at at any given moment like so:

```lua
local uuid, err, entity = PlayerPicker.pick_player()
```

If you're looking at a mirrorable player, `uuid` will be the UUID of that player. Otherwise, it will be `nil` and `err` will be one of the following strings:

| Error | Description |
| - | - |
| `NOT_HOST` | This function was called on a non-host, use `host:isHost()` to check if you're the host. |
| `PLAYER_NOT_LOADED` | The player wasn't loaded when this function got called. |
| `NO_ENTITY` | You're not looking at any entity.
| `NOT_PLAYER` | The entity you're looking at is not a player. |
| `NOT_COPYABLE` | The player you're looking at is not mirrorable. |

In the case of `err` being either `NOT_PLAYER` or `NOT_COPYABLE`, `entity` will be the entity you're looking at.

You can use `err` and `entity` to display something when mirroring doesn't work.