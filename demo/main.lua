local constant = require 'constant'
local game = require 'state.game'
local gamestate = require 'lib.gamestate'
local input = require 'input'
local push = require 'lib.push'

push:setupScreen(constant.screenSize.x, constant.screenSize.y,
	1280, 720, {canvas = false})

function love.load()
	gamestate.registerEvents {'update', 'keypressed'}
	gamestate.switch(game)
end

function love.update(dt)
	input:update()
end

function love.keypressed(key)
	if key == 'escape' then love.event.quit() end
end

function love.draw()
	push:start()
	gamestate.draw()
	push:finish()
end
