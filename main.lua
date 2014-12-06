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
require('classes/exit')
require('classes/entitymanager')
require('classes/menu')
require('classes/log')

local mapData = {
    'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
    'x                                      x',
    'x                                      x',
    'x                                      x',
    'x                                      x',
    'x                                      x',
    'x                                      x',
    'x                                      x',
    'x                                      x',
    'x                                      x',
    'x                                      x',
    'x                                      x',
    'x                           xx#xx      x',
    'x                           x   x      x',
    'x                           x>  x      x',
    'x                           x>  x      x',
    'x                           x>  x      x',
    'x                           x>  x      x',
    'xxxxxxxxxx#xxxxxxxxxxxxxxxxxx>  x      x',
    'x       x   x               x>  x      x',
    'e       #   #             0 x>  x      n',
    'x       x   x               x p x      x',
    'xxxxxxxxxx#xxxxxxxxxxxxxxxxxxx#xxxxxxxxx',
    'x             x                 x      x',
    'x ^^^^^^^ ^^^ x                 x      x',
    'x           ^ x                 #      x',
    'x           ^ x                 x      x',
    'x           ^ x                 x      x',
    'x   ^^^^^^  ^ x                 x      x',
    'x             xxxxxxxxxxxxxxxxxxx      x',
    'x             x             x          x',
    'x             x             x          x',
    'x             x             x          x',
    'xxxxx#xxxxxxxxx             x          x',
    'x             x             x          x',
    'x             x             x          x',
    'x             x             x          x',
    'x             x             x          x',
    'x             x             x          x',
    'x             x             x          x',
    'x             #             x          x',
    'x             x             #          x',
    'x             x             x          x',
    'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
}

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
    local width, height = 40, 44
    map = Map(width, height)
    map:SetTileset(textures)
    map:SetTileOffset(1, 16, 0)
    map:SetTileOffset(2, 0, 8)

    entities = EntityManager()

    for y = 1, height do
        local line = mapData[y]
        for x = 1, width do
            local char = line:sub(x, x)
            local tile = map:GetTile(x, y)
            tile:SetType('floor')

            if char == 'x' then
                tile:SetType('wall')
            elseif char == 'p' then
                -- initialize player
                player = Player(x, y) -- intentionally global variable
                entities:AddEntity(player)
            elseif char == '0' then
                -- initialize training dummy
                local dummy = Dummy(x, y)
                entities:AddEntity(dummy)
            elseif char == 'e' then
                -- initialize exit
                local exit = Exit(x, y)
                entities:AddEntity(exit)
            end
        end
    end
    debug:insert('map initialized')
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
