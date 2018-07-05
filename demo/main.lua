local game = require 'state.game'
local gamestate = require 'lib.gamestate'
local input = require 'input'

function love.load()
	gamestate.registerEvents {'update', 'draw'}
	gamestate.switch(game)
end

function love.update(dt)
	input:update()
end

function love.keypressed(key)
	if key == 'escape' then
		love.event.quit()
	end
end