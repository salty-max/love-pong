--[[
  CS50G Project 0
  Pong remake
  Author: Maxime Blanc
  https://github.com/salty-max
  MAIN
--]] --[[
    Library to set virtual resolution
    -- https://github.com/Ulydev/push
--]]
push = require 'lib/push'

--[[
    Library to implement a class system in lua
    -- https://github.com/vrld/hump/blob/master/class.lua
--]]
Class = require 'class'

require 'Paddle'
require 'Ball'

WINDOW_WIDTH = 1024
WINDOW_HEIGHT = 768
VIRTUAL_WIDTH = 320
VIRTUAL_HEIGHT = 240

PADDLE_SPEED = 200
SCORE_TO_WIN = 10

function love.load()
    -- Use nearest neighbor filtering
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- Seed the RNG so that calls to random are always random
    -- Use the current unix time to get a different number at each startup
    math.randomseed(os.time())

    -- Load fonts
    defaultfont = love.graphics.newFont('resources/font.ttf', 8)
    largefont = love.graphics.newFont('resources/font.ttf', 16)
    scorefont = love.graphics.newFont('resources/font.ttf', 32)
    -- Set Löve active font
    love.graphics.setFont(defaultfont)

    -- Set up sound effects table
    sounds = {
        ['paddle_hit'] = love.audio.newSource('resources/sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('resources/sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('resources/sounds/wall_hit.wav', 'static')
    }

    love.window.setTitle('Pong')

    -- Initialize virtual resolution
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    -- Initialize players paddle
    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

    -- Player 1 serves first
    servingPlayer = 1
    winningPlayer = 0

    -- Place a ball in the middle of the screen
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    -- Initialize score variables, for rendering score and keep track of the winner
    player1Score = 0
    player2Score = 0

    -- Default game state
    gameState = 'start'
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)
    if gameState == 'serve' then
        -- Before switching to play state, initialize ball's velocity
        -- based on who last scored
        ball.dy = math.random(-50, 50)

        if servingPlayer == 1 then
            ball.dx = math.random(140, 200)
        else
            ball.dx = -math.random(140, 200)
        end
    elseif gameState == 'play' then
        -- Detect ball collision with paddles, reversing dx if true and
        -- slightly increasing it, then altering the dy based on position
        if ball:collides(player1) then
            sounds['paddle_hit']:play()
            ball.dx = -ball.dx * 1.03
            -- shift ball outside of paddle to avoid infinite collision
            ball.x = player1.x + 5

            -- Keep y velocity going in the same direction, but randomize it
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
        end

        if ball:collides(player2) then
            sounds['paddle_hit']:play()
            ball.dx = -ball.dx * 1.03
            -- shift ball outside of paddle to avoid infinite collision
            ball.x = player2.x - 4

            -- Keep y velocity going in the same direction, but randomize it
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
        end

        -- Detect upper and lower screen edge collision and reverse it
        -- if collision happens
        if ball.y <= 0 then
            sounds['wall_hit']:play()
            ball.y = 0
            ball.dy = -ball.dy
        end
        -- -4 to account for the ball's size
        if ball.y >= VIRTUAL_HEIGHT - 4 then
            sounds['wall_hit']:play()
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
        end

        -- If the ball reaches the left or right edge of the screen,
        -- reset the ball and update the score
        if ball.x < 0 then
            sounds['score']:play()
            servingPlayer = 1
            player2Score = player2Score + 1

            if player2Score == SCORE_TO_WIN then
                winningPlayer = 2
                gameState = 'done'
            else
                gameState = 'serve'
                ball:reset()
            end
        end

        if ball.x > VIRTUAL_WIDTH then
            sounds['score']:play()
            servingPlayer = 2
            player1Score = player1Score + 1

            if player1Score == SCORE_TO_WIN then
                winningPlayer = 1
                gameState = 'done'
            else
                gameState = 'serve'
                ball:reset()
            end

        end
    end

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
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'done' then
            gameState = 'serve'
            -- Reset ball position and give it a new random starting velocity
            ball:reset()

            player1Score = 0
            player2Score = 0
            servingPlayer = winningPlayer == 1 and 2 or 1
            gameState = "serve"
        end
    end
end

function love.draw()
    -- Begin rendering at virtual resolution
    push:apply('start')
    -- Clear the screen and apply background
    love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 1)

    displayInfo()

    -- Draw score
    love.graphics.setFont(scorefont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)

    -- Render paddles
    player1:render()
    player2:render()
    -- Render ball
    ball:render()

    displayFPS()

    -- End rendering at virtual resolution
    push:apply('end')
end

--[[
    Update HUD when state changed
--]]
function displayInfo()
    love.graphics.setFont(defaultfont)
    if gameState == 'start' then
        love.graphics.printf('Hello Pong!', 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to start', 0, 30, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        love.graphics.printf('Player ' .. tostring(servingPlayer) .. ' is serving!', 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to serve', 0, 30, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'done' then
        love.graphics.setColor(0, 1, 0, 1)
        love.graphics.setFont(largefont)
        love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!', 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setFont(defaultfont)
        love.graphics.printf('Press Enter to rematch', 0, 40, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Esc to quit', 0, 50, VIRTUAL_WIDTH, 'center')
    end
end

--[[
  Renders the current FPS
--]]
function displayFPS()
    -- FPS display across all states
    love.graphics.setFont(defaultfont)

    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end

--[[
  Renders the ball velocity
  -- DEBUG PURPOSE ONLY --
--]]
function displayBallVelocity()
    love.graphics.setFont(defaultfont)
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.print("BALL DX: " .. tostring(ball.dx), 10, 20)
    love.graphics.print("BALL DY: " .. tostring(ball.dy), 10, 30)
end
