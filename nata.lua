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
	self._queue = {}
	self.entities = {}
	self.hasEntity = {}
	self.groups = {}
	self._systems = {}
	self._events = {}
	self.data = options.data or {}
	local groups = options.groups or {}
	local systems = options.systems or {nata.oop()}
	for groupName, groupOptions in pairs(groups) do
		self.groups[groupName] = {
			filter = groupOptions.filter,
			sort = groupOptions.sort,
			entities = {},
			hasEntity = {},
		}
	end
	for _, systemDefinition in ipairs(systems) do
		local system = setmetatable({
			pool = self,
		}, {__index = systemDefinition})
		table.insert(self._systems, system)
	end
	self:emit('init', ...)
end

function Pool:_addToGroup(groupName, entity)
	local group = self.groups[groupName]
	table.insert(group.entities, entity)
	group.hasEntity[entity] = true
	self:emit('addToGroup', groupName, entity)
end

function Pool:_removeFromGroup(groupName, entity)
	local group = self.groups[groupName]
	removeByValue(group.entities, entity)
	group.hasEntity[entity] = nil
	self:emit('removeFromGroup', groupName, entity)
end

function Pool:queue(entity)
	table.insert(self._queue, entity)
	return entity
end

function Pool:flush()
	for i = 1, #self._queue do
		local entity = self._queue[i]
		-- check if the entity belongs in each group and
		-- add it to/remove it from the group as needed
		for groupName, group in pairs(self.groups) do
			if filterEntity(entity, group.filter) then
				if not group.hasEntity[entity] then
					self:_addToGroup(groupName, entity)
				end
				if group.sort then group._needsResort = true end
			elseif group.hasEntity[entity] then
				self:_removeFromGroup(groupName, entity)
			end
		end
		-- add the entity to the pool if it hasn't been added already
		if not self.hasEntity[entity] then
			table.insert(self.entities, entity)
			self.hasEntity[entity] = true
			self:emit('add', entity)
		end
		self._queue[i] = nil
	end
	-- re-sort groups
	for _, group in pairs(self.groups) do
		if group._needsResort then
			table.sort(group.entities, group.sort)
			group._needsResort = nil
		end
	end
end

function Pool:remove(f)
	for i = #self.entities, 1, -1 do
		local entity = self.entities[i]
		if f(entity) then
			self:emit('remove', entity)
			for groupName, group in pairs(self.groups) do
				if group.hasEntity[entity] then
					self:_removeFromGroup(groupName, entity)
				end
			end
			table.remove(self.entities, i)
			self.hasEntity[entity] = nil
		end
	end
end

function Pool:on(event, f)
	self._events[event] = self._events[event] or {}
	table.insert(self._events[event], f)
	return f
end

function Pool:off(event, f)
	if self._events[event] then
		removeByValue(self._events[event], f)
	end
end

function Pool:emit(event, ...)
	for _, system in ipairs(self._systems) do
		if type(system[event]) == 'function' then
			system[event](system, ...)
		end
	end
	if self._events[event] then
		for _, f in ipairs(self._events[event]) do
			f(...)
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

function nata.oop(options)
	local group = options and options.group
	local include, exclude
	if options and options.include then
		include = {}
		for _, event in ipairs(options.include) do
			include[event] = true
		end
	end
	if options and options.exclude then
		exclude = {}
		for _, event in ipairs(options.exclude) do
			exclude[event] = true
		end
	end
	return setmetatable({_cache = {}}, {
		__index = function(t, event)
			t._cache[event] = t._cache[event] or function(self, ...)
				local shouldCallEvent = true
				if include and not include[event] then shouldCallEvent = false end
				if exclude and exclude[event] then shouldCallEvent = false end
				if shouldCallEvent then
					local entities
					-- not using ternary here because if the group doesn't exist,
					-- i'd rather it cause an error than just silently falling back
					-- to the main entity pool
					if group then
						entities = self.pool.groups[group].entities
					else
						entities = self.pool.entities
					end
					for _, entity in ipairs(entities) do
						if type(entity[event]) == 'function' then
							entity[event](entity, ...)
						end
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
