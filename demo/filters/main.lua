local nata = require 'nata'

local pool = nata.new {
	groups = {
		physical = {filter = {'x', 'y', 'w', 'h'}},
		moving = {filter = {'@physical', 'vx', 'vy'}},
		stationary = {filter = {'@physical', '~vx', '~vy'}},
		ghost = {filter = {'~@physical', 'x', 'y'}},
	}
}
pool:on('add', function(groupName, e) print(groupName, e) end)

pool:queue {
	x = 50,
	y = 50,
	--w = 50,
	h = 50,
	--vx = 50,
	--vy = 50,
}
pool:flush()
