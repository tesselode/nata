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

function System:emit(event, ...)
	self._pool:emit(event, ...)
end

local function newSystem(pool, definition)
	return setmetatable({
		entities = {},
		hasEntity = {},
		_pool = pool,
		_definition = definition,
		_sorted = false,
	}, System)
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
}

local Pool = {}
Pool.__index = Pool

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
