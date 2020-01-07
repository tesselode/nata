Nata
----
Nata is a Lua library for managing entities in games. It allows you to create **entity pools**, which are containers that hold all the objects in a game, like geometry, characters, and collectibles. At its simplest, pools hold entities and allow you to call functions on them, but they also provide a minimal structure for an Entity Component System organization.

To see Nata in action, open the demo with LÖVE from the base directory:
```
love demo
```

## Installation
To use Nata, place `nata.lua` in your project, and then add this code to the files where you use Nata:
```lua
local nata = require 'nata' -- if your nata.lua is in the root directory
local nata = require 'path.to.nata' -- if it's in subfolders
```

## Contributing
Nata is a young library, so feel free to make suggestions about the design! Issues and pull requests are always welcome.
