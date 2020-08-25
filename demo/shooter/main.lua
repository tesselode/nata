local nata = require 'nata'
local Player = require 'entity.player'

-- set up the entity pool
local pool = nata.new {
	--[[
		define groups. each group contains the entities
		that have the specified components.
	]]
	groups = {
		all = {},
		test = {'x'},
		physical = {filter = {'x', 'y', 'r'}},
		shoot = {filter = {'x', 'y', 'shoot'}},
		health = {filter = {'x', 'y', 'r', 'health', 'damage'}},
		score = {filter = {'score'}},
	},
	--[[
		define the systems that should be used. systems receive
		events in the order they're listed.
	]]
	systems = {
		nata.forward 'all',
		require 'system.spawn',
		require 'system.physical',
		require 'system.shoot',
		require 'system.health',
		require 'system.score',
	},
}

-- queue up the player entity
pool:queue(Player(400, 300))

function love.update(dt)
	pool:flush() -- add/remove queued entities
	pool:emit('update', dt) -- update systems and entities
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
