local nata = require 'nata'

describe('a pool', function()
	local pool = nata.new {
		groups = {
			all = {},
			cool = {filter = 'cool'},
			uncool = {filter = '~cool'},
			big = {filter = function(e) return e.size > 20 end},
			coolAndBig = {filter = {'@cool', '@big'}},
			uncoolAndBig = {filter = {'@uncool', function(e) return e.size > 20 end}},
		},
	}

	local entityA = {size = 10, cool = true}
	local entityB = {size = 20, cool = true}
	local entityC = {size = 30, cool = true}
	local entityD = {size = 40}

	it('should queue up entities to be added', function()
		pool:queue(entityA)
		pool:queue(entityB)
		pool:queue(entityC)
		pool:queue(entityD)
		assert.are.same(pool 'all'.entities, {})
	end)

	it('should add entities in the order they were queued', function()
		pool:flush()
		assert.are.same(pool 'all'.entities, {entityA, entityB, entityC, entityD})
	end)

	it('should allow groups with a single string filter', function()
		assert.are.same(pool 'cool'.entities, {entityA, entityB, entityC})
	end)

	it('should allow negative filters', function()
		assert.are.same(pool 'uncool'.entities, {entityD})
	end)

	it('should allow function filters', function()
		assert.are.same(pool 'big'.entities, {entityC, entityD})
	end)

	it('should allow group filters', function()
		assert.are.same(pool 'coolAndBig'.entities, {entityC})
	end)

	it('should allow a combination of different kinds of filters', function()
		assert.are.same(pool 'uncoolAndBig'.entities, {entityD})
	end)
end)
