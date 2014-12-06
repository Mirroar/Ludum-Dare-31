Dummy = class(Enemy)

function Dummy:construct(...)
    Enemy.construct(self, ...)

    self.speed = 0

    self:SetHitRect(0.4, 0.6, 0.4, 0.6)
end

function Dummy:draw()
    local x, y = map:GetScreenPosition(self.x, self.y)

    textures:DrawSprite("dummy", x, y)
end

function Dummy:update(delta, ...)
    Enemy.update(self, delta, ...)

    local player = self:TouchesPlayer()
    if player then
        -- push player away, dummy is shy...
        self:PushAway(player, 5)
    end
end