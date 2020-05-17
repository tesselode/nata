local nata = require 'nata'

describe('a forward system', function()
	it('calls functions on the entities themselves', function()
		local entityTestSpy = spy.new(function() end)
		local pool = nata.new {
			systems = {
				nata.forward(),
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
				nata.forward {include = {'test'}},
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
				nata.forward {exclude = {'test2', 'test3'}},
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
				nata.forward {group = 'cool'},
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
