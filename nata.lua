local nata = {}

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

function System:_onEmit(event, ...)
	self:_sort()
	if self._definition.on and self._definition.on[event] then
		self._definition.on[event](self, ...)
	end
end

local function newSystem(definition)
	return setmetatable({
		entities = {},
		hasEntity = {},
		_definition = definition,
		_sorted = false,
	}, System)
end

local Pool = {}
Pool.__index = Pool

function Pool:addSystem(definition)
	local system = newSystem(definition)
	for _, entity in ipairs(self.entities) do
		system:_addEntity(entity)
	end
	table.insert(self._systems, system)
	return self
end

function Pool:emit(event, ...)
	for _, system in ipairs(self._systems) do
		system:_onEmit(event, ...)
	end
end

function Pool:process(name, ...)
	for _, system in ipairs(self._systems) do
		system:_process(name, ...)
	end
end

function Pool:queue(entity)
	table.insert(self._queue, entity)
	return entity
end

function Pool:flush()
	for i, entity in ipairs(self._queue) do
		table.insert(self.entities, entity)
		for _, system in ipairs(self._systems) do
			system:_addEntity(entity)
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
			for _, system in ipairs(self._systems) do
				system:_removeEntity(entity)
			end
			table.remove(self.entities, i)
		end
	end
end

function nata.new()
	return setmetatable({
		entities = {},
		_systems = {},
		_queue = {},
	}, Pool)
end

return nata
