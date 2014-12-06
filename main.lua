require('classes/class')
require('classes/textureatlas')
require('classes/tiledtextureatlas')
require('classes/tile')
require('classes/map')
require('classes/entity')
require('classes/bullet')
require('classes/actor')
require('classes/player')
require('classes/enemy')
require('classes/dummy')
require('classes/entitymanager')
require('classes/menu')
require('classes/log')

function angle(x)
    -- helper function that makes sure angles are always between 0 and 360
    return x % 360
end

function lerp(min, max, percentile)
    -- linear interpolation between min and max
    return min + (max - min) * math.max(0, math.min(1, percentile))
end

function lerpAngle(min, max, percentile)
    -- linear interpolation for angles
    min = angle(min)
    max = angle(max)

    if min > max then
        -- switch everything around to make sure min is always less than max (necessary for next step)
        local temp = max
        max = min
        min = temp
        percentile = 1 - percentile
    end

    if math.abs(min - max) > 180 then
        -- interpolate in the opposite (shorter) direction by putting max on the other side of min
        max = max - 360
    end

    return angle(lerp(min, max, percentile))
end

local function LoadTextures()
    textures = TiledTextureAtlas("images/textures.png")
    --textures:SetTileSize(32, 32)
    textures:SetTilePadding(2, 2)
    textures:SetTileOffset(2, 2)
    textures:DefineTile("wall", 1, 1)
    textures:DefineTile("floor", 2, 1)

    textures:DefineTile("player", 1, 2)
    textures:DefineTile("dummy", 2, 2)
end

local function LoadSounds()
    sounds = {
        --[[menu = {
            love.audio.newSource("sounds/Menu.wav", "static"),
        },--]]
    }
end

function PlaySound(id)
    if sounds[id] then
        local sound = sounds[id][math.random(1, #sounds[id])]
        love.audio.rewind(sound)
        love.audio.play(sound)
    end
end

function love.load()
    debug = Log()
    debug:insert('initialized...')

    love.window.setTitle("Ludum Dare")
    love.window.setMode(1280, 720)

    LoadTextures()
    LoadSounds()

    global = {
        showDebug = true,
        state = 'game',
        keyspressed = {},
    }

    --[[menu = Menu()
    menu:AddItem("Exit", function()
        love.event.quit()
    end)--]]

    -- initialize simple map
    -- TODO: move to new function
    local width, height = 40, 22
    map = Map(width, height)
    map:SetTileset(textures)
    map:SetTileOffset(1, 16, 0)
    map:SetTileOffset(2, 0, 16)

    for x = 1, width do
        for y = 1, height do
            local tile = map:GetTile(x, y)
            tile:SetType('floor')

            if (x == 1 or y == 1 or x == width or y == height or love.math.noise(x / width, y / height) > 0.8) then
                tile:SetType('wall')
            end
        end
    end
    debug:insert('map initialized')

    -- initialize player
    entities = EntityManager()

    player = Player(5, 5)
    entities:AddEntity(player)

    -- initialize training dummy
    local dummy = Dummy(10, 5)
    entities:AddEntity(dummy)

    debug:insert('entities initialized')
end

function love.update(delta)
    entities:update(delta)

    map:ConstrainEntities(entities)
end

function love.draw()
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setBackgroundColor(32, 32, 32)
    love.graphics.clear()

    -- all game graphics should be rendered in here to get magnified by 2
    love.graphics.push()
    love.graphics.scale(2)

    map:draw()
    entities:draw()

    love.graphics.pop()

    -- show debug messages
    if global.showDebug then
        love.graphics.push()
        love.graphics.setColor(0, 0, 0, 255)
        debug:draw()
        love.graphics.pop()
    end
end

function love.keypressed(key, isRepeat)
    if not isRepeat then
        global.keyspressed[key] = true
    end
    if key == "escape" then
        love.event.quit()
    end
end

function love.keyreleased(key)
    global.keyspressed[key] = false
end
