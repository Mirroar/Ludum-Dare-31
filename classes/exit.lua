Exit = class(Enemy)

function Exit:construct(...)
    Enemy.construct(self, ...)

    self.speed = 0

    self:SetHitRect(0, 0.3, 0, 1)
end

function Exit:draw()
    local x, y = map:GetScreenPosition(self.x, self.y)

    --textures:DrawSprite("dummy", x, y)
end

function Exit:update(delta, ...)
    Enemy.update(self, delta, ...)

    local player = self:TouchesPlayer()
    if player then
        -- player is exiting the game, so this is it
        --TODO: keep the player moving left and fade out the screen before actually exiting
        love.event.quit()
    end
end