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
		require 'system.spawn',
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

	love.graphics.setColor(1, 1, 1)
	love.graphics.print('FPS: ' .. love.timer.getFPS(), 0, 0)
	love.graphics.print('Memory: ' .. math.floor(collectgarbage 'count') .. ' kb', 0, 16)
	love.graphics.print('Entities: ' .. #pool.groups.all.entities, 0, 32)
end
