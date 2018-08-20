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

local empty = {}

local function insert(t, v)
	assert(t, 'no table specified')
	assert(v, 'no value specified')
	local position = #t + 1
	if t._holes and #t._holes > 0 then
		position = t._holes[1]
		table.remove(t._holes, 1)
	end
	t[position] = v
	t[v] = position
end

local function remove(t, v)
	assert(t, 'no table specified')
	assert(v, 'no value specified')
	assert(t[v], 'trying to remove element that isn\'t in table')
	local position = t[v]
	if position < #t then
		t[position] = empty
		t._holes = t._holes or {}
		table.insert(t._holes, position)
	else
		t[position] = nil
	end
	t[v] = nil
end

local function iterate(t)
	assert(t, 'no table specified')
	local i = 0
	return function()
		while i < #t do
			i = i + 1
			if t[i] ~= empty then return t[i] end
		end
	end
end

local function sort(t, f)
	table.sort(t, function(a, b)
		if a == empty then return false end
		if b == empty then return true end
		return f(a, b)
	end)
	if t._holes then
		for i = #t._holes, 1, -1 do
			t[t._holes[i]] = nil
			t._holes[i] = nil
		end
	end
end

local function size(t)
	local holes = t._holes and #t._holes or 0
	return #t - holes
end

local function shouldSystemProcess(system, entity)
	if not system.filter then return true
	elseif type(system.filter) == 'table' then
		for _, component in ipairs(system.filter) do
			if not entity[component] then return false end
		end
		return true
	elseif type(system.filter) == 'function' then
		return system.filter(entity)
	else
		error 'system filter is an invalid type'
	end
end

local Pool = {}
Pool.__index = Pool

function Pool:callOn(entity, event, ...)
	for system in iterate(self.systems) do
		if system[event] and self._cache[system][entity] then
			system[event](entity, ...)
		end
	end
end

function Pool:call(event, ...)
	for _, system in ipairs(self.systems) do
		if system[event] then
			for entity in iterate(self._cache[system]) do
				system[event](entity, ...)
			end
		end
	end
end

function Pool:queue(entity, ...)
	insert(self._queue, {entity, {...}})
	return entity
end

function Pool:flush()
	for v in iterate(self._queue) do
		local entity, args = v[1], v[2]
		insert(self._entities, entity)
		for system in iterate(self.systems) do
			if shouldSystemProcess(system, entity) then
				self._cache[system] = self._cache[system] or {}
				insert(self._cache[system], entity)
				if system.sort then
					sort(self._cache[system], system.sort)
				end
				if system.add then system.add(entity, args) end
			end
		end
		remove(self._queue, v)
	end
end

function Pool:remove(f, ...)
	for i = #self._entities, 1, -1 do
		local entity = self._entities[i]
		if f(entity) then
			for system in iterate(self.systems) do
				if self._cache[system][entity] then
					if system.remove then system.remove(entity, ...) end
					remove(self._cache[system], entity)
				end
			end
			remove(self._entities, entity)
		end
	end
end

function Pool:get(f)
	local entities = {}
	for entity in iterate(self._entities) do
		if not f or f(entity) then
			table.insert(entities, entity)
		end
	end
	return entities
end

function Pool:getSize()
	return size(self._entities)
end

function nata.oop()
	return setmetatable({_f = {}}, {
		__index = function(t, k)
			if k == '_f' or k == 'filter' or k == 'sort' then
				return rawget(t, k)
			else
				t._f[k] = t._f[k] or function(e, ...)
					if type(e[k]) == 'function' then
						e[k](e, ...)
					end
				end
				return t._f[k]
			end
		end
	})
end

function nata.new(systems)
	return setmetatable({
		systems = systems or {nata.oop()},
		_entities = {},
		_cache = {},
		_queue = {},
	}, {__index = Pool})
end

return nata
