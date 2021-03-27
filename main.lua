-- https://github.com/Ulydev/push
local push = require "lib/push"s

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

function love.load()
  -- Use nearest neighbor filtering
  love.graphics.setDefaultFilter("nearest", "nearest")

  -- Load font
  font = love.graphics.newFont('resources/font.ttf', 8)
  -- Set Löve active font
  love.graphics.setFont(font)

  love.window.setTitle("Pong")

  -- Initialize virtual resolution
  push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
    fullscreen = false,
    resizable = false,
    vsync = true
  })
end

function love.keypressed(key)
  if key == 'escape' then
    love.event.quit()
  end
end

function love.update(dt)
end

function love.draw()
  -- Begin rendering at virtual resolution
  push:apply("start")
  -- Clear the screen
  love.graphics.clear(40/255, 45/255, 52/255, 1)

  love.graphics.printf("Hello Pong!", 0, VIRTUAL_HEIGHT / 2 - 4, VIRTUAL_WIDTH, "center")

  -- End rendering at virtual resolution
  push:apply("end")
end