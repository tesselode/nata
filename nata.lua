local nata = {}

local Pool = {}
Pool.__index = Pool

function Pool:callSystemOn(system, entity, event, ...)
	if not system.filter or system.filter(entity) then
		if system[event] then 
			system[event](entity, ...)
		end
	end
end

function Pool:callOn(entity, event, ...)
	for _, system in ipairs(self.systems) do
		self:callSystemOn(system, entity, event, ...)
	end
end

function Pool:call(event, ...)
	self._calling = true
	for _, system in ipairs(self.systems) do
		for _, entity in ipairs(self._entities) do
			self:callSystemOn(system, entity, event, ...)
		end
	end
	self._calling = false
end

function Pool:add(entity, ...)
	if self.allowQueueing and self._calling then
		table.insert(self._queue, {entity, {...}})
	else
		self:callOn(entity, 'add', ...)
		table.insert(self._entities, entity)
	end
	return entity
end

function Pool:addQueuedEntities()
	assert(not self._calling)
	for i, entity in ipairs(self._queue) do
		self:add(entity[1], unpack(entity[2]))
		self._queue[i] = nil
	end
end

function Pool:remove(f, ...)
	for i = #self._entities, 1, -1 do
		local entity = self._entities[i]
		if f(entity) then
			self:callOn(entity, 'remove', ...)
			table.remove(self._entities, i)
		end
	end
end

function Pool:get(f)
	local entities = {}
	for _, entity in ipairs(self._entities) do
		if not f or f(entity) then
			table.insert(entities, entity)
		end
	end
	return entities
end

function Pool:sort(f) table.sort(self._entities, f) end

function nata.oop()
	return setmetatable({_f = {}}, {
		__index = function(t, k)
			if k == '_f' or k == 'filter' then
				return rawget(t, k)
			else
				if not t._f[k] then
					t._f[k] = function(e, ...)
						if type(e[k]) == 'function' then
							e[k](e, ...)
						end
					end
				end
				return t._f[k]
			end
		end
	})
end

function nata.new(config)
	return setmetatable({
		systems = config and config.systems or {nata.oop()},
		allowQueueing = config and config.allowQueueing,
		_entities = {},
		_calling = false,
		_queue = {},
	}, {__index = Pool})
end

return nata