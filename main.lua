--[[
  CS50G Project 0
  Pong remake
  Author: Maxime Blanc
  -- https://github.com/salty-max
  -- MAIN --
]]

-- Library to set virtual resolution
-- https://github.com/Ulydev/push
local push = require 'lib/push'

-- Library to implement a class system in lua
-- https://github.com/vrld/hump/blob/master/class.lua
Class = require 'class'

require 'Paddle'
require 'Ball'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

function love.load()
  -- Use nearest neighbor filtering
  love.graphics.setDefaultFilter('nearest', 'nearest')

  -- Seed the RNG so that calls to random are always random
  -- Use the current unix time to get a different number at each startup
  math.randomseed(os.time())

  -- Load fonts
  defaultfont = love.graphics.newFont('resources/font.ttf', 8)
  scorefont = love.graphics.newFont('resources/font.ttf', 32)
  -- Set Löve active font
  love.graphics.setFont(defaultfont)

  love.window.setTitle('Pong')

  -- Initialize virtual resolution
  push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
    fullscreen = false,
    resizable = false,
    vsync = true
  })

  -- Initialize players paddle
  player1 = Paddle(10, 30, 5, 20)
  player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

  -- Place a ball in the middle of the screen
  ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

  player1Score = 0
  player2Score = 0

  -- Default game state
  gameState = 'start'
end

function love.update(dt)
  -- Player 1 movement
  if love.keyboard.isDown('z') then
    -- Add negative speed to the paddle
    player1.dy = -PADDLE_SPEED
  elseif love.keyboard.isDown('s') then
    -- Add positive speed to the paddle
    player1.dy = PADDLE_SPEED
  else
    player1.dy = 0
  end

  -- Player 2 movement
  -- Same behavior than player 1
  if love.keyboard.isDown('up') then
    player2.dy = -PADDLE_SPEED
  elseif love.keyboard.isDown('down') then
    player2.dy = PADDLE_SPEED
  else
    player2.dy = 0
  end

  -- Update ball velocity only when in play state
  -- scaled by dt so movement is framerate-independent
  if gameState == 'play' then
    ball:update(dt)
  end

  player1:update(dt)
  player2:update(dt)
end

function love.keypressed(key)
  if key == 'escape' then
    love.event.quit()
  elseif key == 'enter' or key == 'return' then
    if gameState == 'start' then
      gameState = 'play'
    else
      gameState = 'start'

      -- Reset ball position and give it a new random starting velocity
      ball:reset()
    end
  end
end


function love.draw()
  -- Begin rendering at virtual resolution
  push:apply('start')
  -- Clear the screen and apply background
  love.graphics.clear(40/255, 45/255, 52/255, 1)

  -- Draw welcome text
  love.graphics.setFont(defaultfont)
  love.graphics.printf('Hello Pong!', 0, 20, VIRTUAL_WIDTH, 'center')

  -- Draw score
  love.graphics.setFont(scorefont)
  love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
  love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)

  -- Render paddles
  player1:render()
  player2:render()
  -- Render ball
  ball:render()

  -- End rendering at virtual resolution
  push:apply('end')
end