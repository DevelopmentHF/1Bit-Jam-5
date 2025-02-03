require("states.endstate")
require("core.player")
require("core.snowflake")

local STI = require("sti")

LevelState = Class('LevelState', State)

-- Since this is a 1bit jam, make everything either black or one of these colours.
-- If we want something to be this colour, just love.graphics.setColor before drawing it.
-- It will not change the colour of black
AlternateColours = {
	{198/255, 81/255, 151/255, 1},
	{115/255, 190/255, 211/255, 1},
}

function LevelState:initialize(number)
	self.number = number
end

function LevelState:enter()
	Map = STI(string.format("assets/map/level_%d.lua", self.number), {"box2d"})
	self.world = love.physics.newWorld(0, 0)

	-- load important object level details from Tiled	
	for _, object in pairs(Map.objects) do
		-- spawn point
		if object.name == "spawn" then
			self.spawnX = object.x
			self.spawnY = object.y
		end
	end

	GameTime = 0

	local playerAnimations = {
		default = Animation:new("default", 1, 12, 9, TileWidth, TileHeight-2, 0.3, true),
		death = Animation:new("death", 1, 8, 8, TileWidth, TileHeight-2, 0.1, false),
		jump = Animation:new("jump", 1, 2, 10, TileWidth, TileHeight-2, 0.15, false),
	}
	self.player = Player:new(
		self.spawnX,
		self.spawnY,
		TileWidth,
		TileHeight-2,
		playerAnimations,
		self.world
	)

	-- Set specific collision callbacks for player instance
    self.world:setCallbacks(
        function(a, b, collision) self.player:beginContact(a, b, collision) end,
        function(a, b, collision) self.player:endContact(a, b, collision) end
    )

	Map:box2d_init(self.world)

	Map.layers.solid.visible = false
	Map.layers.death.visible = false
	
	DeathZones = {}
	-- find all tiles which the player should die at
	for _, object in pairs(Map.objects) do
		-- death zone 
		if object.name == "death" then
			table.insert(DeathZones, {
				x = object.x,
            	y = object.y,
				width = object.width,
				height = object.height
			})
		end
	end
	Entities = {}
	
	-- load player
	table.insert(Entities, self.player)

	-- generate initial snowflake data
	self.pendingSnowflakes = Snowflake.generate(2, 5) -- test with 2 snowflakes per second?
	print(self.pendingSnowflakes)
	self.activeSnowflakes = {}
end

function LevelState:updateDeathZones()
    -- Clear out old death zones for this cycle
    DeathZones = {}

    -- Add the original death zones from the Tiled map
    for _, object in pairs(Map.objects) do
        -- death zone
        if object.name == "death" then
            table.insert(DeathZones, {
                x = object.x,
                y = object.y,
                width = object.width,
                height = object.height
            })
        end
    end

    -- Add snowflakes' bounding boxes to the death zones
    for _, snowflake in ipairs(self.activeSnowflakes) do
        table.insert(DeathZones, {
            x = snowflake.x - snowflake.spriteWidth/2,
            y = snowflake.y - snowflake.spriteHeight/2,
            width = snowflake.spriteWidth,
            height = snowflake.spriteHeight
        })
    end
end

function LevelState:update(dt)
	-- update world
	self.world:update(dt)

	GameTime = GameTime + dt

    -- snowflakes from pending to active
    while #self.pendingSnowflakes > 0 and self.pendingSnowflakes[1].spawnTime <= GameTime do
        local snowflake = table.remove(self.pendingSnowflakes, 1)
        table.insert(self.activeSnowflakes, snowflake)
        table.insert(Entities, snowflake)
		print("spaned snowflake")
    end

	-- Update all entities
    for i = #Entities, 1, -1 do
        local entity = Entities[i]
        entity:update(dt)

        -- Check if the snowflake is marked for deletion
        if entity.isDeleted then
            -- Remove from active snowflakes
            for j, snowflake in ipairs(self.activeSnowflakes) do
                if snowflake == entity then
                    table.remove(self.activeSnowflakes, j)
                    break
                end
            end

            -- Remove from entities
            table.remove(Entities, i)

            print("deleted snowflake")
        end
    end

	self:updateDeathZones()

	-- check for the end of the level
	if #self.activeSnowflakes == 0 and GameTime > 5 then
		stateManager:switchToNextLevel()
	end
end


function LevelState:draw()
    love.graphics.push()
    love.graphics.scale(ScalingFactor, ScalingFactor)
	love.graphics.setColor(AlternateColours[self.number])
    love.graphics.draw(Bg)
	love.graphics.setColor(1, 1, 1, 1)
	--self.map:draw(0, 0, ScalingFactor, ScalingFactor)
	Map:drawLayer(Map.layers["ground"])
	Map:drawLayer(Map.layers["snow"])

    -- Draw all entities
    for _, value in ipairs(Entities) do
        value:draw()
    end

    love.graphics.pop()

end

function LevelState:reset()
	-- reset snowflakes
	self.activeSnowflakes = {}
	self.pendingSnowflakes = Snowflake.generate(2, 60) -- test with 2 snowflakes per second?
end

function LevelState:exit()
	love.audio.newSource("assets/sfx/complete.wav", "static"):play()
end
