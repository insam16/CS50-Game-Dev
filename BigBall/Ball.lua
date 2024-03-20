Ball = Class{}

function Ball:init(x, y, size)
	self.x = x
	self.y = y
	self.size = size

	self.dy = math.random(2) == 1 and -100 or 100
	self.dx = math.random(-50, 50)
end

function Ball:reset()
	self.x = VIRTUAL_WIDTH / 2 - self.size / 2
	self.y = VIRTUAL_HEIGHT / 2 - self.size / 2
	self.dy = math.random(2) == 1 and 100 or -100
	self.dx = math.random(-50, 50) * 1.5
end

function Ball:collides(paddle)
	if self.x > paddle.x + paddle.width or paddle.x > self.x + self.size then
		return false
	end

	if self.y > paddle.y + paddle.height or paddle.y > self.y + self.size then
		return false
	end
	
	return true
end

function Ball:update(dt)
	self.x = self.x + self.dx * dt
	self.y = self.y + self.dy * dt
end

function Ball:render()
	love.graphics.rectangle('fill', self.x, self.y, self.size, self.size)
end
