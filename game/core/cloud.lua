require("core.entity")
require("core.player")

Cloud = Class("Cloud", Entity)

function Cloud:initialize(x, y, spriteWidth, spriteHeight, animations,timer, player)
	Entity.initialize(self, x, y, spriteWidth, spriteHeight, animations)

	self.x = x
	self.y = y
	self.spriteWidth = spriteWidth
	self.spriteHeight = spriteHeight

	-- how long until cloud appears
	self.timer = timer
	self.isActive = false

	self.velocity = 50 -- guess for now

	self.player = player
end

function Cloud:isAtPlayer()
	return math.abs(self.x - self.player.x) < 2
end

function Cloud:navigateTowardsPlayer(dt)
	print("navigating to player")
	local speed = self.velocity * dt
	if self.x < self.player.x then
		self.x = self.x + speed
	elseif self.x > self.player.x then
		self.x = self.x - speed
	end
end

function Cloud:rain()
	print("raining on player")
end

function Cloud:update(dt) 
	Entity.update(self, dt)

	if self.player:secondsSinceLastMove() > self.timer then
		self.isActive = true
	else
		self.isActive = false
	end

	if self.isActive then
		if not self:isAtPlayer() then
			self:navigateTowardsPlayer(dt)
		else
			self:rain()
		end
	end
end

function Cloud:draw() 
	Entity.draw(self)
end
