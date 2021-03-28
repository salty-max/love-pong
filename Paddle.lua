--[[
  CS50G Project 0
  Pong Remake
  Author: Maxime Blanc
  -- https://github.com/salty-max
  -- PADDLE CLASS --
]]

Paddle = Class{}

function Paddle:init(x, y, width, height)
  self.x = x
  self.y = y
  self.width = width
  self.height = height
  self.dy = 0
end

function Paddle:update(dt)
  -- Applies velocity to y position, scaled by deltaTime
  if self.dy < 0 then
    -- If dy is negative, go up
    -- Uses math.max to ensure that the paddle doesn't go above the upper screen limit
    self.y = math.max(0, self.y + self.dy * dt)
  else
    -- If dy is positive, go down
    -- Uses math.min to ensure that the paddle doesn't go below the lower screen limit
    self.y = math.min(VIRTUAL_HEIGHT - self.height, self.y + self.dy * dt)
  end
end

function Paddle:render()
  love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end