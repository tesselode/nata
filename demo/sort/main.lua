local nata = require 'nata'

local drawSystem = {}

function drawSystem:draw()
	for i = #self.pool.groups.drawable.entities, 1, -1 do
		local e = self.pool.groups.drawable.entities[i]
		love.graphics.setColor(e.radius, e.radius, e.radius, 1)
		love.graphics.circle('fill', love.graphics.getWidth()/2, love.graphics.getHeight()/2, e.radius * 200)
	end
end

local pool = nata.new {
	groups = {
		drawable = {sort = true},
	},
	systems = {
		drawSystem,
	},
}

pool:queue({radius = .1})
pool:queue({radius = .25})
local toRemove = pool:queue({radius = .5})
pool:queue({radius = .75})
pool:queue({radius = 1})
pool:flush()

function love.keypressed(key)
	if key == 'escape' then love.event.quit() end
	if key == 'space' then
		toRemove.dead = true
		pool:remove(function(e) return e.dead end)
	end
end

function love.draw()
	pool:emit 'draw'
end
