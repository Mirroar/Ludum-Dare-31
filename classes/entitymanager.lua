EntityManager = class()

function EntityManager:construct()
    self.entities = {}
end

function EntityManager:AddEntity(entity)
    self.AssertArgumentType(entity, Entity)

    table.insert(self.entities, entity)
end

function EntityManager:GetCount()
    return #(self.entities)
end

function EntityManager:Get(num)
    return self.entities[num]
end

function EntityManager:update(delta)
    for _, entity in ipairs(self.entities) do
        entity:update(delta)
    end
end

function EntityManager:draw()
    --TODO: draw with y-ordering in mind
    for _, entity in ipairs(self.entities) do
        entity:draw()
    end
end
