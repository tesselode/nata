Nata <!-- omit in toc -->
----
Nata is a Lua library for managing entities in games. It allows you to create **entity pools**, which are containers that hold all the objects in a game, like geometry, characters, and collectibles. At its simplest, pools hold entities and allow you to call functions on them, but they also provide a minimal structure for an Entity Component System organization.

To see Nata in action, open the demo with LÖVE from the base directory:
```
love demo
```

Table of contents <!-- omit in toc -->
=================
- [Installation](#installation)
- [Usage](#usage)
  - [Adding entities to a pool](#adding-entities-to-a-pool)
  - [Emitting events](#emitting-events)
  - [Removing entities](#removing-entities)
  - [Organizing entities into groups](#organizing-entities-into-groups)
  - [Accessing entities](#accessing-entities)
  - [Using systems](#using-systems)
  - [Updating and re-sorting groups](#updating-and-re-sorting-groups)
  - [Listening for events from outside the pool](#listening-for-events-from-outside-the-pool)
  - [Pool data](#pool-data)
- [API](#api)
  - [nata](#nata)
    - [`nata.new(options, ...)`](#natanewoptions-)
    - [`nata.oop(options)`](#nataoopoptions)
  - [Pool](#pool)
    - [Properties](#properties)
      - [`entities` (`table`)](#entities-table)
      - [`hasEntity` (`table`)](#hasentity-table)
      - [`groups` (`table`)](#groups-table)
      - [`data` (`table`)](#data-table)
    - [Functions](#functions)
      - [`pool:queue(entity)`](#poolqueueentity)
      - [`pool:flush()`](#poolflush)
      - [`pool:remove(f)`](#poolremovef)
      - [`pool:emit(event, ...)`](#poolemitevent-)
      - [`pool:on(event, f)`](#poolonevent-f)
      - [`pool:off(event, f)`](#pooloffevent-f)
      - [`pool:getSystem(systemDefinition)`](#poolgetsystemsystemdefinition)
  - [SystemDefinition](#systemdefinition)
    - [Functions](#functions-1)
      - [`SystemDefinition:init(...)`](#systemdefinitioninit)
      - [`SystemDefinition:add(entity)`](#systemdefinitionaddentity)
      - [`SystemDefinition:remove(entity)`](#systemdefinitionremoveentity)
      - [`SystemDefinition:addToGroup(groupName, entity)`](#systemdefinitionaddtogroupgroupname-entity)
      - [`SystemDefinition:removeFromGroup(groupName, entity)`](#systemdefinitionremovefromgroupgroupname-entity)
  - [SystemInstance](#systeminstance)
    - [Properties](#properties-1)
      - [`pool` (`Pool`)](#pool-pool)
- [Contributing](#contributing)

## Installation
To use Nata, place `nata.lua` in your project, and then add this code to the files where you use Nata:
```lua
local nata = require 'nata' -- if your nata.lua is in the root directory
local nata = require 'path.to.nata' -- if it's in subfolders
```

## Usage

### Adding entities to a pool
A pool is a container for the entities in our game world. To create a pool, use `nata.new`:
```lua
local pool = nata.new()
```
Nata assumes that each entity is represented by a table. The table might look something like this:
```lua
local enemy = {
  x = 50,
  y = 50,
  w = 25,
  h = 25,
  vx = 100,
  vy = 200,
  health = 2,
}
```
To add it to the pool, we can use `pool.queue`:
```lua
pool:queue(entity)
```
This won't immediately add it to the pool, it'll just queue it to be added later. To actually add the entities, we need to add `pool.flush` somewhere in our game loop, like `love.update`:
```lua
function love.update(dt)
  pool:flush()
end
```

### Emitting events
It's common for each entity to have callback functions like `update` and `draw`. To call these, we can use `pool.emit`:
```lua
function love.update(dt)
  pool:flush()
  pool:emit('update', dt)
end
```
This code will call `entity:update(dt)` on each entity (if it has a function called `update`).

### Removing entities
We can remove entities from the pool using `pool.remove`:
```lua
pool:remove(function(entity) return entity.dead end)
```
Rather than removing individual entities, we provide a function that decides which entities should be removed. The function takes an entity as the first argument, and it returns true if the entity should be removed. In this example, any entity for which `entity.dead` is true will be removed.

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
You can access entities by reading from the `entities` and `hasEntity` tables directly. You can also sort the `entities` tables manually if you want. It's not recommended to add or remove entities from these tables manually though; use `queue`/`flush`/`remove` for that.

### Using systems
In an Entity Component System architecture, a **system** affects entities with certain qualities. In Nata, a system is just an instance of a class that receives events from the pool and can call functions on the pool.

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

`init` is a special function that's called when the pool is first created. There's other special functions, too - see the [API](#systemdefinition) for the full list.

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

### nata
The main module. Creates pools and OOP systems.

#### `nata.new(options, ...)`
Creates a new entity pool.

Parameters:
- `options` (`table`) (optional) - a table of options to set up the pool with. The table should have the following contents:
  - `groups` (`table`) (optional) - a table of groups the sort entities into. Defaults to `{all = {}}`. Each key is the name of the group, and the value is a table with the following contents:
    - `filter` (`table` or `function`) (optional) - the requirement for entities to be added to this group. It can either be a list of required keys or a function that takes an entity as the first argument and returns if the entity should be added to the group. If no filter is specified, all entities will be added to the group.
    - `sort` (`function`) (optional) - a function that defines how entities will be sorted. The function works the same way as the as the function argument for `table.sort`.
  - `systems` (`table`) (optional) - a table of systems that should operate on the pool. Defaults to `{nata.oop()}`.
  - `data` (`table`) (optional) - a value to set `pool.data` to. Defaults to an empty table.
- `...` - additional arguments that will be used when the `init` event is emitted.

Returns:
- `pool` ([`Pool`](#Pool)) - the new pool

#### `nata.oop(options)`
Creates a system that receives events and calls the function of the same name on the entities themselves.

Parameters:
- `options` (`table`) (optional) - options for customizing the behavior of the system. The table should have the following contents:
  - `group` (`string`) (optional) - the name of the group of entities to call functions on
  - `include` (`table`) (optional) - a list of events to forward to entities. If defined, only these events will be forwarded.
  - `exclude` (`table`) (optional) - a list of events not to forward to entities.

Returns:
- `oopSystem` ([`SystemDefinition`](#SystemDefinition)) - the newly created OOP system

### Pool
A container for the entities and systems that make up a game world.

#### Properties

##### `entities` (`table`)
A list of all the entities in the pool.

##### `hasEntity` (`table`)
A set of all the entities in the pool. If the pool has an entity, `pool.hasEntity[entity]` will be true.

##### `groups` (`table`)
A dictionary of all the groups in the pool. Each group has the following members:
  - `entities` (`table`) - a list of all the entities in the group
  - `hasEntity` (`table`) - a set of all the entities in the group.
  - `filter` (`table` or `function` or `nil`) - the filter used to decide which entities belong in the grouop
  - `sort` (`function` or `nil`) - the function used to decide how entities should be sorted within the group

##### `data` (`table`)
A table you can use for whatever you like.

#### Functions

##### `pool:queue(entity)`
Queues an entity to be added to the pool. If the entity is already in the pool, the pool will re-check which groups the entity belongs in and add it to/remove it from groups as needed. Any group with a sort function that contains this entity will re-sort its entities list.

Parameters:
- `entity` - the entity to queue

Returns:
- `entity` (`table`) - the entity that was queued

##### `pool:flush()`
Adds/re-checks all of the queued entities (in the order they were queued).

##### `pool:remove(f)`
Removes all entities that meet the specified condition.

Parameters:
- `f` (`function`) - a function that takes an entity as an argument and returns `true` if the entity should be removed.

##### `pool:emit(event, ...)`
Calls the function named `event` on each system that has it.

Parameters:
- `event` (`string`) - the name of the function to call
- `...` - additional arguments to pass to the system's functions

##### `pool:on(event, f)`
Registers a function to be called when the specified event is emitted.

Parameters:
- `event` (`string`) - the event to listen for
- `f` (`function`) - the function to call

Returns:
- `f` (`function`) - the registered function

##### `pool:off(event, f)`
Unregisters a function from an event.

Parameters:
- `event` (`string`) - the event to unregister from
- `f` (`function`) - the function to unregister

##### `pool:getSystem(systemDefinition)`
Gets the pool's instance of a certain system.

Parameters:
- `systemDefinition` ([`SystemDefinition`](#SystemDefinition)) - the table that was used to add the system to the pool

Returns:
- `systemInstance` ([`SystemInstance`](#SystemInstance)) - the instance of the system running in this pool

### SystemDefinition
Defines a set of behaviors that can be added to a game world.

#### Functions
A system definition can have functions for the following special events, all of which are optional:

##### `SystemDefinition:init(...)`
Called when the pool is first creaed.

Parameters:
- `...` - additional arguments passed to `nata.new`

##### `SystemDefinition:add(entity)`
Called when an entity is added to the pool.

Parameters:
- `entity` (`table`) - the entity that was added

##### `SystemDefinition:remove(entity)`
Called when an entity is removed from the pool.

Parameters:
- `entity` (`table`) - the entity that was removed

##### `SystemDefinition:addToGroup(groupName, entity)`
Called when an entity is added to a group.

Parameters:
- `groupName` (`string`) - the name of the group the entity was added to
- `entity` (`table`) - the entity that was added

##### `SystemDefinition:removeFromGroup(groupName, entity)`
Called when an entity is removed from a group.

Parameters:
- `groupName` (`string`) - the name of the group the entity was removed from
- `entity` (`table`) - the entity that was removed

### SystemInstance
An instance of a system that runs in a pool.

#### Properties

##### `pool` ([`Pool`](#pool))
The pool that this system is currently running on.

## Contributing
Nata is still rapidly changing, so feel free to make suggestions about the design! Issues and pull requests are always welcome.
