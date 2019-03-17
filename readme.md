# Nata
Nata is a Lua library for managing entities in games. It allows you to create **entity pools**, which are containers that hold all the objects in a game, like geometry, characters, and collectibles. At its simplest, pools hold entities and allow you to call functions on them, but they also provide a minimal structure for an Entity Component System organization.

## Installation
To use Nata, place `nata.lua` in your project, and then add this code to the files where you use Nata:
```lua
local nata = require 'nata' -- if your nata.lua is in the root directory
local nata = require 'path.to.nata' -- if it's in subfolders
```

## Usage

### Creating a pool
```lua
local pool = nata.new()
```
When called without any arguments, `nata.new` creates a pool with default settings that are suitable for an object-oriented architecture.

### Queueing entities to be added to the world
```lua
local entity = pool:queue(entity)
```

### Adding queued entities to the world
```lua
pool:flush()
```
When an entity is added to the world, its `add` function is called, if it has one.

### Removing objects from the world
```lua
pool:remove(f)
```
This removes every entity for which `f(entity)` returns true, where `f` is a user-provided function that takes the `entity` as the first argument. For example, this code will remove any entities that have a field called `dead`.
```lua
pool:remove(function(entity) return entity.dead end)
```

### Emitting events
```lua
pool:emit(event, ...)
```
Calls the function named `event` on each entity that has one, and passes the additional arguments `...` to that function.

### Accessing entities
```lua
for _, entity in ipairs(pool.groups.entities.entities) do
  -- operate on entities...
end
print(pool.groups.entities.hasEntity[entity]) -- check if a group has an entity
```
Entities are stored in groups, which you can find in `pool.groups`. Each group has `entities`, an array of all the entities in the group, and `hasEntity`, a table which has each entity in the world as a key (with a dummy value of `true`).

Feel free to read from these tables and sort them. I wouldn't recommend adding or removing entities from these tables manually though; use `queue`/`flush`/`remove` for that.

### Sorting entities into more groups
You can set up additional groups to organize entities into. Each group can have its own **filter**, which determines which entities will be added to that group.