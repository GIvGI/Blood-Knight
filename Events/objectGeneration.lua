--Class which handles generation of objects and power ups in the world.

local Config = require("config")
local objectGeneration = {}
objectGeneration.__index = objectGeneration

--Function to pick random image from a folder
local function pickRandomImage(folder)
    local files = love.filesystem.getDirectoryItems(folder)
    if #files == 0 then return nil end
    local file = files[math.random(1, #files)]
    return love.graphics.newImage(folder .. "/" .. file)
end


function objectGeneration:new()
    local obj = setmetatable({}, self)

    --General variables for this class 
    obj.globalSizeMultiplier = Config.GLOBAL_SIZE_MULTIPLIER
    obj.generalObjectDensity = 50

    --Secondary variables
    obj.ruinsDensity = 40
    obj.rocksDensity = 30
    obj.safeDistanceFromCenter = 200
    obj.distanceBetweenObjectsMultiplier = 2

    --Number of power ups in the world
    obj.bootsNumber = 10
    obj.hpPotionNumber = 10
    obj.swordUpgradeNumber = 10

    obj.points = {}


    --Auxiliary variables
    obj.generationIterationNumber = obj.generalObjectDensity * 100
    obj.healthPotion = love.graphics.newImage("Sprites/WorldUpgrades/healthpotion.png")
    obj.boots = love.graphics.newImage("Sprites/WorldUpgrades/boots.png")
    obj.sword = love.graphics.newImage("Sprites/WorldUpgrades/sword.png")
    obj.healPotionWidth = obj.healthPotion:getWidth() / 4
    obj.healthPotionHeight = obj.healthPotion:getHeight() / 4


    --Amount of objects in the world, basically their density is made for 1920x1080 resolution
    obj.objectSet = {}
    local j = 1
    for i=1, obj.generalObjectDensity do
        j = j + 1
        table.insert(obj.objectSet,pickRandomImage("Sprites/Objects/Bushes"))
        table.insert(obj.objectSet,pickRandomImage("Sprites/Objects/Trees"))
        if j < obj.ruinsDensity then table.insert(obj.objectSet,pickRandomImage("Sprites/Objects/Ruins")) end
        if j < obj.rocksDensity then table.insert(obj.objectSet,pickRandomImage("Sprites/Objects/Rocks")) end
    end

    --Coordinates generation
    obj.objects = {}
    for i = 1, #obj.objectSet do
        local sprite = obj.objectSet[i]
        local spriteWidth = sprite:getWidth()
        local spriteHeight = sprite:getHeight()
        local x,y
        local valid = false

        for k = 1, obj.generationIterationNumber do
            x = math.random(0,Config.STANDARD_WIDTH * obj.globalSizeMultiplier - spriteWidth)
            y = math.random(0,Config.STANDARD_HEIGHT * obj.globalSizeMultiplier - spriteHeight)
            while math.abs(x - Config.STANDARD_WIDTH * obj.globalSizeMultiplier / 2) < obj.safeDistanceFromCenter and math.abs(y - Config.STANDARD_HEIGHT * 5 / 2) < obj.safeDistanceFromCenter do
                x = math.random(0,Config.STANDARD_WIDTH * obj.globalSizeMultiplier - spriteWidth)
                y = math.random(0,Config.STANDARD_HEIGHT * obj.globalSizeMultiplier - spriteHeight)
            end

            valid = true
            for _, other in ipairs(obj.objects) do
                local dx = other.x - x
                local dy = other.y - y 
                if math.sqrt(dx*dx+dy*dy) < spriteWidth * obj.distanceBetweenObjectsMultiplier then
                    valid = false
                    break
                end

                local screenW = Config.STANDARD_WIDTH * obj.globalSizeMultiplier
                local screenH = Config.STANDARD_HEIGHT * obj.globalSizeMultiplier
                local middleSectionX = screenW / obj.globalSizeMultiplier * 2
                local middleSectionY = screenH / obj.globalSizeMultiplier * 2

                if x >= middleSectionX and x <= middleSectionX + Config.STANDARD_WIDTH and
                   y >= middleSectionY and y <= middleSectionY + Config.STANDARD_HEIGHT then
                    valid = false
                end
            end
            if valid then break end
        end



        if valid then
            table.insert(obj.objects, 
            {image = sprite,
            x=x,
            y=y,
            width = spriteWidth,
            height = spriteHeight,})
        end
    end



    local indexJ = 1
    for i = 1, obj.bootsNumber do
        obj:spawnPoint()
        obj.points[indexJ].type = "boots"
        indexJ = indexJ + 1
    end
    for i = 1, obj.hpPotionNumber do
        obj:spawnPoint()
        obj.points[indexJ].type = "health"
        indexJ = indexJ + 1
    end

    for i = 1, obj.swordUpgradeNumber do
        obj:spawnPoint()
        obj.points[indexJ].type = "sword"
        indexJ = indexJ + 1
    end


    return obj
end

function objectGeneration:update(dt)
end

function objectGeneration:draw()
    for _, o in ipairs(self.objects) do
        love.graphics.draw(o.image, o.x, o.y)
    end

    local drawable = nil
    for _, p in ipairs(self.points) do
        if p.type == "health" then drawable = self.healthPotion end
        if p.type == "boots" then drawable = self.boots end
        if p.type == "sword" then drawable = self.sword end
        love.graphics.draw(drawable,p.x,p.y,0,0.5)
    end
end

--Points are considered power ups. this function uses same logic for coordinates not to overlap.
function objectGeneration:spawnPoint()
    local i = 0
    while i ~= 1 do
        local x = math.random(0, Config.STANDARD_WIDTH * self.globalSizeMultiplier)
        local y = math.random(0, Config.STANDARD_HEIGHT * self.globalSizeMultiplier)
        local valid = true


        for _, other in ipairs(self.objects) do
            if x + self.healPotionWidth > other.x and x < other.x + other.width and
               y + self.healPotionWidth > other.y and y < other.y + other.height then
                valid = false
                break
            end
        end


        if valid then
            table.insert(self.points,
            {x=x,
            y=y,
            width = self.healPotionWidth,
            height = self.healthPotionHeight,
            type = nil
            })
            i = 1
            return
        end
    end
end

return objectGeneration
