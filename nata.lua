local nata = {}

local Pool = {}
Pool.__index = Pool

function Pool:callSystemOn(system, entity, event, ...)
	if system[event] and (not system.filter or system.filter(entity)) then
		system[event](entity, ...)
	end
end

function Pool:callSystem(system, event, ...)
	for _, entity in ipairs(self._entities) do
		self:callSystemOn(system, entity, event, ...)
	end
end

function Pool:callOn(entity, event, ...)
	for _, system in ipairs(self.systems) do
		self:callSystemOn(system, entity, event, ...)
	end
end

function Pool:call(event, ...)
	for _, system in ipairs(self.systems) do
		self:callSystem(system, event, ...)
	end
end

function Pool:queue(entity, ...)
	table.insert(self._queue, {entity, {...}})
	return entity
end

function Pool:flush()
	for i, v in ipairs(self._queue) do
		local entity, args = v[1], v[2]
		self:callOn(entity, 'add', unpack(args))
		table.insert(self._entities, entity)
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
		_queue = {},
	}, {__index = Pool})
end

return nata