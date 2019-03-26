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

### Emitting events
```lua
pool:emit(event, ...)
```
Calls the function named `event` on each entity that has one, and passes the additional arguments `...` to that function.

### Accessing entities
```lua
for _, entity in ipairs(pool.groups.all.entities) do
  -- operate on entities...
end
print(pool.groups.all.hasEntity[entity]) -- check if a group has an entity
```
Entities are stored in groups, which you can find in `pool.groups`. Each group has `entities`, an array of all the entities in the group, and `hasEntity`, a table which has each entity in the world as a key (with a dummy value of `true`).

Feel free to read from these tables and sort them. It's not recommended to add or remove entities from these tables manually though; use `queue`/`flush`/`remove` for that.

### Sorting entities into more groups
You can set up additional groups to organize entities into. Each group can have its own **filter**, which determines which entities will be added to that group.

You can define groups by passing an options table into `nata.new`:
```lua
local pool = nata.new {
  groups = {
    all = {},
    physical = {filter = {'x', 'y', 'w', 'h'}},
    large = {filter = function(entity)
      return entity.w > 100 or entity.h > 100
    end},
  }
}
```
Filters can be either a table of required keys or a function. You can also leave out the filter, which allows all entities to be added to that group.

### Using systems
A **system**, generally speaking, defines a behavior that affects entities in certain groups. In Nata, a system is just an instance of a class that receives events from the pool and can call functions on the pool.

A system is defined like this:
```lua
local GravitySystem = {}

function GravitySystem:update(dt)
  for _, e in ipairs(self.pool.groups.gravity.entities) do
    e.vy = e.vy + e.gravity * dt
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

Also note that the system functions are all self functions - each pool has its own instance of each system "class", and system functions are called with the system instance as the first argument, so you can store data in the systems without affecting the original table. `system.pool` is automatically set to the pool that's using the system instance, so systems can interact with the pool in whatever way is needed.

Note that when the `systems` table is not defined, the pool defaults to having one system: the `nata.oop` system. This system is responsible for calling functions on entities when an event is emitted. If you're defining a list of systems and you want to retain this behavior, you should add `nata.oop(group)` to your systems list, where `group` is the name of the group whose entities you want to call functions on:
```lua
local pool = nata.new {
  groups = {
    everything = {},
    gravity = {filter = {'gravity'}},
  },
  systems = {
    nata.oop 'everything',
    GravitySystem,
  },
}
```

### Special events
When an entity is added to the world, the `add` event is emitted with two arguments: `groupName`, the name of the group the entity was added to, and `entity`, the entity that was added. When entities are removed from the world, the `remove` event is called with the same arguments.

## API
```lua
local pool = nata.new(options, ...)
```
Creates a new entity pool.
- `options` (optional) - a table of options to set up the pool with. The table should have the following contents:
  - `groups` (optional) - a table of groups the sort entities into. Defaults to `{all = {}}`. Each key is the name of the group, and the value is a table with the following contents:
    - `filter` (optional) - the requirement for entities to be added to this group. It can either be a list of required keys or a function that takes an entity as the first argument and returns if the entity should be added to the group. If no filter is specified, all entities will be added to the group.
    - `sort` (optional) - a function that defines how entities will be sorted. The function works the same way as the as the function argument for `table.sort`.
  - `systems` (optional) - a table of systems that should operate on the pool. Defaults to `nata.oop('all')`.
- `...` - additional arguments that will be used when the `init` event is emitted.

```lua
pool:queue(entity)
```
Queues an entity to be added to the pool.
- `entity` - the entity to queue

```lua
pool:flush()
```
Adds all of the queued entities to the pool (in the order they were queued). `pool:emit('add', entity)` will be called for each entity that's added.

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