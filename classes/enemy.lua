Enemy = class(Actor)

function Enemy:construct(...)
    Actor.construct(self, ...)
end

function Enemy:TouchesPlayer()
    local x, y = self:GetX(), self:GetY()
    local l, r, t, b = self:GetHitRect()
    l = l + x
    r = r + x
    t = t + y
    b = b + y

    for i = 1, entities:GetCount() do
        local entity = entities:Get(i)
        if entity:IsInstanceOf(Player) then
            local px, py = entity:GetX(), entity:GetY()
            local pl, pr, pt, pb = entity:GetHitRect()
            pl = pl + px
            pr = pr + px
            pt = pt + py
            pb = pb + py

            -- test for actual hit
            if l < pr and pl < r and t < pb and pt < b then
                return entity
            end
        end
    end

    return false
end