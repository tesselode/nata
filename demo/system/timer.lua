local timer = require 'lib.timer'

local TimerSystem = {}

function TimerSystem:add()
	self.timer = timer.new()
end

function TimerSystem:update(dt)
	self.timer:update(dt)
end

return TimerSystem