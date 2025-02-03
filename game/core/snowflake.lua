require("core.entity")

Snowflake = Class('Snowflake', Entity)

function Snowflake:initialize(x, y, spriteWidth, spriteHeight, animations, spawnTime, fallSpeed)
	Entity.initialize(self, x, y, spriteWidth, spriteHeight, animations)
	
	self.spawnTime = spawnTime
	self.fallSpeed = fallSpeed
	self.isDeleted = false

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
        local spriteWidth, spriteHeight = 7, 7
		local fallSpeed = math.random(8, 20) -- these numbers are guesses

		local animations = {
			default = Animation:new("default", 1, 5, 5, spriteWidth, spriteHeight, 0.5, true),
		}

        table.insert(snowflakes, Snowflake(x, y, spriteWidth, spriteHeight, animations, spawnTime, fallSpeed))

    end

    -- Sort by spawn time so they are created in order
    table.sort(snowflakes, function(a, b) return a.spawnTime < b.spawnTime end)

    return snowflakes
end

function Snowflake:update(dt)
	Entity.update(self, dt)

	-- move down at fallSpeed
	self.y = self.y + self.fallSpeed * dt

	-- delete if off the bottom of the screen
	if self.y > 150 then
		self.isDeleted = true
	end
end

function Snowflake:draw()
	-- maybe draw a slightly larger version behind to act as an outline?
	Entity.draw(self)
end
