local nata = require 'nata'
local Player = require 'entity.player'

local pool = nata.new {
	groups = {
		all = {},
		physical = {filter = {'x', 'y', 'r'}},
		shoot = {filter = {'x', 'y', 'shoot'}},
	},
	systems = {
		nata.oop 'all',
		require 'system.physical',
		require 'system.shoot'
	},
}

pool:queue(Player(400, 300))

local function shouldRemove(entity)
	return entity.dead
end

function love.update(dt)
	pool:flush()
	pool:emit('update', dt)
	pool:remove(shouldRemove)
end

function love.keypressed(key)
	if key == 'escape' then love.event.quit() end
end

function love.draw()
	pool:emit 'draw'
end
