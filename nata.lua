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

local System = {}
System.__index = System

function System:_shouldProcess(entity)
	if type(self._definition.filter) == 'table' then
		for _, component in ipairs(self._definition.filter) do
			if not entity[component] then
				return false
			end
		end
		return true
	elseif type(self._definition.filter) == 'function' then
		return self._definition.filter(self, entity)
	end
	return true
end

function System:_addEntity(entity)
	if not self:_shouldProcess(entity) then
		return false
	end
	table.insert(self.entities, entity)
	self.hasEntity[entity] = true
	if self._definition.sort then
		self._sorted = false
	end
end

function System:_removeEntity(entity)
	if not self.hasEntity[entity] then
		return false
	end
	for i = #self.entities, 1, -1 do
		if self.entities[i] == entity then
			table.remove(self.entities, i)
			break
		end
	end
	self.hasEntity[entity] = false
end

function System:_sort()
	if self._definition.sort and not self._sorted then
		table.sort(self.entities, self._definition.sort)
		self._sorted = true
	end
end

function System:_process(name, ...)
	self:_sort()
	if self._definition.process and self._definition.process[name] then
		self._definition.process[name](self, ...)
	end
end

function System:_trigger(event, entity, ...)
	if not self._definition.on then return false end
	if not self._definition.on[event] then return false end
	if not self.hasEntity[entity] then return false end
	self:_sort()
	self._definition.on[event](self, entity, ...)
end

function System:queue(...) self._pool:queue(...) end
function System:process(...) self._pool:process(...) end
function System:trigger(...) self._pool:trigger(...) end

local function newSystem(pool, definition)
	local system = setmetatable({
		entities = {},
		hasEntity = {},
		_pool = pool,
		_definition = definition,
		_sorted = false,
	}, System)
	if system._definition.init then system._definition.init(system) end
	return system
end

nata.oop = {
	process = setmetatable({_f = {}}, {
		__index = function(t, k)
			if k == 'f' then
				return rawget(t, k)
			else
				t._f[k] = t._f[k] or function(self, ...)
					for _, entity in ipairs(self.entities) do
						if type(entity[k]) == 'function' then
							entity[k](entity, ...)
						end
					end
				end
				return t._f[k]
			end
		end,
	}),
	on = setmetatable({_f = {}}, {
		__index = function(t, k)
			if k == 'f' then
				return rawget(t, k)
			else
				t._f[k] = t._f[k] or function(self, entity, ...)
					if type(entity[k]) == 'function' then
						entity[k](entity, ...)
					end
				end
				return t._f[k]
			end
		end,
	}),
}

local Pool = {}
Pool.__index = Pool

function Pool:trigger(event, entity, ...)
	for _, system in ipairs(self._systems) do
		system:_trigger(event, entity, ...)
	end
end

function Pool:process(name, ...)
	for _, system in ipairs(self._systems) do
		system:_process(name, ...)
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
			system:_addEntity(entity)
		end
		self:trigger('add', entity, unpack(args))
		self._queue[i] = nil
	end
end

function Pool:remove(f, ...)
	for i = #self.entities, 1, -1 do
		local entity = self.entities[i]
		if f(entity) then
			self:trigger('remove', entity, ...)
			for _, system in ipairs(self._systems) do
				system:_removeEntity(entity)
			end
			table.remove(self.entities, i)
		end
	end
end

function nata.new(systems)
	systems = systems or {nata.oop}
	local pool = setmetatable({
		entities = {},
		_systems = {},
		_queue = {},
	}, Pool)
	for _, system in ipairs(systems) do
		table.insert(pool._systems, newSystem(pool, system))
	end
	return pool
end

return nata
