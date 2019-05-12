# Nata
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
The `remove` function will also be called on those entities, if they have one.

### Emitting events
```lua
pool:emit(event, ...)
```
Calls the function named `event` on each entity that has one, and passes the additional arguments `...` to that function.

### Organizing entities into groups
By default, pools store every entity in a single collection, but you can also set up additional groups to organize entities into. Each group can have its own **filter**, which determines which entities will be added to that group. Groups can also have a `sort` function, which is used to sort the entities in the group whenever a new one is added.

You can define groups by passing an options table into `nata.new`:
```lua
local pool = nata.new {
  groups = {
    physical = {filter = {'x', 'y', 'w', 'h'}},
    large = {
      filter = function(entity)
        return entity.w > 100 or entity.h > 100
      end,
      sort = function(a, b)
        return a.w + a.h < b.w + b.h
      end,
    },
  }
}
```
Filters can be either a table of required keys or a function. You can also leave out the filter, which allows all entities to be added to that group. The sort function works the same way as the second argument to `table.sort`.

### Accessing entities
```lua
-- iterate through all entities
for _, entity in ipairs(pool.entities) do end

-- iterate through the physical group
for _, entity in ipairs(pool.groups.physical.entities) do end

-- check if the pool has an entity
print(pool.hasEntity[entity])

-- check if a specific group has an entity
print(pool.groups.physical.hasEntity[entity])
```
Feel free to read from the `entities` and `hasEntity` tables directly. You can also sort the `entities` tables manually if you want. It's not recommended to add or remove entities from these tables manually though; use `queue`/`flush`/`remove` for that.

### Using systems
A **system**, generally speaking, defines a behavior that affects entities in certain groups. In Nata, a system is just an instance of a class that receives events from the pool and can call functions on the pool.

A system is defined like this:
```lua
local GravitySystem = {}

function GravitySystem:init()
  self.baseGravity = 100
end

function GravitySystem:update(dt)
  for _, e in ipairs(self.pool.groups.gravity.entities) do
    e.vy = e.vy + self.baseGravity * e.gravity * dt
  end
end
```
You can add systems to a pool by including a `systems` table in the options table passed to `nata.new`:
```lua
local pool = nata.new {
  groups = {
    gravity = {filter = {'gravity'}},
  },
  systems = {
    GravitySystem,
  },
}
```
Now, when `pool:emit('update', dt)` is called, `GravitySystem:update(dt)` will be called as well.

Also note that the system functions are all self functions - each pool creates "instances" of each system "class", so systems can hold their own internal state. Each system also has `self.pool`, which allows access to all pool functions and properties.

Note that when the `systems` table is not defined, the pool defaults to having one system: the `nata.oop` system. This system is responsible for calling functions on entities when an event is emitted. If you're defining a list of systems and you want to retain this behavior, you should add `nata.oop()` to your systems list.
```lua
local pool = nata.new {
  groups = {
    gravity = {filter = {'gravity'}},
  },
  systems = {
    nata.oop(),
    GravitySystem,
  },
}
```
When called without any arguments, `nata.oop` will create a system that operates on every entity in the pool. If you want it to only operate on a specific group, you can pass an options table to `nata.oop` with a `group` field. You can also whitelist or blacklist events for the system to forward to entities using `include` and `exclude`. In this example, the `nata.oop` system will only operate on entities in the gravity group, and it won't call the draw event on those entities.
```lua
  local pool = nata.new {
  groups = {
    gravity = {filter = {'gravity'}},
  },
  systems = {
    nata.oop {
      group = 'gravity',
      exclude = {'draw'},
    },
    GravitySystem,
  },
}
```

### Updating and re-sorting groups
Sometimes, you may want to add or remove a component on an entity after it's been added to the pool, and you may want those changes to be reflected in the groups so that systems can iterate over the right entities. Pools don't know when an entity changes, but if you queue the entity again, then when the entity is flushed, the pool will re-check which groups the entity belongs to. Groups containing the queued entity will also re-sort their entities even if the queued entity was already in the group, so you can use this to sort groups at any time.

### Special events
Pools emit certain events automatically at certain times:
- `pool:emit('init', ...)` - called when the pool is created. `...` are additional arguments (after the options table) passed to `nata.new`.
- `pool:emit('add', entity)` - called when an entity is added to the pool.
- `pool:emit('remove', entity)` - called when an entity is removed from the pool.
- `pool:emit('addToGroup', groupName, entity`) - called when an entity is added to a group.
- `pool:emit('removeFromGroup', groupName, entity`) - called when an entity is removed from a group.

### Listening for events from outside the pool
Any system in a pool will automatically receive events that the pool emits. However, it can be useful to listen for events in a piece of code that isn't one the pool's systems. You can trigger any function when a certain event occurs using `pool.on`:
```lua
local listener = pool:on('quitGame', function()
  love.event.quit()
end)
```
In this example, when the pool emits the `quitGame` event, the game will be closed. If you want to undo this later, you can use `pool.off`:
```lua
pool:off('quitGame', listener)
```

### Pool data
Each pool has a `data` field, which by default is an empty table. You can set it to anything you want by defining a `data` field in the options table passed to `nata.new`. This happens before the "init" event is called, so systems can use the data in the `init` function. Besides this, Nata doesn't use the data field in any way, so feel free to use it for whatever you want.

## API
```lua
local pool = nata.new(options, ...)
```
Creates a new entity pool.
- `options` (optional) - a table of options to set up the pool with. The table should have the following contents:
  - `groups` (optional) - a table of groups the sort entities into. Defaults to `{all = {}}`. Each key is the name of the group, and the value is a table with the following contents:
    - `filter` (optional) - the requirement for entities to be added to this group. It can either be a list of required keys or a function that takes an entity as the first argument and returns if the entity should be added to the group. If no filter is specified, all entities will be added to the group.
    - `sort` (optional) - a function that defines how entities will be sorted. The function works the same way as the as the function argument for `table.sort`.
    - `data` (optional) - a value to set `pool.data` to. Defaults to an empty table.
  - `systems` (optional) - a table of systems that should operate on the pool. Defaults to `nata.oop()`.
- `...` - additional arguments that will be used when the `init` event is emitted.

```lua
local entity = pool:queue(entity)
```
Queues an entity to be added to the pool and returns the entity that was queued. If the entity is already in the pool, the pool will re-check which groups the entity belongs in and add it to/remove it from groups as needed. Any group with a sort function that contains this entity will re-sort its entities list.
- `entity` - the entity to queue

```lua
pool:flush()
```
Adds/re-checks all of the queued entities (in the order they were queued).

```lua
pool:remove(f)
```
Removes all entities that meet the specified condition.
- `f` - a function that takes an entity as an argument and returns `true` if the entity should be removed.

```lua
pool:emit(event, ...)
```
Calls the function named `event` on each system that has it.
- `event` - the name of the function to call
- `...` - additional arguments to pass to the system's functions

```lua
local f = pool:on(event, f)
```
Registers a function to be called when the specified event is emitted. Returns the registered function.
- `event` - the event to listen for
- `f` - the function to call

```lua
pool:off(event, f)
```
Unregisters a function from an event.
- `event` - the event to unregister from
- `f` - the function to unregister

```lua
pool:getSystem(systemDefinition)
```
Gets the pool's instance of a certain system.
- `systemDefinition` - the table that was used to add the system to the pool

```lua
local oopSystem = nata.oop(groupName)
```
Creates a system that receives events and calls the function of the same name on the entities themselves.
- `groupName` - the group of entities to call functions on

## Contributing
Nata is still in early development, so feel free to make suggestions about the design! Issues and pull requests are always welcome.
