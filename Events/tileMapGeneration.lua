--This class handles generation of tiles or grass on the map. I wrote this before i knew how to make grid systems in game.
--Was considering remaking this with grids but there is really no reason to add grid system in this game other than this.

grassShader = {}
grassShader.__index = grassShader
local Config = require("config")

local tileMapGeneration = {}
tileMapGeneration.__index = tileMapGeneration
function tileMapGeneration:new()
local obj = setmetatable({}, self)
    obj.globalSizeMultiplier = Config.GLOBAL_SIZE_MULTIPLIER
    obj.screenWidth = Config.STANDARD_WIDTH * (obj.globalSizeMultiplier + 1)
    obj.screenHeight = Config.STANDARD_HEIGHT * (obj.globalSizeMultiplier + 1)
    obj.tileset = love.graphics.newImage("Sprites/Objects/tiles.png")
    obj.tileWidth = Config.TILE_SIZE
    obj.tileHeight = Config.TILE_SIZE
    obj.numberXtiles = (obj.screenWidth / obj.tileWidth) + 1
    obj.numberYtiles = (obj.screenHeight / obj.tileHeight) + 1
    obj.tilesTotal = obj.numberXtiles * obj.numberYtiles

    --Extra coordinates for grass patches and flowers.
    obj.tileRandomCoords = {}
    for i = 1, 100 do
        table.insert(obj.tileRandomCoords,math.random(0,obj.screenWidth))
    end
    --Array for randomly picked sequence of tiles.
    obj.grassPatchSequence = {}
    for i = 1, obj.tilesTotal do
        table.insert(obj.grassPatchSequence,math.random(1,9))
    end
    --Handpicked quads from the sprite i use for grass
    obj.grassQuads = {
        love.graphics.newQuad(0,0,obj.tileWidth,obj.tileHeight,obj.tileset:getDimensions()),
        love.graphics.newQuad(24,0,obj.tileWidth,obj.tileHeight,obj.tileset:getDimensions()),
        love.graphics.newQuad(24*2,0,obj.tileWidth,obj.tileHeight,obj.tileset:getDimensions()),
        love.graphics.newQuad(24*3,0,obj.tileWidth,obj.tileHeight,obj.tileset:getDimensions()),
        love.graphics.newQuad(0,24,obj.tileWidth,obj.tileHeight,obj.tileset:getDimensions()),
        love.graphics.newQuad(24*2,24,obj.tileWidth,obj.tileHeight,obj.tileset:getDimensions()),
        love.graphics.newQuad(0,24*2,obj.tileWidth,obj.tileHeight,obj.tileset:getDimensions()),
        love.graphics.newQuad(24,24*2,obj.tileWidth,obj.tileHeight,obj.tileset:getDimensions()),
        love.graphics.newQuad(24*2,24*2,obj.tileWidth,obj.tileHeight,obj.tileset:getDimensions()),
    }
    obj.grassPatchQuad = love.graphics.newQuad(24,24,obj.tileWidth,obj.tileHeight,obj.tileset:getDimensions())
    obj.flowerQuad = love.graphics.newQuad(24*8,0,obj.tileWidth,obj.tileHeight,obj.tileset:getDimensions())
    obj.flower2Quad = love.graphics.newQuad(24*8,24,obj.tileWidth,obj.tileHeight,obj.tileset:getDimensions())
    return obj
end

function tileMapGeneration:update(dt)
end

function tileMapGeneration:draw()
    --Fill the screen with randomly generated grasses
    local k = 1
    for y = 0, self.screenHeight, self.tileHeight do
        for x = 0, self.screenWidth, self.tileWidth do
            love.graphics.draw(self.tileset,self.grassQuads[self.grassPatchSequence[k]],x,y)
            k = k + 1
        end
    end
    --Add extra flowers and grass patches
    for i = 0, 100 do
    if i < 20 then love.graphics.draw(self.tileset,self.grassPatchQuad,self.tileRandomCoords[i],self.tileRandomCoords[i+1]) end
    if i > 20 and i < 60 then love.graphics.draw(self.tileset,self.flowerQuad,self.tileRandomCoords[i],self.tileRandomCoords[i+1]) end
    if i > 60 and i < 100 then love.graphics.draw(self.tileset,self.flower2Quad,self.tileRandomCoords[i],self.tileRandomCoords[i+1]) end
    end

end

return tileMapGeneration
