local nata = {}

local function removeByValue(t, v)
	for i = #t, 1, -1 do
		if t[i] == v then
			table.remove(t, i)
			break
		end
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
	else
		assert 'filter must be a table or function'
	end
end

local Pool = {}
Pool.__index = Pool

function Pool:_init(options)
	options = options or {}
	local groups = options.groups or {}
	self._queue = {}
	self._entities = {}
	self._groups = {}
	for groupName, groupOptions in pairs(groups) do
		self._groups[groupName] = {
			filter = groupOptions.filter,
			sort = groupOptions.sort,
			entities = {},
			hasEntity = {},
		}
	end
end

function Pool:queue(entity)
	table.insert(self._queue, entity)
end

function Pool:flush()
	for i = 1, #self._queue do
		local entity = self._queue[i]
		table.insert(self._entities, entity)
		for _, group in pairs(self._groups) do
			if filterEntity(entity, group.filter) then
				table.insert(group.entities, entity)
				group.hasEntity[entity] = true
			end
		end
		self._queue[i] = nil
	end
end

function Pool:remove(f)
	for i = #self._entities, 1, -1 do
		local entity = self._entities[i]
		if f(entity) then
			for _, group in ipairs(self._groups) do
				if group.hasEntity[entity] then
					removeByValue(group.entities, entity)
					group.hasEntity[entity] = nil
				end
			end
		end
	end
end

function nata.new(...)
	local pool = setmetatable({}, Pool)
	pool:_init(...)
	return pool
end

return nata
