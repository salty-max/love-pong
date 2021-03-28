-- https://github.com/Ulydev/push
local push = require "lib/push"

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

function love.load()
  -- Use nearest neighbor filtering
  love.graphics.setDefaultFilter("nearest", "nearest")

  -- Load font
  defaultfont = love.graphics.newFont('resources/font.ttf', 8)
  scorefont = love.graphics.newFont('resources/font.ttf', 32)
  -- Set Löve active font
  love.graphics.setFont(defaultfont)

  love.window.setTitle("Pong")

  -- Initialize virtual resolution
  push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
    fullscreen = false,
    resizable = false,
    vsync = true
  })

  player1Score = 0
  player2Score = 0

  player1Y = 30
  player2Y = VIRTUAL_HEIGHT - 50
end

function love.keypressed(key)
  if key == 'escape' then
    love.event.quit()
  end
end

function love.update(dt)
  -- Player 1 movement
  if love.keyboard.isDown("z") then
    player1Y = player1Y + -PADDLE_SPEED * dt
  elseif love.keyboard.isDown("s") then
    player1Y = player1Y + PADDLE_SPEED * dt
  end

  -- Player 2 movement
  if love.keyboard.isDown("up") then
    player2Y = player2Y + -PADDLE_SPEED * dt
  elseif love.keyboard.isDown("down") then
    player2Y = player2Y + PADDLE_SPEED * dt
  end
end

function love.draw()
  -- Begin rendering at virtual resolution
  push:apply("start")
  -- Clear the screen
  love.graphics.clear(40/255, 45/255, 52/255, 1)

  -- Draw welcome text
  love.graphics.setFont(defaultfont)
  love.graphics.printf("Hello Pong!", 0, 20, VIRTUAL_WIDTH, "center")

  -- Draw score
  love.graphics.setFont(scorefont)
  love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
  love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)

  -- Render paddles
  love.graphics.rectangle("fill", 10, player1Y, 5, 20)
  love.graphics.rectangle("fill", VIRTUAL_WIDTH - 15, player2Y, 5, 20)
  -- Render ball
  love.graphics.rectangle("fill", VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

  -- End rendering at virtual resolution
  push:apply("end")
end