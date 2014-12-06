Enemy = class(Actor)

function Enemy:construct(...)
    Actor.construct(self, ...)
end

function Enemy:TouchesPlayer()
    for i = 1, entities:GetCount() do
        local entity = entities:Get(i)
    end

    return false
end