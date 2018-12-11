local nata = {
	_VERSION = 'Nata',
	_DESCRIPTION = 'Entity management for Lua.',
	_URL = 'https://github.com/tesselode/nata',
	_LICENSE = [[
		MIT License

		Copyright (c) 2018 Andrew Minnich

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
	]]
}

local function checkForReservedNames(name)
	if name == 'filter' then error 'filter is a reserved name for systems' end
	if name == 'sort' then error 'sort is a reserved name for systems' end
	if name == 'continuousSort' then error 'continuousSort is a reserved name for systems' end
	if name == 'init' then error 'init is a reserved name for systems' end
	if name == 'queue' then error 'queue is a reserved name for systems' end
	if name == 'call' then error 'call is a reserved name for systems' end
end

--[[
	System definitions:

	Passed to nata.new to define the systems you can use. They're a table with the following keys:
	- filter - function|table|nil - defines what entities the system acts on
		- if it's a function and function(entity) returns true, the system will act on that entity
		- if it's a table and each item of the table is a key in the entity, the system will act on that entity
		- if it's nil, the system will act on every entity
	- sort (optional) - if defined, systems will sort their entities when new ones are added.
		- sort functions work the same way as with table.sort
	- continuousSort - if true, systems will also sort entities on pool calls
	- init (optional) - a self function that will run when the pool is created
	- ... - other functions will be called when pool:call(...) is called
]]

-- A system instance that does processing on entities within a pool.
local System = {}
function System:__index(k)
	return System[k] or self._definition[k]
end

-- internal functions --

-- uses the filter table/function in the system definition to decide if the system
-- should add an entity to its pool
function System:_shouldProcess(entity)
	if type(self._definition.filter) == 'table' then
		for _, component in ipairs(self._definition.filter) do
			if not entity[component] then return false end
		end
		return true
	elseif type(self._definition.filter) == 'function' then
		return self._definition.filter(self, entity)
	end
	return true
end

-- adds an entity to the system's pool and sorts the entities if needed
function System:_addEntity(entity, ...)
	if not self:_shouldProcess(entity) then return false end
	table.insert(self.entities, entity)
	self.hasEntity[entity] = true
	if type(self._definition.add) == 'function' then
		self._definition.add(self, entity, ...)
	end
	if self._definition.sort then
		table.sort(self.entities, self._definition.sort)
	end
end

-- removes an entity from the system's pool
function System:_removeEntity(entity, ...)
	if not self.hasEntity[entity] then return false end
	if type(self._definition.remove) == 'function' then
		self._definition.remove(self, entity, ...)
	end
	for i = #self.entities, 1, -1 do
		if self.entities[i] == entity then
			table.remove(self.entities, i)
			break
		end
	end
	self.hasEntity[entity] = false
end

function System:_call(name, ...)
	checkForReservedNames(name)
	if type(self._definition[name]) == 'function' then
		self._definition[name](self, ...)
		if self._definition.sort and self._definition.continuousSort then
			table.sort(self.entities, self._definition.sort)
		end
	end
end

-- public functions - accessible within the system definition's functions --
function System:queue(...) self._pool:queue(...) end
function System:call(...) self._pool:call(...) end

local function newSystem(pool, definition, ...)
	local system = setmetatable({
		entities = {}, -- also accessible from within system definition's functions
		hasEntity = {}, -- also accessible from within system definition's functions
		_pool = pool,
		_definition = definition,
	}, System)
	if system._definition.init then system._definition.init(system, ...) end
	return system
end

--[[
	creates a system that forwards pool calls to each entity
	for example, if pool:call('update', dt) is called, the system
	will call entity:update(dt) on each entity that has an update function
]]
function nata.oop(sort, continuousSort)
	return setmetatable({_f = {}}, {
		__index = function(t, k)
			if k == 'filter' or k == 'init' then return nil end
			if k == 'sort' then return sort end
			if k == 'continuousSort' then return continuousSort end
			t._f[k] = t._f[k] or function(self, ...)
				for _, entity in ipairs(self.entities) do
					if type(entity[k]) == 'function' then
						entity[k](entity, ...)
					end
				end
			end
			return t._f[k]
		end
	})
end

-- A manager for entities and systems
local Pool = {}
Pool.__index = Pool

function Pool:call(name, ...)
	checkForReservedNames(name)
	for _, system in ipairs(self._systems) do
		system:_call(name, ...)
	end
end

function Pool:queue(entity, ...)
	table.insert(self._queue, {entity, {...}})
	return entity
end

function Pool:flush()
	for i, v in ipairs(self._queue) do
		local entity, args = v[1], v[2]
		table.insert(self.entities, entity)
		for _, system in ipairs(self._systems) do
			system:_addEntity(entity, unpack(args))
		end
		self._queue[i] = nil
	end
end

function Pool:remove(f, ...)
	for i = #self.entities, 1, -1 do
		local entity = self.entities[i]
		if f(entity) then
			for _, system in ipairs(self._systems) do
				system:_removeEntity(entity, ...)
			end
			table.remove(self.entities, i)
		end
	end
end

-- Creates a new pool
function nata.new(systems, ...)
	systems = systems or {nata.oop}
	local pool = setmetatable({
		entities = {},
		_systems = {},
		_queue = {},
	}, Pool)
	for _, system in ipairs(systems) do
		table.insert(pool._systems, newSystem(pool, system, ...))
	end
	return pool
end

return nata
