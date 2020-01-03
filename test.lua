local nata = require 'nata'

describe('nata.new', function()
	it('returns a pool', function()
		assert.is.table(nata.new())
	end)

	it('only accepts tables as the first argument', function()
		assert.has_error(function()
			nata.new(2)
		end)
		assert.has_error(function()
			nata.new 'asdf'
		end)
	end)

	it('does not require an options argument', function()
		assert.has_no.errors(function() nata.new() end)
	end)
end)

describe('The Pool class', function()
	local entity1 = {}
	local entity2 = {}
	local entity3 = {}

	local pool = nata.new()

	it('adds queued entities in order', function()
		pool:queue(entity1)
		pool:queue(entity2)
		pool:queue(entity3)
		pool:flush()
		assert.are.equals(pool.entities[1], entity1)
		assert.are.equals(pool.entities[2], entity2)
		assert.are.equals(pool.entities[3], entity3)
	end)

	it('removes entities according to a user-specified condition', function()
		entity2.dead = true
		pool:remove(function(e) return e.dead end)
		assert.are.equals(pool.entities[1], entity1)
		assert.are.equals(pool.entities[2], entity3)
	end)

	it('keeps a set of entities', function()
		assert.is_true(pool.hasEntity[entity1])
		assert.is_true(pool.hasEntity[entity3])
		assert.is_nil(pool.hasEntity[entity2])
	end)
end)
