local nata = {}

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

function Pool:_init(options)
	options = options or {}
	local groups = options.groups or {entities = {}}
	local systems = options.systems or {nata.oop 'entities'}
	self._queue = {}
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
	self:emit 'init'
end

function Pool:queue(entity)
	table.insert(self._queue, entity)
	return entity
end

function Pool:flush()
	for i = 1, #self._queue do
		local entity = self._queue[i]
		for groupName, group in pairs(self.groups) do
			if filterEntity(entity, group.filter) then
				table.insert(group.entities, entity)
				if group.sort then
					table.sort(group.entities, group.sort)
				end
				group.hasEntity[entity] = true
				self:emit('add', groupName, entity)
			end
		end
		self._queue[i] = nil
	end
end

function Pool:remove(f)
	for groupName, group in pairs(self.groups) do
		for i = #group.entities, 1, -1 do
			local entity = group.entities[i]
			if f(entity) then
				table.remove(group.entities, i)
				group.hasEntity[entity] = nil
				self:emit('remove', groupName, entity)
			end
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

function nata.oop(groupName)
	return setmetatable({_cache = {}}, {
		__index = function(t, event)
			t._cache[event] = t._cache[event] or function(self, ...)
				for _, entity in ipairs(self.pool.groups[groupName].entities) do
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
