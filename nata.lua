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
	for _, system in ipairs(self.systems) do
		for _, entity in ipairs(self._entities) do
			self:callSystemOn(system, entity, event, ...)
		end
	end
end

function Pool:add(entity, ...)
	self:callOn(entity, 'add', ...)
	table.insert(self._entities, entity)
	return entity
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

nata.oop = setmetatable({_f = {}}, {
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

function nata.new(systems)
	return setmetatable({
		_entities = {},
		systems = systems or {nata.oop},
	}, {__index = Pool})
end

return nata