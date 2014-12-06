-- tiled map class that works with any number of dimensions
Map = class()

function Map:construct(...)
    self.tileset = nil
    self.dimensions = #{...}
    self:SetSize(...)
    self.xTileSize = {}
    self.yTileSize = {}
    for i = 1, self.dimensions do
        self.xTileSize[i] = 16
        self.yTileSize[i] = 16
    end
    self.yTileSize[1] = 0
    if self.dimensions > 1 then
        self.xTileSize[2] = 0
    end
end

function Map:SetSize(...)
    if not self.tiles then self.tiles = {} end

    self:_SetSizeRecursive(self.tiles, self.dimensions, ...)
end

function Map:_SetSizeRecursive(table, dimension, size, ...)
    for i = 1, size do
        if dimension == 1 then
            table[i] = Tile()
        else
            table[i] = {}
            self:_SetSizeRecursive(table[i], dimension - 1, ...)
        end
    end

    --TODO: reduce table if size is less than before
end

function Map:GetTile(...)
    return self:_GetTileRecursive(self.tiles, self.dimensions, ...)
end

function Map:_GetTileRecursive(table, dimension, coord, ...)
    if dimension == 1 then
        return table[coord]
    else
        return self:_GetTileRecursive(table[coord], dimension - 1, ...)
    end
end

function Map:SetTileset(tileset)
    self.AssertArgumentType(tileset, TextureAtlas)

    self.tileset = tileset
end

function Map:SetTileOffset(dimension, xOffset, yOffset)
    self.xTileSize[dimension] = xOffset
    self.yTileSize[dimension] = yOffset
end

function Map:GetScreenPosition(...)
    local coords = {...}
    local x, y = 0, 0
    for i = 1, self.dimensions do
        x = x + self.xTileSize[i] * (coords[i] - 1)
        y = y + self.yTileSize[i] * (coords[i] - 1)
    end

    return x, y
end

-- given a screen position, find tiles that are on that position
function Map:GetTileCoordinates(x, y, validityCallback)
    --TODO: create a better solution than brute-forcing it!
    return self:_GetTileCoordinatesRecursive()
end

function Map:_GetTileCoordinatesRecursive(dimension)
end

function Map:draw()
    self.AssertArgumentType(self.tileset, TextureAtlas)

    self:_DrawRecursive(self.tiles, 1, 0, 0)
end

function Map:_DrawRecursive(table, dimension, currentX, currentY)
    for i = 1, #table do
        if dimension == self.dimensions then
            local tileType = table[i]:GetType()
            if tileType then
                self.tileset:DrawSprite(tileType, currentX, currentY)
            end
        else
            self:_DrawRecursive(table[i], dimension + 1, currentX, currentY)
        end
        currentX = currentX + self.xTileSize[dimension]
        currentY = currentY + self.yTileSize[dimension]
    end
end

local function recalculateEntityPosition(self, entity)
    local x, y = entity:GetX(), entity:GetY()
    local hl, hr, ht, hb = entity:GetHitRect()

    -- get current hit rect of player
    local l = hl + x
    local r = hr + x
    local t = ht + y
    local b = hb + y

    local topLeft = self:GetTile(math.floor(l), math.floor(t))
    local topRight = self:GetTile(math.floor(r), math.floor(t))
    local bottomLeft = self:GetTile(math.floor(l), math.floor(b))
    local bottomRight = self:GetTile(math.floor(r), math.floor(b))

    return x, y, l, r, b, t, hl, hr, ht, hb, topLeft, topRight, bottomLeft, bottomRight
end

function Map:ConstrainEntities(entities)
    --TODO: a better way would probably be to constrain the entity's movement, e.g. don't move up when there's a wall there
    local padding = 0.005
    for i = 1, entities:GetCount() do
        local entity = entities:Get(i)

        if entity:IsInstanceOf(Actor) then
            -- FIXME: this is really bad style...
            local x, y, l, r, b, t, hl, hr, ht, hb, topLeft, topRight, bottomLeft, bottomRight = recalculateEntityPosition(self, entity)

            -- first check if we are against a solid wall in one direction. changes can be applied immediately
            -- x constraints
            if topLeft:IsBlocking() and bottomLeft:IsBlocking() then
                entity:SetX(math.ceil(l) - hl + padding)
                x, y, l, r, b, t, hl, hr, ht, hb, topLeft, topRight, bottomLeft, bottomRight = recalculateEntityPosition(self, entity)
            elseif topRight:IsBlocking() and bottomRight:IsBlocking() then
                entity:SetX(math.floor(r) - hr - padding)
                x, y, l, r, b, t, hl, hr, ht, hb, topLeft, topRight, bottomLeft, bottomRight = recalculateEntityPosition(self, entity)
            end

            -- y constraints
            if topLeft:IsBlocking() and topRight:IsBlocking() then
                entity:SetY(math.ceil(t) - ht + padding)
                x, y, l, r, b, t, hl, hr, ht, hb, topLeft, topRight, bottomLeft, bottomRight = recalculateEntityPosition(self, entity)
            elseif bottomLeft:IsBlocking() and bottomRight:IsBlocking() then
                entity:SetY(math.floor(b) - hb - padding)
                x, y, l, r, b, t, hl, hr, ht, hb, topLeft, topRight, bottomLeft, bottomRight = recalculateEntityPosition(self, entity)
            end

            -- afterwards, handle corners by applying the smalles change necessary
            local newX, newY = nil, nil
            -- x constraints
            if topLeft:IsBlocking() or bottomLeft:IsBlocking() then
                newX = math.ceil(l) - hl + padding
            elseif topRight:IsBlocking() or bottomRight:IsBlocking() then
                newX = math.floor(r) - hr - padding
            end

            -- y constraints
            if topLeft:IsBlocking() or topRight:IsBlocking() then
                newY = math.ceil(t) - ht + padding
            elseif bottomLeft:IsBlocking() or bottomRight:IsBlocking() then
                newY = math.floor(b) - hb - padding
            end

            if newX and newY then
                local dx = math.abs(x - newX)
                local dy = math.abs(y - newY)

                if dx < dy then
                    entity:SetX(newX)
                    --TODO: check if y constraint is now fine
                else
                    entity:SetY(newY)
                    --TODO: check if x constraint is now fine
                end
            elseif newX then
                -- only x constraint, no problem
                entity:SetX(newX)
            elseif newY then
                -- only y constraint, no problem
                entity:SetY(newY)
            end
        end
    end
end
