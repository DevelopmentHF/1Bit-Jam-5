require("core.entity")

Player = Class('Player', Entity)
-- TODO: Add dashes and near misses
function Player:initialize(x, y, spriteWidth, spriteHeight, animations, world)
	self.animations = animations
	Entity.initialize(self, x, y, spriteWidth, spriteHeight, animations)
	
	self.spawnX = x
	self.spawnY = y

	self.width = spriteWidth
	self.height = spriteHeight
	self.xVel = 0
	self.yVel = 0
	self.maxSpeed = 100
	self.acceleration = 4000 -- 200/4000 = 0.05s to speed up to max
	self.initialFriction = 3500
	self.friction = self.initialFriction
	self.gravity = 1500
	self.jumpFactor = -250

	self.grounded = false
	self.jumpCount = 0
	self.maxJumps = 2

	self.moved = false
	self.lastMoveTime = 0

	self.isDying = false
	self.deathTimer = self.animations["death"].totalDuration

	self.physics = {}
	self.physics.body = love.physics.newBody(world, self.x, self.y, "dynamic")
	self.physics.body:setFixedRotation(true) -- dont rotate
	self.physics.shape = love.physics.newRectangleShape(self.width, self.height)
	self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
end

function Player:update(dt)
	Entity.update(self, dt)

	-- special death update logic
	if self.isDying then
		-- Reduce the death timer
		self.deathTimer = self.deathTimer - dt
		if self.deathTimer <= 0 then
			self:respawn() -- Respawn after death animation/delay
		end
	else
		-- Normal update logic
		self:syncPhysics()
		self:applyGravity(dt)
		self:move(dt)
		if self:inDeathZone() then
			self:die()
		end
	end

end

function Player:move(dt)
	if love.keyboard.isDown("d", "right") then
		if self.xVel < self.maxSpeed then
			if self.xVel + self.acceleration * dt < self.maxSpeed then
				self.xVel = self.xVel + self.acceleration * dt
			else
				self.xVel = self.maxSpeed
			end
			self.moved = true
		end
	elseif love.keyboard.isDown("a", "left") then
		if self.xVel > -self.maxSpeed then
			if self.xVel - self.acceleration * dt > -self.maxSpeed then
				self.xVel = self.xVel - self.acceleration * dt
			else
				self.xVel = -self.maxSpeed
			end
		end
		self.moved = true
	else
		self:applyFriction(dt)
	end

	if self.xVel ~= 0 then
        self.lastMoveTime = GameTime
    end
end

function Player:applyGravity(dt)
	if not self.grounded then
		self.yVel = self.yVel + self.gravity * dt
	end
end

function Player:applyFriction(dt)
	if self.xVel > 0 then
		if self.xVel - self.friction * dt > 0 then
			self.xVel = self.xVel - self.friction * dt
		else
			self.xVel = 0
		end
	elseif self.xVel < 0 then
		if self.xVel + self.friction * dt < 0 then
			self.xVel = self.xVel + self.friction * dt
		else
			self.xVel = 0
		end
	end
end

function Player:syncPhysics()
	self.x, self.y = self.physics.body:getPosition();
	self.physics.body:setLinearVelocity(self.xVel, self.yVel)
end


function Player:beginContact(a, b, collision)
    if self.grounded == true then return end

    local nx, ny = collision:getNormal()
    local fixture, otherFixture = a, b

    if b == self.physics.fixture then
        fixture, otherFixture = b, a
    end

	if otherFixture and otherFixture:getUserData() then
        local object = otherFixture:getUserData()
        if object and object.ice then
            print("Player is on an icey platform. Reduce friction")
            object.standingOn = true  
			self.friction = 500	
			-- for some reason with manually platform creation temp platform normals are inverted to regular
			-- collidable objects straight from tiled
			if ny < 0 then
				self:land(collision)
			end
        end
    end

    -- Check if the player lands on a "death" object
    if ny > 0 then
        self:land(collision)
    end
end

-- check whether the player is within a death bounded area 
function Player:inDeathZone()
	for _, zone in pairs(DeathZones) do
		-- Check if the player's x and y are within the bounds of the zone
		if self.x > zone.x and self.x < zone.x + zone.width and
		   self.y > zone.y and self.y < zone.y + zone.height then
			return true
		end
	end

	return false -- Player is safe
end

-- Play death anim and stuff
function Player:die()
	if not self.isDying then
		self.isDying = true
		Entity.swapAnimation(self, "death")
		love.audio.newSource("assets/sfx/hitHurt.wav", "static"):play()
	end
end

function Player:respawn()
	-- Reset player position, velocity, and state
	self.x = self.spawnX
	self.y = self.spawnY
	self.xVel = 0
	self.yVel = 0
	self.isDying = false
	self.deathTimer = self.animations["death"].totalDuration
	self.physics.body:setPosition(self.spawnX, self.spawnY)
	self.physics.body:setLinearVelocity(0, 0)

	GameTime = 0
	-- also need to reset snowflakes

end

function Player:land(collision)
	self.currentGroundCollision = collision
	self.yVel = 0
	self.grounded = true
	self.jumpCount = 0
end

function Player:endContact(a, b, collision)
	if a == self.physics.fixture or b == self.physics.fixture then
		if (self.currentGroundCollision == collision) then
			self.grounded = false	
		end
	end

	self.friction = self.initialFriction
end

function Player:jump(key)
	print(self.jumpCount)
	if (key == "w" or key == "up") and self.jumpCount < self.maxJumps then
		if not self.isDying then
			Entity.swapAnimation(self, "jump")
		end
		self.yVel = self.jumpFactor
		self.grounded = false
		self.jumpCount = self.jumpCount + 1
		love.audio.newSource("assets/sfx/playerjump.wav", "static"):play()
	end
end

function Player:secondsSinceLastMove()
	return GameTime - self.lastMoveTime
end

function Player:keypressed(key)
    if (key == "w" or key == "up") and self.jumpCount < self.maxJumps then
        self:jump(key)
    end
end

function Player:draw()
	Entity.draw(self)
	--love.graphics.circle("fill", self.x, self.y, 1)
end
