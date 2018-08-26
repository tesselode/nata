local constant = require 'constant'
local nata = require 'lib.nata'
local Player = require 'entity.player'

local function removeCondition(entity)
	return entity.dead
end

local game = {}

function game:enter()
	self.entities = nata.new {
		nata.oop,
		require 'system.move',
		require 'system.draw',
	}
	self.entities:queue(Player(constant.screenSize / 2))
end

function game:update(dt)
	self.entities:flush()
	self.entities:process('update', dt)
	self.entities:remove(removeCondition)
end

function game:draw()
	self.entities:process('draw')
end

return game
