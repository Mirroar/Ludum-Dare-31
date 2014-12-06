Player = class(Actor)

function Player:construct(...)
    Actor.construct(self, ...)

    self.speed = 5

    self:SetHitRect(0.3, 0.7, 0.3, 0.7)
end

function Player:draw()
    local x, y = map:GetScreenPosition(self.x, self.y)

    textures:DrawSprite("player", x, y)
end

function Player:update(delta, ...)
    self.moveX = 0
    self.moveY = 0
    if global.keyspressed['w'] and not global.keyspressed['s'] then
        self.moveY = -1
    end
    if global.keyspressed['s'] and not global.keyspressed['w'] then
        self.moveY = 1
    end
    if global.keyspressed['a'] and not global.keyspressed['d'] then
        self.moveX = -1
    end
    if global.keyspressed['d'] and not global.keyspressed['a'] then
        self.moveX = 1
    end

    Actor.update(self, delta, ...)
end
