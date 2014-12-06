Player = class(Actor)

function Player:construct(...)
    Actor.construct(self, ...)
end

function Player:draw()
    textures:DrawSprite("player", self.x, self.y)
end