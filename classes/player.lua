Player = class(Actor)

function Player:construct(...)
    Actor.construct(self, ...)

    self.speed = 5

    self.hitLeft = 4/16
    self.hitRight = 13/16
    self.hitTop = 3/16
    self.hitBottom = 13/16
end

function Player:draw()
    local x, y = map:GetScreenPosition(self.x, self.y)

    textures:DrawSprite("player", x, y)
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