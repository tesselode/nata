nata = require 'nata'

uptime = 0

startPositionSystem = {
    add = function(e)
        e.x = 400
        e.y = 300
    end
}

horizontalMovementSystem = {
    filter = function(e) return e.xspeed end,
    update = function(e, dt)
        e.x = 400 + 200 * math.sin(uptime * e.xspeed * .5)
    end
}

verticalMovementSystem = {
    filter = function(e) return e.yspeed end,
    update = function(e, dt)
        e.y = 300 + 200 * math.sin(uptime * e.yspeed * .5)
    end
}

drawSystem = {
    filter = function(e) return e.color end,
    draw = function(e)
        love.graphics.setColor(e.color)
        love.graphics.circle('fill', e.x, e.y, e.radius, 64)
    end
}

spawnSystem = {
    filter = function(e) return e.spawn end,
    update = function(e, dt)
        if love.math.random(100) == 1 then
            pool:add {z = love.math.random(), radius = love.math.random(64), xspeed = love.math.random(10), color = {love.math.random(255), love.math.random(255), love.math.random(255)}}
        end
    end
}

pool = nata.new {
    systems = {
        spawnSystem,
        startPositionSystem,
        horizontalMovementSystem,
        verticalMovementSystem,
        nata.oop(),
        drawSystem,
    },
    allowQueueing = true,
}

pool:add {z = 1, radius = 32, xspeed = 1, color = {150, 150, 150}, spawn = true}
pool:add {z = 2, radius = 32, xspeed = 2, color = {200, 100, 150}}
pool:add {z = 3, radius = 32, xspeed = 3, yspeed = .1, color = {100, 200, 150}}
pool:add {z = 4, radius = 32, xspeed = 4, yspeed = .2, color = {100, 150, 200}}
pool:add {z = 5, radius = 32, xspeed = 5, color = {150, 200, 100},
    update = function(e, dt)
        e.radius = 32 + 16 * math.sin(uptime)
    end
}

-- performance stats
updateTime = 0
updates = 0
drawTime = 0
draws = 0

function love.update(dt)
    uptime = uptime + dt
    local t = love.timer.getTime()
    pool:call('update', dt)
    updateTime = updateTime + (love.timer.getTime() - t)
    updates = updates + 1
end

function love.keypressed(key)
    if key == 'return' then
        pool:addQueuedEntities()
    end
end

function love.draw()
    local t = love.timer.getTime()
    pool:sort(function(a, b) return a.z > b.z end)
    pool:call 'draw'
    drawTime = drawTime + (love.timer.getTime() - t)
    draws = draws + 1

    love.graphics.setColor(255, 255, 255)
    love.graphics.print('Average update time (us): ' .. (math.floor((updateTime/updates)*1000000)), 0, 0)
    love.graphics.print('Average draw time (us): ' .. (math.floor((drawTime/draws)*1000000)), 0, 16)
    love.graphics.print('Memory usage (kb): ' .. math.floor(collectgarbage 'count'), 0, 32)
    love.graphics.print('Queued entities: ' .. #pool._queue, 0, 48)
end