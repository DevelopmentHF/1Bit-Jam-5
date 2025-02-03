require("states.levelstate")
require("states.state")
require("ui.animatedtext")

StartState = Class('StartState', State)

-- TODO: Make this a singleton
function StartState:initialize()
	--self.title = HighlightedText:new(love.graphics.getWidth()/2 , love.graphics.getHeight()/2, "bit", 20)
	
	self.title = AnimatedText:new(love.graphics.getWidth()/2 , love.graphics.getHeight()/2, "1-bit Jam #5", BigFont, 10, 1)
end

function StartState:enter()
	
end

function StartState:update(dt)
    -- Press any key to start the game
    if love.keyboard.isDown("space") then
        stateManager:switch(LevelState:new(1))
    end

	self.title:update(dt)
end

function StartState:draw()
	love.graphics.push()
    love.graphics.scale(ScalingFactor, ScalingFactor)

	love.graphics.setColor(0, 0, 0)
    love.graphics.draw(Bg)

	love.graphics.setColor(0, 0, 1, 1)
	love.graphics.pop()
	love.graphics.setColor(1, 1, 1, 1)

	self.title:draw()
    love.graphics.printf("Press [Space] to Start", Font, 0, love.graphics.getHeight() - (love.graphics.getHeight() / 4), love.graphics.getWidth(), "center")

	love.graphics.printf("Made with <3", Font, 0, love.graphics.getHeight() - 14, love.graphics.getWidth() - Font:getWidth("Made with <3"))

end
