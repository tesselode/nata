local nata = require 'nata'

local drawSystem = {
	sort = function(a, b) return a.r > b.r end,

	filter = function(e) return e.r and e.visible end,

	draw = function(e)
		love.graphics.setColor(e.color.r, e.color.g, e.color.b)
		love.graphics.circle('fill', 400, 300, e.r, 64)
	end
}

local circles = nata.new {
	drawSystem,
}
for _ = 1, 3 do
	circles:queue {
		r = love.math.random(10, 250),
		visible = love.math.random() > .5,
		color = {
			r = love.math.random(),
			g = love.math.random(),
			b = love.math.random(),
		}
	}
end
circles:flush()

function love.keypressed(key)
	if key == 'escape' then love.event.quit() end
	if key == 'space' then
		circles:queue {
			r = love.math.random(10, 250),
			visible = love.math.random() > .5,
			color = {
				r = love.math.random(),
				g = love.math.random(),
				b = love.math.random(),
			}
		}
		circles:flush()
	end
end

function love.draw()
	circles:call 'draw'
end
