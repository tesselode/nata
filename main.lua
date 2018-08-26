local nata = require 'nata'

local moveSystem = {
	filter = {'x', 'y', 'vx', 'vy'},
	process = {
		update = function(self, dt)
			for _, entity in ipairs(self.entities) do
				entity.x = entity.x + entity.vx * dt
				entity.y = entity.y + entity.vy * dt
			end
		end,
	}
}

local drawSystem = {
	filter = {'x', 'y', 'w', 'h', 'color'},
	sort = function(a, b)
		return a.w * a.h > b.w * b.h
	end,
	on = {
		add = function(self, entity)
			print('added ' .. tostring(entity) .. ' to draw system')
		end,
	},
	process = {
		draw = function(self)
			for _, entity in ipairs(self.entities) do
				love.graphics.setColor(entity.color)
				love.graphics.rectangle('fill', entity.x, entity.y, entity.w, entity.h)
			end
		end,
	},
}

local entities = nata.new()
	:addSystem(moveSystem)
	:addSystem(drawSystem)

for _ = 1, 25 do
	entities:queue {
		x = love.math.random(love.graphics.getWidth()),
		y = love.math.random(love.graphics.getHeight()),
		w = love.math.random(100),
		h = love.math.random(100),
		color = {
			love.math.random(),
			love.math.random(),
			love.math.random(),
		},
		vx = love.math.random(-50, 50),
		vy = love.math.random(-50, 50),
	}
end

function love.update(dt)
	entities:flush()
	entities:process('update', dt)
end

function love.draw()
	entities:process('draw')
end
