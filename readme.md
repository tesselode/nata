# Nata
**Nata** is an entity management library for LÖVE. It can be used in a traditional OOP style or a minimal ECS style.

Nata lets you create **entity pools**, which hold all of the objects in your game world, such as platforms, enemies, and collectables.

## Installation
To use Nata, place `nata.lua` in your project, and then add this code to your `main.lua`:
```lua
nata = require 'nata' -- if your nata.lua is in the root directory
nata = require 'path.to.nata' -- if it's in subfolders
```

## Usage - OOP style
In the traditional OOP (object oriented programming) style, an entity is a table that contains both **data** and **functions**. For example, a player entity may have `x` and `y` variables for position, as well as functions such as `jump`. Generally, all entities will have some of the same functions, such as `update` or `draw`, which contain behavior unique to that entity.

### Creating an entity pool
```lua
pool = nata.new()
```
Creates a pool which holds entities.

### Queueing entities to be added to the pool
```lua
entity = pool:queue(entity, ...)
```
Adds an entity to the queue and returns it. Additional arguments are stored to be passed to `entity.add` when the queue is flushed.

### Adding queued entities
```lua
pool:flush()
```
Adds all of the entities in the queue to the pool. For each entity, `entity:add(...)` will be called (if it exists), where `...` is the arguments passed to `pool.queue`.

### Running a function on all entities
```lua
pool:call(event, ...)
```
For each entity, this will run `entity:[event](...)` if the entity has a function called `event`. Any additional arguments passed to `pool.call` will be passed to each entity's function.

### Accessing entities
You can access the entities table directly using `pool.entities`. Feel free to read and modify these entities, but it's not recommended to manually insert or remove entities using this table.

### Removing entities
```lua
pool:remove(f)
```
Removes all the entities for which `f(entity)` returns true and calls the "remove" function on each entity that is removed.

## Usage - ECS style
While object oriented programming is a powerful metaphor, the **Entity Component System** pattern can offer greater flexibility and avoid some of the problems with inheritance. With ECS, entities primarily contain **data** rather than functions, and systems act on entities depending on what components they have.

Using Nata in the ECS style is similar to using it in the OOP style, except you pass a list of systems to `nata.new`.
```lua
pool = nata.new(systems)
```

### Defining systems
Systems are objects that act on a certain subset of the entity pool. The entities that a system acts on is determined by its filter, and the system performs actions when `pool.call` is called.

Systems are defined by a table such as this one:
```lua
local scoreSystem = {
  -- all of the following keys are optional.

  -- the filter decides which entities the system will process.
  -- if it is a table, only entities with all of the specified keys will be processed.
  filter = {'points'},
  
  -- the filter can also be a function that takes an entity as the first argument.
  -- if it returns true, the entity will be processed.
  filter = function(entity) return entity.points end,

  -- a sorting function that will be used to sort entities for this system only.
  -- by default, entities are only sorted when new ones are added.
  sort = function(a, b) return a.order < b.order end,

  -- whether to sort entities when running events as well as adding entities
  continuousSort = true,

  -- the function that will be run when the pool is created.
	init = function(self)
		self.score = 0
  end,

  -- called when an entity is added to a system
  -- only called for entities that this system actually processes
  -- additional arguments can be passed in from pool.queue
  add = function(self, entity, ...) end,

  -- called when an entity is removed from a system
  -- only called for entities that this system actually processes
  -- additional arguments can be passed in from pool.remove
  remove = function(self, entity, ...) end,
  
  -- other functions can be defined that correspond to events called using pool.call
  -- note that in this example, entity is not passed automatically, it's passed
  -- manually as an argument to pool.call
  killed = function(self, entity)
    self.score = self.score + entity.points
  end,

  draw = function(self)
    love.graphics.setColor(255, 255, 255)
    love.graphics.print(self.score)
  end,
}
```

When a pool is created, an "instance" of each system is created. The system functions take the system instance as their first argument, providing access to the following properties and functions:
- `entities` - a list of the entities the system acts on
- `hasEntity` - a set of the entities the system acts on
  - If `self.hasEntity[entity]` is `true`, that means the system currently acts on `entity`
- `queue(entity, ...)` - equivalent to `pool.queue`
- `call(event, ...)` - equivalent to `pool.call`

### Hybrid OOP/ECS style
Nata's OOP functionality is implemented as a single system that forwards events to every entity. If you want to use this system in combination with other systems, add `nata.oop()` to the `systems` table.

## Contributing
This library is in early development. Feel free to make suggestions about the design. Issues and pull requests are always welcome.

## License
MIT License

Copyright (c) 2019 Andrew Minnich

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
