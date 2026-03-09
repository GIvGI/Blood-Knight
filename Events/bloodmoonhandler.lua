--The event when all knights tranform into monsters.

local BloodShader = require("Shaders/bloodShader")
local Monster1 = require("Enemies/monster1")
bloodmoonhandler = {}
bloodmoonhandler.__index = bloodmoonhandler

function bloodmoonhandler:new(numberofMonsters)
    local obj = setmetatable({},self)
    obj.bloodShader = BloodShader:new()
    obj.numberofMonsters = 0

    obj.monsterSpawnTimer = 0
    --Important variable for balancing. Determines how fast monsters spawn.
    obj.monsterSpawnCooldown = 1.5
    obj.maxNumberofMonstersCounter = 0

    obj.playerWon = false
    return obj
end

function bloodmoonhandler:update(dt,enemyTable,numMonsters)
    self.numberofMonsters = numMonsters
    self.bloodShader:update(dt)
    self.monsterSpawnTimer = self.monsterSpawnTimer + dt
    if self.monsterSpawnTimer >= self.monsterSpawnCooldown and self.maxNumberofMonstersCounter < self.numberofMonsters then
        table.insert(enemyTable,Monster1:new(100,100)) -- Since monsters have unlimited teleport distance, doesnt matter where we spawn them.
        self.maxNumberofMonstersCounter = self.maxNumberofMonstersCounter + 1
        self.monsterSpawnTimer = 0
    end

    --next(enemyTable) checks if the table is empty or not, if it is then the player has killed all monsets and has won the game.
    if self.maxNumberofMonstersCounter >= self.numberofMonsters
    and next(enemyTable) == nil then
        self.playerWon = true
    end
end

function bloodmoonhandler:draw()
    self.bloodShader:draw()
end

return bloodmoonhandler