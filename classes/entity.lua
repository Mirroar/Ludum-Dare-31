Entity = class()

function Entity:construct(x, y)
    if x then
        self.AssertArgumentType(x, "number")
    end
    if y then
        self.AssertArgumentType(y, "number")
    end

    self.x = x or 0
    self.y = y or 0
    self.previousX = self.x
    self.previousY = self.y
    self.rotation = 0
    self.vx = 0
    self.vy = 0
    self.friction = 10
    self.bouncyness = 0.3

    self.hitTop = 0
    self.hitBottom = 1
    self.hitLeft = 0
    self.hitRight = 1

    self.centerX = 0.5
    self.centerY = 0.5
end

function Entity:GetX(centered)
    return self.x + (centered and self.centerX or 0)
end

function Entity:GetY(centered)
    return self.y + (centered and self.centerY or 0)
end

function Entity:SetX(x)
    self.AssertArgumentType(x, "number")

    self.x = x
end

function Entity:SetY(y)
    self.AssertArgumentType(y, "number")

    self.y = y
end

function Entity:SetPosition(x, y)
    self.AssertArgumentType(x, "number")
    self.AssertArgumentType(y, "number")

    self:SetX(x)
    self:SetY(y)
end

function Entity:SetHitRect(l, r, t, b)
    self.hitLeft = l
    self.hitRight = r
    self.hitTop = t
    self.hitBottom = b
end

function Entity:GetHitRect()
    return self.hitLeft, self.hitRight, self.hitTop, self.hitBottom
end

function Entity:GetRotation()
    return self.rotation
end

function Entity:SetRotation(rotation)
    self.AssertArgumentType(rotation, "number")

    self.rotation = angle(rotation)
end

function Entity:GetVelocity()
    return self.vx, self.vy
end

function Entity:SetVelocity(vx, vy)
    self.AssertArgumentType(vx, "number")
    self.AssertArgumentType(vy, "number")

    self.vx = vx
    self.vy = vy
end

function Entity:AddVelocity(vx, vy)
    self.AssertArgumentType(vx, "number")
    self.AssertArgumentType(vy, "number")

    self.vx = self.vx + vx
    self.vy = self.vx + vy
end

function Entity:GetFriction()
    return self.friction
end

function Entity:SetFriction(f)
    self.AssertArgumentType(f, "number")

    self.friction = f
end

function Entity:GetAngleTo(x, y)
    local dx = x - self:GetX(true)
    local dy = self:GetY(true) - y

    return angle(math.atan2(dx, dy) * 180 / math.pi)
end

function Entity:update(delta)
    -- save previous position for reverence
    self.previousX = self.x
    self.previousY = self.y

    -- only do movement calculation if object has a noticeable velocity
    if math.abs(self.vx) > 0.1 or math.abs(self.vy) > 0.1 then
        local vAngle = math.atan2(self.vx, self.vy)
        local ax = -math.sin(vAngle) * self.friction
        local ay = -math.cos(vAngle) * self.friction

        self.x = self.x + self.vx * delta + 0.5 * ax * delta * delta
        self.y = self.y + self.vy * delta + 0.5 * ay * delta * delta

        self.vx = self.vx + ax * delta
        self.vy = self.vy + ay * delta
    end
end

function Entity:draw()
    love.graphics.circle("fill", self.x, self.y, 10, 10)
end

function Entity:PushAway(entity, force)
    -- apply the force as some kind of velocity instead of directly moving the entity
    local x, y = entity:GetX(true), entity:GetY(true)
    local angle = self:GetAngleTo(x, y)

    --debug:insert(angle..' / '..math.sin(angle * math.pi / 180).." / "..-math.cos(angle * math.pi / 180))

    entity:SetVelocity(math.sin(angle * math.pi / 180) * force, -math.cos(angle * math.pi / 180) * force)
end
