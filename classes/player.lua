Player = class(Actor)

function Player:construct(...)
    Actor.construct(self, ...)

    self.speed = 5
end

function Player:draw()
    textures:DrawSprite("player", self.x * 16, self.y * 16)
end

function Player:update(delta, ...)
    Actor.update(self, delta, ...)

    --TODO: diagonal movement is currently faster
    if global.keyspressed['w'] then
        self.y = self.y - self.speed * delta
    end
    if global.keyspressed['s'] then
        self.y = self.y + self.speed * delta
    end
    if global.keyspressed['a'] then
        self.x = self.x - self.speed * delta
    end
    if global.keyspressed['d'] then
        self.x = self.x + self.speed * delta
    end
end