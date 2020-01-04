local nata = require 'nata'

describe('nata.new', function()
	it('returns a pool', function()
		assert.is.table(nata.new())
	end)

	it('only accepts tables as the first argument', function()
		assert.has_error(function()
			nata.new(2)
		end, "bad argument #1 to 'new' (expected table, got number)")
		assert.has_error(function()
			nata.new 'asdf'
		end, "bad argument #1 to 'new' (expected table, got string)")
	end)
end)

describe('a pool', function()
	local systemInitSpy = spy.new(function() end)
	local systemAddSpy = spy.new(function() end)
	local systemRemoveSpy = spy.new(function() end)
	local systemAddToGroupSpy = spy.new(function() end)
	local systemRemoveFromGroupSpy = spy.new(function() end)

	local testSystem = {}

	function testSystem:init()
		systemInitSpy()
	end

	function testSystem:add(...)
		systemAddSpy(...)
	end

	function testSystem:remove(...)
		systemRemoveSpy(...)
	end

	function testSystem:addToGroup(...)
		systemAddToGroupSpy(...)
	end

	function testSystem:removeFromGroup(...)
		systemRemoveFromGroupSpy(...)
	end

	local entity1 = {coolness = 0, x = 50, y = 100, z = 10}
	local entity2 = {coolness = 100, z = -10}
	local entity3 = {coolness = 10, z = 0}

	local pool = nata.new {
		groups = {
			all = {},
			sorted = {
				sort = function(a, b) return a.z < b.z end
			},
			cool = {
				filter = function(e) return e.coolness >= 10 end
			},
			position = {filter = {'x', 'y'}},
		},
		systems = {
			testSystem,
		}
	}

	-- adding entities
	it('queues entities to be added', function()
		pool:queue(entity1)
		pool:queue(entity2)
		pool:queue(entity3)
		assert.are.same(pool.entities, {})
	end)

	it('adds queued entities in order', function()
		pool:flush()
		assert.are.same(pool.entities, {entity1, entity2, entity3})
	end)

	it('removes entities from the queue after adding them', function()
		assert.are.same(pool._queue, {})
	end)

	it('keeps a set of entities', function()
		assert.is_true(pool.hasEntity[entity1])
		assert.is_true(pool.hasEntity[entity2])
		assert.is_true(pool.hasEntity[entity3])
	end)

	-- groups
	it('allows adding groups without filters', function()
		assert.are.same(pool.groups.all.entities, pool.entities)
	end)

	it('allows adding groups with required keys', function()
		assert.are.same(pool.groups.position.entities, {entity1})
	end)

	it('allows adding groups with filter functions', function()
		assert.are.same(pool.groups.cool.entities, {entity2, entity3})
	end)

	it('allows sorting groups', function()
		assert.are.same(pool.groups.sorted.entities, {entity2, entity3, entity1})
	end)

	-- systems
	it('calls the init event on systems', function()
		assert.spy(systemInitSpy).was_called()
	end)

	it('calls add events on systems', function()
		assert.spy(systemAddSpy).was_called_with(entity1)
		assert.spy(systemAddSpy).was_called_with(entity2)
		assert.spy(systemAddSpy).was_called_with(entity3)
	end)

	it('calls addToGroup events on systems', function()
		assert.spy(systemAddToGroupSpy).was_called_with('cool', entity2)
		assert.spy(systemAddToGroupSpy).was_called_with('cool', entity3)
		assert.spy(systemAddToGroupSpy).was_not_called_with('cool', entity1)
		assert.spy(systemAddToGroupSpy).was_not_called_with('position', entity2)
	end)

	-- removing entities
	it('removes entities according to a user-specified condition', function()
		entity2.dead = true
		pool:remove(function(e) return e.dead end)
		assert.are.same(pool.entities, {entity1, entity3})
	end)

	it('removes entities from the set', function()
		assert.is_nil(pool.hasEntity[entity2])
	end)

	it('removes entities from groups as well as the main pool', function()
		assert.are.same(pool.groups.cool.entities, {entity3})
	end)

	it('calls remove events on systems', function()
		assert.spy(systemRemoveSpy).was_not_called_with(entity1)
		assert.spy(systemRemoveSpy).was_called_with(entity2)
	end)

	it('calls removeFromGroup events on systems', function()
		assert.spy(systemRemoveFromGroupSpy).was_called_with('cool', entity2)
		assert.spy(systemRemoveFromGroupSpy).was_not_called_with('cool', entity3)
	end)

	-- updating entities
	it('allows re-queueing entities to check for changes', function()
		entity1.coolness = 1000
		pool:queue(entity1)
		pool:flush()
		assert.are.same(pool.entities, {entity1, entity3})
		assert.are.same(pool.groups.cool.entities, {entity3, entity1})
		assert.spy(systemAddToGroupSpy).was_called_with('cool', entity1)
	end)

	-- event listeners
	local s = spy.new(function() end)
	local f = pool:on('test', function(...) s(...) end)

	it('allows registering functions to events', function()
		pool:emit('test', 'hi!', 1, 2, 3)
		assert.spy(s).was_called_with('hi!', 1, 2, 3)
	end)

	it('allows unregistering functions from events', function()
		pool:off('test', f)
		pool:emit 'test'
		assert.spy(s).was_called(1)
	end)
end)

describe('nata.oop', function()
	it('returns an OOP system', function()
		assert.is_table(nata.oop())
	end)

	it('only accepts tables as the first argument', function()
		assert.has_error(function()
			nata.oop(2)
		end, "bad argument #1 to 'oop' (expected table, got number)")
		assert.has_error(function()
			nata.oop 'asdf'
		end, "bad argument #1 to 'oop' (expected table, got string)")
	end)
end)

describe('an OOP system', function()
	it('calls functions on the entities themselves', function()
		local entityTestSpy = spy.new(function() end)
		local pool = nata.new {
			systems = {
				nata.oop(),
			},
		}
		pool:queue {
			test = function(self, ...) entityTestSpy(...) end,
		}
		pool:flush()
		pool:emit('test', 'asdf', 1, 2, 3)
		assert.spy(entityTestSpy).was_called_with('asdf', 1, 2, 3)
	end)

	it('is included by default in pools with no systems specified', function()
		local entityTestSpy = spy.new(function() end)
		local pool = nata.new()
		pool:queue {
			test = function(self, ...) entityTestSpy(...) end,
		}
		pool:flush()
		pool:emit('test', 'asdf', 1, 2, 3)
		assert.spy(entityTestSpy).was_called_with('asdf', 1, 2, 3)
	end)

	it('allows setting an explicit whitelist for events', function()
		local entityTestSpy = spy.new(function() end)
		local entityTest2Spy = spy.new(function() end)
		local entityTest3Spy = spy.new(function() end)
		local pool = nata.new {
			systems = {
				nata.oop {include = {'test'}},
			},
		}
		pool:queue {
			test = function(self, ...) entityTestSpy(...) end,
			test2 = function(self, ...) entityTest2Spy(...) end,
			test3 = function(self, ...) entityTest3Spy(...) end,
		}
		pool:flush()
		pool:emit('test', 'asdf', 1, 2, 3)
		pool:emit('test2', 'asdf', 1, 2, 3)
		pool:emit('test3', 'asdf', 1, 2, 3)
		assert.spy(entityTestSpy).was_called_with('asdf', 1, 2, 3)
		assert.spy(entityTest2Spy).was_not_called()
		assert.spy(entityTest3Spy).was_not_called()
	end)

	it('allows setting a blacklist for events', function()
		local entityTestSpy = spy.new(function() end)
		local entityTest2Spy = spy.new(function() end)
		local entityTest3Spy = spy.new(function() end)
		local pool = nata.new {
			systems = {
				nata.oop {exclude = {'test2', 'test3'}},
			},
		}
		pool:queue {
			test = function(self, ...) entityTestSpy(...) end,
			test2 = function(self, ...) entityTest2Spy(...) end,
			test3 = function(self, ...) entityTest3Spy(...) end,
		}
		pool:flush()
		pool:emit('test', 'asdf', 1, 2, 3)
		pool:emit('test2', 'asdf', 1, 2, 3)
		pool:emit('test3', 'asdf', 1, 2, 3)
		assert.spy(entityTestSpy).was_called_with('asdf', 1, 2, 3)
		assert.spy(entityTest2Spy).was_not_called()
		assert.spy(entityTest3Spy).was_not_called()
	end)

	it('allows restricting events to a certain group', function()
		local entity1Spy = spy.new(function() end)
		local entity2Spy = spy.new(function() end)
		local entity3Spy = spy.new(function() end)
		local entity1 = {
			coolness = 0,
			test = function(self, ...) entity1Spy(...) end,
		}
		local entity2 = {
			coolness = 10,
			test = function(self, ...) entity2Spy(...) end,
		}
		local entity3 = {
			coolness = 100,
			test = function(self, ...) entity3Spy(...) end,
		}
		local pool = nata.new {
			groups = {
				cool = {
					filter = function(e) return e.coolness >= 10 end,
				}
			},
			systems = {
				nata.oop {group = 'cool'},
			}
		}
		pool:queue(entity1)
		pool:queue(entity2)
		pool:queue(entity3)
		pool:flush()
		pool:emit('test', 'asdf', 1, 2, 3)
		assert.spy(entity1Spy).was_not_called()
		assert.spy(entity2Spy).was_called_with('asdf', 1, 2, 3)
		assert.spy(entity3Spy).was_called_with('asdf', 1, 2, 3)
	end)
end)
