--- Entity management for Lua.
-- @module nata

local nata = {
	_VERSION = 'Nata v0.3.3',
	_DESCRIPTION = 'Entity management for Lua.',
	_URL = 'https://github.com/tesselode/nata',
	_LICENSE = [[
		MIT License

		Copyright (c) 2020 Andrew Minnich

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

-- gets the error level needed to make an error appear
-- in the user's code, not the library code
local function getUserErrorLevel()
	local source = debug.getinfo(1).source
	local level = 1
	while debug.getinfo(level).source == source do
		level = level + 1
	end
	--[[
		we return level - 1 here and not just level
		because the level was calculated one function
		deeper than the function that will actually
		use this value. if we produced an error *inside*
		this function, level would be correct, but
		for the function calling this function, level - 1
		is correct.
	]]
	return level - 1
end

-- gets the name of the function that the user called
-- that eventually caused an error
local function getUserCalledFunctionName()
	return debug.getinfo(getUserErrorLevel() - 1).name
end

local function checkCondition(condition, message)
	if condition then return end
	error(message, getUserErrorLevel())
end

-- changes a list of types into a human-readable phrase
-- i.e. string, table, number -> "string, table, or number"
local function getAllowedTypesText(...)
	local numberOfArguments = select('#', ...)
	if numberOfArguments >= 3 then
		local text = ''
		for i = 1, numberOfArguments - 1 do
			text = text .. string.format('%s, ', select(i, ...))
		end
		text = text .. string.format('or %s', select(numberOfArguments, ...))
		return text
	elseif numberOfArguments == 2 then
		return string.format('%s or %s', select(1, ...), select(2, ...))
	end
	return select(1, ...)
end

-- checks if an argument is of the correct type, and if not,
-- throws a "bad argument" error consistent with the ones
-- lua and love produce
local function checkArgument(argumentIndex, argument, ...)
	for i = 1, select('#', ...) do
		-- allow tables with the __call metamethod to be treated like functions
		if select(i, ...) == 'function' then
			if type(argument) == 'table' and getmetatable(argument).__call then
				return
			end
		end
		if type(argument) == select(i, ...) then return end
	end
	error(
		string.format(
			"bad argument #%i to '%s' (expected %s, got %s)",
			argumentIndex,
			getUserCalledFunctionName(),
			getAllowedTypesText(...),
			type(argument)
		),
		getUserErrorLevel()
	)
end

local function checkOptionalArgument(argumentIndex, argument, ...)
	if argument == nil then return end
	checkArgument(argumentIndex, argument, ...)
end

local function removeByValue(t, v)
	for i = #t, 1, -1 do
		if t[i] == v then table.remove(t, i) end
	end
end

--[[
	removes an item from a table by replacing it with the
	last item in the table (and removing the last item from
	the end of the table). this is faster than using table.remove
	because you only have to move one element. the downside is
	that removing items changes their order, but this is OK
	for most entity groups
]]
local function fastRemove(t, i)
	t[i] = t[#t]
	t[#t] = nil
end

local groupEntitiesMetatable = {
	__call = function(entities)
		return ipairs(entities)
	end,
}

local groupHasMetatable = {
	__call = function(has, entity)
		return has[entity]
	end,
}

--- Defines the behaviors of a system.
--
-- There's no constructor for SystemDefinitions. Rather, you simply
-- define a table with functions that correspond to events. These
-- events can be named anything you like. Below are the built-in events
-- that the world will automatically call.
-- @type SystemDefinition

--- Called when the world is first created.
-- @function SystemDefinition:init
-- @param ... additional arguments that were passed to `nata.new`.

--- Called when an entity is added to a group.
-- @function SystemDefinition:add
-- @string groupName the name of the group that the entity was added to
-- @tparam table e the entity that was added

--- Called when an entity is removed from a group.
-- @function SystemDefinition:remove
-- @string groupName the name of the group that the entity was removed from
-- @tparam table e the entity that was removed

--- Responds to events in a world.
--
-- Systems are not created directly. They're created by the @{World}
-- according to the @{SystemDefinition}s passed to `nata.new`.
-- Each system instance inherits all of the functions of its
-- @{SystemDefinition}.
-- @type System

--- The @{World} that this system is running on.
-- @tfield World world

--- Manages a subset of entities.
-- @type Group

--- A list of all the entities in the group.
-- @tfield table entities

--- A set of all the entities in the group.
-- @tfield table has
-- @usage
-- print(world.groups.physical.has[e]) -- prints "true" if the entity is in the "physical" group, or "nil" if not

--- Manages entities in a game world.
-- @type World
local World = {}
World.__index = World

function World:__call(groupName)
	checkArgument(1, groupName, 'string')
	checkCondition(self.groups[groupName], ("world does not have a group named '%s'"):format(groupName))
	return self.groups[groupName]
end

--- A dictionary of the @{Group}s in the world.
-- @tfield table groups

--- A field containing any data you want.
-- @field data

---

function World:_validateOptions(options)
	checkOptionalArgument(1, options, 'table')
	if not options then return end
	if options.groups then
		checkCondition(type(options.groups) == 'table', "groups must be a table")
		for groupName, groupOptions in pairs(options.groups) do
			checkCondition(type(groupOptions) == 'table',
				string.format("options for group '$s' must be a table", groupName))
			for k in pairs(groupOptions) do
				checkCondition(k == 'filter' or k == 'sort', string.format(
					"'%s' is not a valid property for group options. " ..
					"valid properties are 'filter' and 'sort'.\n\n" ..
					"if you meant to define components for this group, try " ..
					"groupName = {filter = {...}}",
					k
				))
			end
			local filter = groupOptions.filter
			if filter ~= nil then
				checkCondition(type(filter) == 'string' or type(filter) == 'table' or type(filter) == 'function',
					string.format("filter for group '%s' must be a string, table, or function", groupName))
			end
			local sort = groupOptions.sort
			if sort ~= nil then
				checkCondition(sort == true or type(sort) == 'function',
					string.format("sort for group '%s' must be a function or true", groupName))
			end
		end
	end
	if options.systems then
		checkCondition(type(options.systems) == 'table', "systems must be a table")
		for _, system in ipairs(options.systems) do
			checkCondition(type(system) == 'table', "all systems must be tables")
		end
	end
end

function World:_init(options, ...)
	self:_validateOptions(options)
	options = options or {
		groups = {all = {}},
		systems = {nata.forward 'all'},
	}
	self._eventQueue = {}
	self.groups = {}
	self._systems = {}
	self._events = {}
	self.data = options.data or {}
	local groups = options.groups or {}
	local systems = options.systems or {}
	for groupName, groupOptions in pairs(groups) do
		self.groups[groupName] = {
			_filter = groupOptions and groupOptions.filter,
			_sort = groupOptions and groupOptions.sort,
			_addQueue = {},
			_willRemove = {},
			entities = setmetatable({}, groupEntitiesMetatable),
			has = setmetatable({}, groupHasMetatable),
		}
	end
	for _, systemDefinition in ipairs(systems) do
		local system = setmetatable({
			world = self,
		}, {__index = systemDefinition})
		table.insert(self._systems, system)
	end
	self:emit('init', ...)
end

function World:_filterEntity(entity, filter)
	if type(filter) == 'function' then
		return filter(entity)
	end
	if type(filter) == 'string' then
		local negated = false
		-- if the component name starts with a "~", that means the entity
		-- must NOT have that component
		if filter:sub(1, 1) == '~' then
			negated = true
			filter = filter:sub(2, -1)
		end
		local meetsCondition
		-- if the component name starts with a "@", then it's actually the
		-- name of a group that the entity must belong in
		if filter:sub(1, 1) == '@' then
			local groupName = filter:sub(2, -1)
			local dependentGroup = self.groups[groupName]
			meetsCondition = self:_filterEntity(entity, dependentGroup._filter)
		-- otherwise, just check if the entity has the key
		else
			meetsCondition = entity[filter]
		end
		if negated then meetsCondition = not meetsCondition end
		return meetsCondition
	end
	if type(filter) == 'table' then
		for _, subfilter in ipairs(filter) do
			if not self:_filterEntity(entity, subfilter) then
				return false
			end
		end
	end
	return true
end

function World:queue(entity)
	for _, group in pairs(self.groups) do
		if self:_filterEntity(entity, group._filter) then
			if not group.has[entity] then
				table.insert(group._addQueue, entity)
			end
		elseif group.has[entity] then
			group._willRemove[entity] = true
		end
	end
	return entity
end

function World:remove(entity)
	for _, group in pairs(self.groups) do
		if group.has[entity] then
			group._willRemove[entity] = true
		end
	end
end

function World:flush()
	for groupName, group in pairs(self.groups) do
		-- remove entities
		for i = #group.entities, 1, -1 do
			local entity = group.entities[i]
			if group._willRemove[entity] then
				--[[
					if the group has a sort function, or it's in
					"preserve order" mode, then we should use the slower
					remove function that preserves the order of entities.
					otherwise, we can go fast
				]]
				if group._sort then
					table.remove(group.entities, i)
				else
					fastRemove(group.entities, i)
				end
				group.has[entity] = nil
				group._willRemove[entity] = nil
				table.insert(self._eventQueue, 'remove')
				table.insert(self._eventQueue, groupName)
				table.insert(self._eventQueue, entity)
			end
		end
		-- add entities
		if #group._addQueue > 0 then
			for i = 1, #group._addQueue do
				local entity = group._addQueue[i]
				table.insert(group.entities, entity)
				group.has[entity] = true
				table.insert(self._eventQueue, 'add')
				table.insert(self._eventQueue, groupName)
				table.insert(self._eventQueue, entity)
				group._addQueue[i] = nil
			end
			if type(group._sort) == 'function' then
				table.sort(group.entities, group._sort)
			end
		end
	end
	-- emit add/remove events
	for i = 1, #self._eventQueue, 3 do
		local event = self._eventQueue[i]
		local groupName = self._eventQueue[i + 1]
		local entity = self._eventQueue[i + 2]
		self:emit(event, groupName, entity)
		self._eventQueue[i] = nil
		self._eventQueue[i + 1] = nil
		self._eventQueue[i + 2] = nil
	end
end

function World:entities()
	checkCondition(self.groups.all, "the world does not have a group named 'all'\n\n"
		.. "If you create a world without specifying any groups, it will have "
		.. "a group called 'all' by default. This function iterates over that group. "
		.. "Since you have specified different groups, you'll probably want to use "
		.. "world(groupName).entities() to iterate over the entities in a specific group.")
	return self 'all'.entities()
end

function World:has(entity)
	checkCondition(self.groups.all, "the world does not have a group named 'all'\n\n"
		.. "If you create a world without specifying any groups, it will have "
		.. "a group called 'all' by default. This function checks for an entity in "
		.. "that group. Since you have specified different groups, you'll probably want "
		.. "to use world(groupName).has(entity) to check if a specific group has an entity.")
	return self 'all'.has(entity)
end

--- Registers a function to be called when an event is emitted.
-- @string event the event to listen for
-- @tparam function f the function to call
-- @treturn function the function that was registered
function World:on(event, f)
	checkCondition(event ~= nil, "event cannot be nil")
	checkArgument(2, f, 'function')
	self._events[event] = self._events[event] or {}
	table.insert(self._events[event], f)
	return f
end

--- Unregisters a function from an event.
-- @string event the event to unregister the function from
-- @tparam function f the function to unregister
function World:off(event, f)
	checkCondition(event ~= nil, "event cannot be nil")
	checkArgument(2, f, 'function')
	if self._events[event] then
		removeByValue(self._events[event], f)
	end
end

--- Emits an event. The `system[event]` function will be called
-- for each system that has it, and functions registered
-- to the event will be called as well.
-- @string event the event to emit
-- @param ... additional arguments to pass to the functions that are called
function World:emit(event, ...)
	checkCondition(event ~= nil, "event cannot be nil")
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

---
-- @section end

local function validateForwardOptions(options)
	checkOptionalArgument(1, options, 'table')
	if not options then return end
	if options.include then
		checkCondition(type(options.include) == 'table', "include must be a table")
	end
	if options.exclude then
		checkCondition(type(options.exclude) == 'table', "exclude must be a table")
	end
end

--- Defines the behavior of a forward system.
-- @type ForwardOptions
-- @see nata.forward

--- A list of events to forward to entities. If not defined,
-- the system will forward all events to entities (except
-- for the ones in the exclude list).
-- @tfield[opt] table include

--- A list of events *not* to forward to entities.
-- @tfield[opt] table exclude

---
-- @section end

--- Creates a new forward system definition.
-- A forward system, upon receiving an event, will call
-- the function of the same name on each entity it monitors
-- (if it exists). This facilitates a more traditional, OOP-style
-- entity management, where you loop over a table of entities and
-- call update and draw functions on them.
-- @tparam string group the name of the group of entities to forward
-- events to
-- @tparam[opt] ForwardOptions options how to set up the forward system
-- @treturn SystemDefinition the new forward system definition
function nata.forward(group, options)
	checkArgument(1, group, 'string')
	validateForwardOptions(options)
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
				checkCondition(self.world.groups[group], ("a forward system was created for the group '%s', "
					.. "but the world does not have a group called '%s'"):format(group, group))
				local shouldCallEvent = true
				if include and not include[event] then shouldCallEvent = false end
				if exclude and exclude[event] then shouldCallEvent = false end
				if shouldCallEvent then
					local entities = self.world.groups[group].entities
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

--- Defines the filter and sort function for a @{Group}.
-- @type GroupOptions

--- The filter that defines which entities are added to this group.
-- Can be either:
--
-- - A list of required keys
-- - A function that takes the entity as the first argument
-- and returns true if the entity should be added to the group
-- @tfield[opt] table|function filter

--- Specifies how entities in this group will be sorted.
-- Can be:
--
-- - `nil` - entities will not be sorted, and they will not necessarily
-- retain their order when entities are removed. This allows for faster
-- entity removal, so it's recommended for groups whose entity order
-- doesn't matter.
-- - `true` - entities will remain in the order they were added in
-- - a function - entities will be sorted according to the specified function.
-- This function has the same requirements as the function argument to
-- Lua's built-in `table.sort`.
-- @tfield[opt] true|function sort

--- Defines the groups and systems for a @{World}.
-- @type WorldOptions

--- A dictionary of groups for the world to have.
-- Each key is the name of the group, and each value
-- should be a @{GroupOptions} table.
-- @tfield[opt={}] table groups

--- A list of @{SystemDefinition}s for the world to use.
-- @tfield[opt={nata.forward()}] table systems

--- An initial value to set @{World.data} to.
-- @field[opt={}] data

---
-- @section end

--- Creates a new @{World}.
-- @tparam[opt] WorldOptions options how to set up the world
-- @param[opt] ... additional arguments to pass to the world's init event
-- @treturn World the new world
function nata.new(options, ...)
	local world = setmetatable({}, World)
	world:_init(options, ...)
	return world
end

return nata
