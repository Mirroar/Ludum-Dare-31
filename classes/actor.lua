Actor = class(Entity)

function Actor:construct(...)
    Entity.construct(self, ...)

    self.speed = 1
    self.moveX = 0
    self.moveY = 0
end

function Actor:update(delta, ...)
    Entity.update(self, delta, ...)

    -- make sure entity does not move faster than its max speed
    local speed = math.sqrt(self.moveX * self.moveX + self.moveY * self.moveY)
    if speed > 1 then
        self.moveX = self.moveX / speed
        self.moveY = self.moveY / speed
    end

    self.x = self.x + self.speed * delta * self.moveX
    self.y = self.y + self.speed * delta * self.moveY
end
