--Game starter and controller class. Controls how the game starts and goes.

gameStartHandler = {}
gameStartHandler.__index = gameStartHandler

local Knight1 = require("Enemies/knight1")
local Knight2 = require("Enemies/knight2")
local Knight3 = require("Enemies/knight3")
local Monster1 = require("Enemies/monster1")
local SwordParticle = require("swordParticle")
local BloodMoonHandler = require("Events/bloodmoonhandler")
local CollisionHandler = require("Events/collisionhandler")
local TileMapGeneration = require("Events/tileMapGeneration")
local ObjectGeneration = require("Events/objectGeneration")
local Player = require("player")
local Config = require("config")

function gameStartHandler:new()
    local obj = setmetatable({},self)
    math.randomseed(os.time())

    obj.swordParticle = SwordParticle:new()

    obj.objectgeneration = ObjectGeneration:new()

    obj.screenW = Config.STANDARD_WIDTH
    obj.screenH = Config.STANDARD_HEIGHT
    obj.worldW = obj.screenW * Config.GLOBAL_SIZE_MULTIPLIER
    obj.worldH = obj.screenH * Config.GLOBAL_SIZE_MULTIPLIER
    obj.middleX = obj.worldW / 2
    obj.middleY = obj.worldH / 2


    --Player spawns in the middle of the map
    obj.playerCharacter = Player:new(obj.middleX,obj.middleY)
    obj.enemyTable = {}

    --Most important variables for game balance. They can be modified to make the game easier or more difficult.

    --Number of knights in the world. 
    obj.knight1Number = 5
    obj.knight2Number = 5
    obj.knight3Number = 10
    --Blood moon event timer.
    obj.bloodMoonCooldown = 180

    obj.bloodMoonTimer = obj.bloodMoonCooldown
    obj.bloodMoonActive = false

    obj.restartCooldown = 5
    obj.restartTimer = 0
    obj.hasLost = false

    obj.knightsRandomCoords = {}

    --Game generates a random coordinate, checks if it is safe (meaning if it doesn't overlap with any of the world objects)
    --and then spawns a knight in those coordinates. 10K iterations guarantee us that even if massive amount of overlaps happen
    --all spawnable knights will get safe coordinates.
    for i = 1, 10000 do
        local x,y
        local legalWidth = Config.STANDARD_WIDTH * Config.GLOBAL_SIZE_MULTIPLIER
        local legalHeight = Config.STANDARD_HEIGHT * Config.GLOBAL_SIZE_MULTIPLIER
        local safe = false
        while not safe do
            x = math.random((Config.STANDARD_WIDTH / 2) + 200,legalWidth - 200)
            y = math.random((Config.STANDARD_HEIGHT / 2) - 200,legalHeight - 200)
            safe = true

            for _, o in ipairs(obj.objectgeneration.objects) do
                local ox, oy = o.x, o.y
                local ow, oh = o.width, o.height

                if x + 200 > ox and x - 200 < ox + ow and y + 200 > oy and y - 200 < oy + oh then
                    safe = false
                    break
                end
            end

            if safe then
            table.insert(obj.knightsRandomCoords,x)
            table.insert(obj.knightsRandomCoords,y)
            break
            end
        end
    end

    --Loops to spawn knights themselves.
        local index = 1
        for i = 1, obj.knight1Number do
            table.insert(obj.enemyTable,Knight1:new(obj.knightsRandomCoords[index],obj.knightsRandomCoords[index+1]))
            index = index + 2
        end

        for i = 1, obj.knight2Number do
            table.insert(obj.enemyTable,Knight2:new(obj.knightsRandomCoords[index],obj.knightsRandomCoords[index+1]))
            index = index + 2
        end

        for i = 1, obj.knight3Number  do
            table.insert(obj.enemyTable,Knight3:new(obj.knightsRandomCoords[index],obj.knightsRandomCoords[index+1])) 
            index = index + 2
        end

    --These are separate 3 musketeers type knight formations. It would be really fun to add more knight aggregations 
    --and different formations in game.
        for i = 1, 3 do
            table.insert(obj.enemyTable,Knight1:new(obj.knightsRandomCoords[index], obj.knightsRandomCoords[index+1]))
            table.insert(obj.enemyTable,Knight1:new(obj.knightsRandomCoords[index] + 60,obj.knightsRandomCoords[index+1]))
            table.insert(obj.enemyTable,Knight1:new(obj.knightsRandomCoords[index] + 30,obj.knightsRandomCoords[index+1] + 60))
            index = index + 2
        end
    

    obj.bloodmoonhandler = BloodMoonHandler:new()
    obj.collisionhandler = CollisionHandler:new(obj.playerCharacter,obj.enemyTable)
    obj.currentEnemyNumber = obj.collisionhandler.currentEnemyNumber
    obj.tilemapgeneration = TileMapGeneration:new()
    return obj
end

function gameStartHandler:update(dt)
    self.tilemapgeneration:update(dt)
    self.objectgeneration:update(dt)
    self.collisionhandler:update(dt,self.enemyTable,self.objectgeneration)
    self.swordParticle:update(dt)


    self.bloodMoonTimer = self.bloodMoonTimer - dt
    if self.bloodMoonTimer <= 0 then
        --If level or wave system is added in this game, this bloodMoonTimer will be handler of its balance. Because we don't have these waves or levels, the player
        --basically has 1 hour or pratically unlimited time to kill all of the monsters in the first wave.
        self.bloodMoonTimer = 3600
        self.bloodMoonActive = true
        --During blood moon even, all knights should despawn and then bloodmoonhandler should start inserting/spawning monsters slowly.
        for i = self.currentEnemyNumber, 1, -1 do
            table.remove(self.enemyTable,i)
        end
    end

    if self.bloodMoonActive == true then
        self.bloodmoonhandler:update(dt,self.enemyTable,self.currentEnemyNumber)
    end

end

function gameStartHandler:draw(dt)
    if self.bloodMoonActive == true then
        self.bloodmoonhandler:draw()
    end
    self.tilemapgeneration:draw()
    self.objectgeneration:draw()
    self.collisionhandler:draw()
    self.swordParticle:draw()
end



return gameStartHandler