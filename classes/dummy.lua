Dummy = class(Enemy)

function Dummy:construct(...)
    Enemy.construct(self, ...)

    self.speed = 0
end

function Dummy:draw()
    local x, y = map:GetScreenPosition(self.x, self.y)

    textures:DrawSprite("dummy", x, y)
end

function Dummy:update(delta, ...)
    Enemy.update(self, delta, ...)

    local player = self:TouchesPlayer()
    if player then
        --TODO: push player away, dummy is shy...
    end
end