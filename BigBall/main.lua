push = require 'push'
Class = require 'class'
require 'Paddle'
require 'Ball'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 250

goalScore = 5

ballIncreaseSize = 10
ballMaxSize = 350
ballMinSize = 10

function love.load()
	love.graphics.setDefaultFilter('nearest', 'nearest')

	love.window.setTitle('Pong - Big Ball')

	math.randomseed(os.time())

	smallFont = love.graphics.newFont('font.ttf', 8)
	largeFont = love.graphics.newFont('font.ttf', 16)
	scoreFont = love.graphics.newFont('font.ttf', 32)
	love.graphics.setFont(smallFont)

	sounds = {
		['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
		['score'] = love.audio.newSource('sounds/score.wav', 'static'),
		['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
	}

	push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
		fullscreen = false,
		resizable = true,
		vsync = true
	})

	player1Score = 0
	player2Score = 0
	servingPlayer = 1
	
	player1 = Paddle(10, 30, 5, 20)
	player2 = Paddle(VIRTUAL_WIDTH - 15, VIRTUAL_HEIGHT - 50, 5, 20)

	ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)
	gameState = 'start'
	ballMode = 'big'
end

function love.resize(w, h)
	push:resize(w, h)
end

function love.update(dt)
	if gameState == 'serve' then
		ball.dy = math.random(-50, 50)
		if servingPlayer == 1 then
			ball.dx = math.random(140, 200)
		else
			ball.dx = -math.random(140, 200)
		end
	elseif gameState == 'play' then
		if ball:collides(player1) then
			ball.dx = -ball.dx * 1.03
			ball.x = player1.x + player1.width
			sounds['paddle_hit']:play()
			if ballMode == 'big' then
				ball.size = ball.size + ballIncreaseSize
			else
				ball.size = ball.size - ballIncreaseSize
			end
			if ball.dy < 0 then
				ball.dy = -math.random(10, 150)
			else
				ball.dy = math.random(10, 150)
			end
		end
		if ball:collides(player2) then
			ball.dx = -ball.dx * 1.03
			sounds['paddle_hit']:play()
			if ballMode == 'big' then
				ball.x = player2.x - ball.size - ballIncreaseSize
				ball.size = ball.size + ballIncreaseSize
			else
				ball.x = player2.x - ball.size + ballIncreaseSize
				ball.size = ball.size - ballIncreaseSize
			end
			if ball.dy < 0 then
				ball.dy = -math.random(10, 150)
			else
				ball.dy = math.random(10, 150)
			end
		end
		
		if ball.y <= 0 then
			ball.y = 0
			ball.dy = -ball.dy
			sounds['wall_hit']:play()
		end
		
		if ball.y >= VIRTUAL_HEIGHT - ball.size then
			ball.y = VIRTUAL_HEIGHT - ball.size
			ball.dy = -ball.dy
			sounds['wall_hit']:play()
		end
	end

	if ball.x < 0 then
		servingPlayer = 1
		player2Score = player2Score + 1
		ball:reset()
		sounds['score']:play()

		if player2Score >= goalScore then
			winningPlayer = 2
			gameState = 'done'
		else
			gameState = 'serve'
		end
	end

	if ball.x + ball.size > VIRTUAL_WIDTH then
		servingPlayer = 2
		player1Score = player1Score + 1
		ball:reset()
		sounds['score']:play()
		
		if player1Score >= goalScore then
			winningPlayer = 1
			gameState = 'done'
		else
			gameState = 'serve'
		end
	end

	-- p1 movement
	if love.keyboard.isDown('w') then
		player1.dy = -PADDLE_SPEED
	elseif love.keyboard.isDown('s') then
		player1.dy = PADDLE_SPEED
	else
		player1.dy = 0
	end

	-- p2 movement
	if love.keyboard.isDown('up') then
		player2.dy = -PADDLE_SPEED
	elseif love.keyboard.isDown('down') then
		player2.dy = PADDLE_SPEED
	else
		player2.dy = 0
	end

	if gameState == 'play' then
		if ballMode == 'big' and ball.size >= ballMaxSize then
			ballMode = 'small'
		elseif ballMode == 'small' and ball.size <= ballMinSize then
			ballMode = 'big'
		end
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
			ball:reset()
			player1Score = 0
			player2Score = 0

			if winningPlayer == 1 then
				servingPlayer = 2
			else
				servingPlayer = 1
			end
		end
	end
end

function love.draw()
	push:apply('start')

	love.graphics.clear(40/255, 45/255, 52/255, 255/255)

	love.graphics.setFont(smallFont)

	displayScore()

	if gameState == 'start' then
		love.graphics.setFont(smallFont)
		love.graphics.printf('Welcome to Pong - Big Ball!', 0, 10, VIRTUAL_WIDTH, 'center')
		love.graphics.printf('Press Enter to begin!', 0, 20, VIRTUAL_WIDTH, 'center')
	elseif
		gameState == 'serve' then
			love.graphics.setFont(smallFont)
			love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!",
				0, 10, VIRTUAL_WIDTH, 'center')
			love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
	elseif gameState == 'play' then
		-- no UI to display
	elseif gameState == 'done' then
		love.graphics.setFont(largeFont)
		love.graphics.printf('Player ' .. tostring(winningPlayer) .. " wins!",
			0, 10, VIRTUAL_WIDTH, 'center')
		love.graphics.printf('Press Enter to restart!', 
			0, 30, VIRTUAL_WIDTH, 'center')
	end
	
	player1:render()
	player2:render()
	ball:render()

	displayFPS()
	displayBallSize()

	push:apply('end')
end

function displayFPS()
	love.graphics.setFont(smallFont)
	love.graphics.setColor(0, 255/255, 0, 255/255)
	love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end

function displayBallSize()
	love.graphics.setFont(smallFont)
	love.graphics.setColor(0, 255/255, 0, 255/255)
	love.graphics.print('Ball: ' .. tostring(ball.size), 10, 20)
end

function displayScore()
	love.graphics.setFont(scoreFont)
	love.graphics. print(tostring(player1Score),
		VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
	love.graphics. print(tostring(player2Score),
		VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
end
