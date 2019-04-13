local nata = {
	_VERSION = 'Nata',
	_DESCRIPTION = 'Entity management for Lua.',
	_URL = 'https://github.com/tesselode/nata',
	_LICENSE = [[
		MIT License

		Copyright (c) 2019 Andrew Minnich

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

local function removeByValue(t, v)
	for i = #t, 1, -1 do
		if t[i] == v then table.remove(t, i) end
	end
end

local function entityHasKeys(entity, keys)
	for _, key in ipairs(keys) do
		if not entity[key] then return false end
	end
	return true
end

local function filterEntity(entity, filter)
	if type(filter) == 'table' then
		return entityHasKeys(entity, filter)
	elseif type(filter) == 'function' then
		return filter(entity)
	end
	return true
end

local Pool = {}
Pool.__index = Pool

function Pool:_init(options, ...)
	options = options or {}
	local groups = options.groups or {}
	local systems = options.systems or {nata.oop()}
	self._queue = {}
	self.entities = {}
	self.hasEntity = {}
	self.groups = {}
	for groupName, groupOptions in pairs(groups) do
		self.groups[groupName] = {
			filter = groupOptions.filter,
			sort = groupOptions.sort,
			entities = {},
			hasEntity = {},
		}
	end
	self._systems = {}
	for _, systemDefinition in ipairs(systems) do
		local system = setmetatable({
			pool = self,
		}, {__index = systemDefinition})
		table.insert(self._systems, system)
	end
	self:emit('init', ...)
end

function Pool:queue(entity)
	table.insert(self._queue, entity)
	return entity
end

function Pool:flush()
	for i = 1, #self._queue do
		local entity = self._queue[i]
		table.insert(self.entities, entity)
		self.hasEntity[entity] = true
		for _, group in pairs(self.groups) do
			if filterEntity(entity, group.filter) then
				table.insert(group.entities, entity)
				if group.sort then
					table.sort(group.entities, group.sort)
				end
				group.hasEntity[entity] = true
			end
		end
		self:emit('add', entity)
		self._queue[i] = nil
	end
end

function Pool:remove(f)
	for i = #self.entities, 1, -1 do
		local entity = self.entities[i]
		if f(entity) then
			self:emit('remove', entity)
			for _, group in pairs(self.groups) do
				removeByValue(group.entities, entity)
				group.hasEntity[entity] = nil
			end
			table.remove(self.entities, i)
			self.hasEntity[entity] = nil
		end
	end
end

function Pool:emit(event, ...)
	for _, system in ipairs(self._systems) do
		if type(system[event]) == 'function' then
			system[event](system, ...)
		end
	end
end

function Pool:refresh(flag)
	for _, entity in ipairs(self.entities) do
		if entity[flag] then
			entity[flag] = nil
			for _, group in pairs(self.groups) do
				local belongsInGroup = filterEntity(entity, group.filter)
				if belongsInGroup and not group.hasEntity[entity] then
					table.insert(group.entities, entity)
					if group.sort then
						table.sort(group.entities, group.sort)
					end
					group.hasEntity[entity] = true
				elseif not belongsInGroup and group.hasEntity[entity] then
					removeByValue(group.entities, entity)
					group.hasEntity[entity] = nil
				end
			end
		end
	end
end

function Pool:getSystem(systemDefinition)
	for _, system in ipairs(self._systems) do
		if getmetatable(system).__index == systemDefinition then
			return system
		end
	end
end

function nata.oop(groupName)
	return setmetatable({_cache = {}}, {
		__index = function(t, event)
			t._cache[event] = t._cache[event] or function(self, ...)
				local entities = groupName and self.pool.groups[groupName].entities or self.pool.entities
				for _, entity in ipairs(entities) do
					if type(entity[event]) == 'function' then
						entity[event](entity, ...)
					end
				end
			end
			return t._cache[event]
		end
	})
end

function nata.new(...)
	local pool = setmetatable({}, Pool)
	pool:_init(...)
	return pool
end

return nata
