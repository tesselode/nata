local nata = require 'nata'
local Player = require 'entity.player'

-- set up the entity pool
local pool = nata.new {
	--[[
		define groups. each group contains the entities
		that have the specified components.
	]]
	groups = {
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
		nata.oop(),
		require 'system.spawn',
		require 'system.physical',
		require 'system.shoot',
		require 'system.health',
		require 'system.score',
	},
}

pool:on('addToGroup', function(group, entity)
	if entity.isPlayer then
		print('add', group, entity)
	end
end)
pool:on('removeFromGroup', function(group, entity)
	if entity.isPlayer then
		print('remove', group, entity)
	end
end)

-- queue up the player entity
local player = pool:queue(Player(400, 300))

-- this function defines the condition for removing entities
local function shouldRemove(entity)
	return entity.dead
end

function love.update(dt)
	pool:flush() -- add entities that have been queued up
	pool:emit('update', dt) -- update systems and entities
	pool:remove(shouldRemove) -- remove entities that are marked as "dead"
end

function love.keypressed(key)
	if key == 'escape' then love.event.quit() end
	if key == 'space' then
		if player.shoot then
			player.shootDisabled = player.shoot
			player.shoot = nil
		else
			player.shoot = player.shootDisabled
			player.shootDisabled = nil
		end
		pool:queue(player)
	end
end

function love.draw()
	pool:emit 'draw'

	love.graphics.setColor(1, 1, 1)
	love.graphics.print('FPS: ' .. love.timer.getFPS(), 0, 0)
	love.graphics.print('Memory: ' .. math.floor(collectgarbage 'count') .. ' kb', 0, 16)
	love.graphics.print('Entities: ' .. #pool.entities, 0, 32)
end
