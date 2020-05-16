# Tutorial

## Installation
To use Nata, place `nata.lua` in your project, and then add this code to the files where you use Nata:
```lua
local nata = require 'nata' -- if your nata.lua is in the root directory
local nata = require 'path.to.nata' -- if it's in subfolders
```

## Adding entities to a pool
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
To add it to the pool, we can use `Pool:queue`:
```lua
pool:queue(entity)
```
This won't immediately add it to the pool, it'll just queue it to be added later. To actually add the entities, we need to add `Pool:flush` somewhere in our game loop, like `love.update`:
```lua
function love.update(dt)
  pool:flush()
end
```

## Emitting events
It's common for each entity to have callback functions like `update` and `draw`. To call these, we can use `Pool:emit`:
```lua
function love.update(dt)
  pool:flush()
  pool:emit('update', dt)
end
```
This code will call `entity:update(dt)` on each entity (if it has a function called `update`).

## Removing entities
We can remove entities from the pool using `Pool:remove`:
```lua
pool:remove(function(entity) return entity.dead end)
```
Rather than removing individual entities, we provide a function that decides which entities should be removed. The function takes an entity as the first argument, and it returns true if the entity should be removed. In this example, any entity for which `entity.dead` is true will be removed.

## Organizing entities into groups
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

## Accessing entities
```lua
-- iterate through all entities
for _, entity in ipairs(pool.entities) do end

-- iterate through the physical group
for _, entity in ipairs(pool.groups.physical.entities) do end

-- check if the pool has an entity
print(pool.has[entity])

-- check if a specific group has an entity
print(pool.groups.physical.has[entity])
```
You can access entities by reading from the `entities` and `has` tables directly. You can also sort the `entities` tables manually if you want. It's not recommended to add or remove entities from these tables manually though; use `queue`/`flush`/`remove` for that.

## Using systems
In an Entity Component System architecture, a **system** affects entities with certain qualities. In Nata, a system is just an object that receives events from a pool.

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

`init` is a special function that's called when the pool is first created. There's other special functions, too - see the API for the full list.

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

## Updating and re-sorting groups
Sometimes, you may want to add or remove a component on an entity after it's been added to the pool, and you may want those changes to be reflected in the groups so that systems can iterate over the right entities. Pools don't know when an entity changes, but if you queue the entity again, then when the entity is flushed, the pool will re-check which groups the entity belongs to. Groups containing the queued entity will also re-sort their entities even if the queued entity was already in the group, so you can use this to sort groups at any time.

## Listening for events from outside the pool
Any system in a pool will automatically receive events that the pool emits. However, it can be useful to listen for events in a piece of code that isn't one the pool's systems. You can trigger any function when a certain event occurs using `Pool:on`:
```lua
local listener = pool:on('quitGame', function()
  love.event.quit()
end)
```
In this example, when the pool emits the `quitGame` event, the game will be closed. If you want to undo this later, you can use `Pool:off`:
```lua
pool:off('quitGame', listener)
```

## Pool data
Each pool has a `data` field, which by default is an empty table. You can set it to anything you want by defining a `data` field in the options table passed to `nata.new`. This happens before the "init" event is called, so systems can use the data in the `init` function. Besides this, Nata doesn't use the data field in any way, so feel free to use it for whatever you want.
