local nata = require 'nata'

local PointSystem = {}

function PointSystem:add(groupName, entity)
	print('added entity (' .. tostring(entity) .. ') to group ' .. groupName)
end

function PointSystem:draw()
	for _, e in ipairs(self.pool.groups.point.entities) do
		love.graphics.setColor(1, 0, 0)
		love.graphics.circle('fill', e.x, e.y, 4, 64)
	end
end

local CircleSystem = {}

function CircleSystem:draw()
	for _, e in ipairs(self.pool.groups.circle.entities) do
		love.graphics.setColor(1, 1, 1)
		love.graphics.circle('fill', e.x, e.y, e.r, 64)
	end
end

local pool = nata.new {
	groups = {
		point = {
			filter = {'x', 'y'},
		},
		circle = {
			filter = {'x', 'y', 'r'},
		},
	},
	systems = {
		CircleSystem,
		PointSystem,
	}
}

pool:queue {x = 50, y = 100, r = 25}
pool:queue {x = 500, y = 100, r = 25}
pool:queue {x = 500, y = 200}

local shouldRemove = function(entity)
	return entity.r
end

function love.update(dt)
	pool:flush()
end

function love.keypressed(key)
	if key == 'escape' then love.event.quit() end
	if key == 'space' then pool:remove(shouldRemove) end
end

function love.draw()
	pool:emit 'draw'
end
