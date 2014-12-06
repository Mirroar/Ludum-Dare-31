Actor = class(Entity)

function Actor:construct(...)
    Entity.construct(self, ...)

    self.maxSpeed = 5
    self.acceleration = 5
    self.slowDown = 10
    self.moveX = 0
    self.moveY = 0
end

function Actor:update(delta, ...)
    Entity.update(self, delta, ...)

    -- make sure entity does not move faster than its max speed
    local targetSpeed = math.sqrt(self.moveX * self.moveX + self.moveY * self.moveY)
    if targetSpeed > 1 then
        self.moveX = self.moveX / targetSpeed
        self.moveY = self.moveY / targetSpeed
    end

    local speed = math.sqrt(self.vx * self.vx + self.vy * self.vy)
    local a = self.acceleration * (self.maxSpeed - speed)

    -- accelerate the player
    if a > 0 then
        self.vx = self.vx + a * delta * self.moveX
        self.vy = self.vy + a * delta * self.moveY
    end
end
