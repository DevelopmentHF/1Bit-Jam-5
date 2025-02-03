require("core.entity")

Snowflake = Class('Snowflake', Entity)

function Snowflake:initialize(x, y, startFrame, endFrame, spriteRow, spriteWidth, spriteHeight, animationDuration, spawnTime, fallSpeed)
	Entity.initialize(self, x, y, startFrame, endFrame, spriteRow, spriteWidth, spriteHeight, animationDuration)
	
	self.spawnTime = spawnTime
	self.fallSpeed = fallSpeed

end

-- STATIC
-- frequency: int - num snowflakes that will be spawned per second
-- duration: int - how long level lasts for (seconds)
--
-- returns: list of snowflakes to be randomly spawned
function Snowflake.generate(frequency, duration)
	local snowflakes = {}
    local numSnowflakes = frequency * duration

    for _ = 1, numSnowflakes do
        local spawnTime = math.random() * duration
        local x = math.random(0, 160)
        local y = -math.random(10, 50) -- starts off screen
        local startFrame, endFrame = 1, 1 -- no anims as of yet
        local spriteRow, spriteWidth, spriteHeight = 5, 8, 8
        local animationDuration = 0.5
		local fallSpeed = math.random(8, 20) -- these numbers are guesses

        table.insert(snowflakes, Snowflake(x, y, startFrame, endFrame, spriteRow, spriteWidth, spriteHeight, animationDuration, spawnTime, fallSpeed))

    end

    -- Sort by spawn time so they are created in order
    table.sort(snowflakes, function(a, b) return a.spawnTime < b.spawnTime end)

    return snowflakes
end

function Snowflake:update(dt)
	Entity.update(self, dt)

	-- move down at fallSpeed
	self.y = self.y + self.fallSpeed * dt
end

function Snowflake:draw()
	Entity.draw(self)
end
