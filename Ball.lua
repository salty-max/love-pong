--[[
  CS50G Project 0
  Pong Remake
  Author: Maxime Blanc
  -- https://github.com/salty-max
  -- BALL CLASS --
--]]
Ball = Class {}

function Ball:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height

    -- Ball velocity
    -- randomized at each play state
    self.dx = math.random(2) == 1 and 100 or -100
    self.dy = math.random(-50, 50) * 1.5
end

--[[
  Places the ball in the middle of the screen
  with an initial random velocity on both axes
--]]
function Ball:reset()
    self.x = VIRTUAL_WIDTH / 2 - 2
    self.y = VIRTUAL_HEIGHT / 2 - 2
    self.dx = math.random(2) == 1 and 100 or -100
    self.dy = math.random(-50, 50) * 1.5
end

--[[
    AABB Collision Detection between ball and paddles
--]]
function Ball:collides(paddle)
    -- First, check to see if the left edge of either is farther to the right
    -- than the right edge od the other
    if self.x > paddle.x + paddle.width or self.x + self.width < paddle.x then
        return false
    end
    -- Then check to see if the bottom edge of either is higher
    -- than the top edge of the other
    if self.y > paddle.y + paddle.height or self.y + self.height < paddle.y then
        return false
    end

    -- If conditions above aren't true, ball and paddle are overlapping
    return true
end

--[[
  Applies velocity to position, scaled by deltaTime
--]]
function Ball:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

function Ball:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end
