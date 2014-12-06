Tile = class()

function Tile:construct()
    self.tileType = nil
end

function Tile:SetType(tileType)
    self.tileType = tileType
end

function Tile:GetType()
    return self.tileType
end

function Tile:IsBlocking()
    return self.tileType == 'wall'
end