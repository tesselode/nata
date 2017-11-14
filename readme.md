# Nata
**Nata** is a library for LÖVE that creates entity pools. It can be used in either a traditional OOP style or a simple ECS style.

See the demos folder for some examples - the shooter example uses OOP, while the platformer example uses ECS.

## Installation
To use Nata, place `nata.lua` in your project, and then add this code to your `main.lua`:
```lua
nata = require 'nata' -- if your nata.lua is in the root directory
nata = require 'path.to.nata' -- if it's in subfolders
```

## Usage - OOP style

### Creating an entity pool
```lua
pool = nata.new()
```

### Adding an entity to the pool
```lua
entity = pool:add(entity)
```
Adds an entity to the pool and returns the entity.

### Calling an event for all entities
```lua
pool:call(event, ...)
```
For each entity, this will run `entity:[event](...)` if the entity has a function called `event`. Any additional arguments passed to `pool.call` will be passed to each entity's function.

### Calling an event for a single entity
```lua
pool:callOn(entity, event, ...)
```

### Getting entities
```lua
entities = pool:get(f)
```
Returns a table containing all the entities for which `f(entity)` returns true. For example, this code will return a table with all the entities that are marked as "solid":
```lua
solidEntities = pool:get(function(entity)
  return entity.solid
end)
```
If no function is provided, `pool:get()` will return every entity.

### Sorting entities
```lua
pool:sort(f)
```
Sorts the entities according to the function `f`. This works just like `table.sort`.

### Removing entities
```lua
pool:remove(f)
```
Removes all the entities for which `f(entity)` returns true and calls the "remove" event on each entity that is removed.

## Usage - ECS style
ECS style is almost exactly the same as OOP style, except you pass a list of systems to nata.
```lua
pool = nata.new(systems)
```
Each system is a table with an optional filter function and a function for each event it should respond to. Each event function will receive an entity first, followed by any additional arguments passed to `pool.call`, `pool.callOn`, `pool.add`, or `pool.remove`. For example, a gravity system might look like this:
```lua
GravitySystem = {
  filter = function(entity)
    return entity.vy and entity.gravity
  end,
  update = function(entity, dt)
    entity.vy = entity.vy + entity.gravity * dt
  end,
}
```
Nata's OOP functionality is implemented as a single system that passes every event (except for "filter" and "add") to the entity. If you want to use this system in combination with other systems, add `nata.oop` to the `systems` table.

## Contributing
This library is in very early development. Feel free to make suggestions about the design. Issues and pull requests are always welcome.

## License
MIT License

Copyright (c) 2017 Andrew Minnich

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
