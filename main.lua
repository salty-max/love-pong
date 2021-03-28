-- https://github.com/Ulydev/push
local push = require 'lib/push'

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

  -- Velocity and position for the ball at startup
  startBallX = VIRTUAL_WIDTH / 2 - 2
  startBallY = VIRTUAL_HEIGHT / 2 - 2
  ballX = startBallX
  ballY = startBallY
  -- Randomize default velocity for the ball
  ballDX = math.random(2) == 1 and 100 or -100
  ballDY = math.random(-50, 50) * 1.5

  player1Score = 0
  player2Score = 0

  player1Y = 30
  player2Y = VIRTUAL_HEIGHT - 50

  -- Default game state
  gameState = 'start'
end

function love.keypressed(key)
  if key == 'escape' then
    love.event.quit()
  elseif key == 'enter' or key == 'return' then
    if gameState == 'start' then
      gameState = 'play'
    else
      gameState = 'start'

      -- Reset ball's position
      ballX = startBallX
      ballY = startBallY
      -- and give ball's dx and dy a new random starting value
      ballDX = math.random(2) == 1 and 100 or -100
      ballDY = math.random(-50, 50) * 1.5
    end
  end
end

function love.update(dt)
  -- Player 1 movement
  if love.keyboard.isDown('z') then
    -- Add negative paddle speed to current Y scaled by deltaTime
    -- clamped to the bounds of the screen
    player1Y = math.max(0, player1Y + -PADDLE_SPEED * dt)
  elseif love.keyboard.isDown('s') then
    -- Add positive paddle speed to current Y scaled by deltaTime
    player1Y = math.min(VIRTUAL_HEIGHT - 20, player1Y + PADDLE_SPEED * dt)
  end

  -- Player 2 movement
  -- Same behavior than player 1
  if love.keyboard.isDown('up') then
    player2Y = math.max(0, player2Y + -PADDLE_SPEED * dt)
  elseif love.keyboard.isDown('down') then
    player2Y = math.min(VIRTUAL_HEIGHT - 20, player2Y + PADDLE_SPEED * dt)
  end

  -- Update ball velocity only when in play state
  -- scaled by dt so movement is framerate-independent
  if gameState == 'play' then
    ballX = ballX + ballDX * dt
    ballY = ballY + ballDY * dt
  end
end

function love.draw()
  -- Begin rendering at virtual resolution
  push:apply('start')
  -- Clear the screen
  love.graphics.clear(40/255, 45/255, 52/255, 1)

  -- Draw welcome text
  love.graphics.setFont(defaultfont)
  love.graphics.printf('Hello Pong!', 0, 20, VIRTUAL_WIDTH, 'center')

  -- Draw score
  love.graphics.setFont(scorefont)
  love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
  love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)

  -- Render paddles
  love.graphics.rectangle('fill', 10, player1Y, 5, 20)
  love.graphics.rectangle('fill', VIRTUAL_WIDTH - 15, player2Y, 5, 20)
  -- Render ball
  love.graphics.rectangle('fill', ballX, ballY, 4, 4)

  -- End rendering at virtual resolution
  push:apply('end')
end