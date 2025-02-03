Entity = Class('Entity')

function Entity:initialize(x, y, startFrame, endFrame, spriteRow, spriteWidth, spriteHeight, animationDuration)
	self.x = x
	self.y = y

	self.startFrame = startFrame
	self.endFrame = endFrame
	self.animationDuration = animationDuration

	self.spriteWidth = spriteWidth
	self.spriteHeight = spriteHeight
	
	self.animation = Anim8.newAnimation(AnimationGrid(tostring(startFrame) .. '-' .. tostring(endFrame), spriteRow), animationDuration)
end

function Entity:update(dt)
	self.animation:update(dt)
end

function Entity:draw()
	self.animation:draw(TileSheet, self.x - self.spriteWidth/2, self.y - self.spriteHeight/2)
end
