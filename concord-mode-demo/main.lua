local nata = require 'nata'
local Position = require 'component.position'
local Size = require 'component.size'
local Velocity = require 'component.velocity'

local pool = nata.new {
	groups = {
		physical = {filter = {Position, Size}},
		velocity = {filter = {Position, Velocity}},
	},
	systems = {
		require 'system.velocity',
		require 'system.draw-physical',
	},
}

local entity = pool:queue()
	:add(Position, 50, 50)
	:add(Size, 50, 100)
	:add(Velocity, 200, 100)

function love.update(dt)
	pool:flush()
	pool:emit('update', dt)
end

function love.keypressed(key)
	if key == 'space' then
		entity:remove(Velocity)
	end
end

function love.draw()
	pool:emit 'draw'
end
