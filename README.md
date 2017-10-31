# SqueezeVelocity
Fuzzy search your music collection. For Logitech Media Server 7.6 and up.

![screenshot](screen.png "Screenshot")

## Usage
Unzip spoon in `~/.hammerspoon/Spoons`

```
sqz = hs.loadSpoon("SqueezeVelocity")
sqz:configure({serverURL = "http://192.168.178.20:9002/",
               playerId = "00:00:00:00:00:00",
               albumCoversEnabled = true})
sqz:start()
sqz:bindHotKeys({show={{"cmd", "ctrl" }, "P"}})
```
