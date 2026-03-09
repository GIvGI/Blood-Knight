--This class handles collisions for every entity and object.
local Config = require("config")
local Player = require("player")
local Knight3 = require("Enemies/knight3")
collisionhandler = {}
collisionhandler.__index = collisionhandler

function collisionhandler:new(playerCharacter, enemyTable)
    local obj = setmetatable({},self)
    math.randomseed(os.time())

    obj.playerCharacter = playerCharacter
    obj.enemyTable = enemyTable
    --We need this variable for when remaining knights are transformed into monsters.
    obj.currentEnemyNumber = #obj.enemyTable

    obj.playerCollisionTimer = 0
    obj.playerCollisionCooldown = 3

    obj.wipeLogicNumber = -50
    return obj
end

function collisionhandler:update(dt,enemyTable,objectgeneration)
    self.playerCharacter.swordParticleActivated = false
    self.playerCollisionTimer = self.playerCollisionTimer + dt

    local oldCollisionX, oldCollisionY = self.playerCharacter.x, self.playerCharacter.y
    self.playerCharacter:update(dt)

    --Checks collision between enemy NPCs and world objects.
    --Since knight3 can wander around, if he collides with an object. New wander point is selected so that he doesn't get stuck in infinite walking loop.
    for key, enemy in pairs(enemyTable) do
    
        local oldCollisionEnemyX, oldCollisionEnemyY = enemy.x, enemy.y
        enemy:update(dt,self.playerCharacter)

        for _, obj in ipairs(objectgeneration.objects) do
            if self:rectsCollideforObjects(enemy,obj) then
            enemy.x = oldCollisionEnemyX
            enemy.y = oldCollisionEnemyY
            if getmetatable(enemy) == Knight3 then
                enemy.wanderPointX = math.random(enemy.x - enemy.wanderLength, enemy.x + enemy.wanderLength)
                enemy.wanderPointY = math.random(enemy.y - enemy.wanderLength, enemy.y + enemy.wanderLength)
            end 
            end
        end
        
        --Checks collision between the player and enemy NPCs. Enemy NPC takes damage only when the player is in attack state.
        if self:rectsCollide(self.playerCharacter,enemy) then
        self.playerCharacter.swordParticleActivated = true
        if self.playerCharacter.currentState == self.playerCharacter.PlayerStates.ATTACK1
        or self.playerCharacter.currentState == self.playerCharacter.PlayerStates.ATTACK2
        or self.playerCharacter.currentState == self.playerCharacter.PlayerStates.ATTACK3 then
            if self.playerCollisionTimer >= self.playerCollisionCooldown then
                enemy.health = enemy.health - 1
                self.playerCharacter.hit:play()
                self.playerCollisionTimer = 0
            end
        end
    end 

    --Removing dead NPC from table.
    if enemy.health == self.wipeLogicNumber then
        table.remove(enemyTable,key)
        self.currentEnemyNumber = self.currentEnemyNumber - 1
    end


    end

    --Collisions between the player and world objects.
    --Since pines dont have rectangular shapes, they have custom collisions.
    local pine1 = love.graphics.newImage("Sprites/Objects/Trees/Tree1.png")
    local pine2 = love.graphics.newImage("Sprites/Objects/Trees/Tree2.png")
    for _, obj in ipairs(objectgeneration.objects) do

        if (pine1:getWidth() == obj.width and pine1:getHeight() == obj.height)
        or (pine2:getWidth() == obj.width and pine2:getHeight() == obj.height) then
            if self:rectsCollideforPines(self.playerCharacter,obj) then
                self.playerCharacter.x = oldCollisionX
                self.playerCharacter.y = oldCollisionY
            end
        else
            
        if self:rectsCollideforObjects(self.playerCharacter,obj) then
            self.playerCharacter.x = oldCollisionX
            self.playerCharacter.y = oldCollisionY
        end
    end
    end

    --Collision handling for power up objects.
    for _, obj in ipairs(objectgeneration.points) do
        if self:rectsCollide(self.playerCharacter,obj) then
            if obj.type == "health" then
                self.playerCharacter.health = self.playerCharacter.health + 1
                table.remove(objectgeneration.points,_)
                self.playerCharacter.powerUp:play()
            end

            if obj.type == "boots" then
                self.playerCharacter.speed = self.playerCharacter.speed + 50
                table.remove(objectgeneration.points,_)
                self.playerCharacter.powerUp:play()
            end

            if obj.type == "sword" then
                --If we give the player faster attacks then this, then we also have to increase the rate of monsters spawning during blood moon,
                --so that the player isn't able to spawn camp them as soon as they spawn.
                if self.playerCharacter.attackCooldown > 2 then
                self.playerCharacter.attackCooldown = self.playerCharacter.attackCooldown - 0.3
                self.playerCollisionCooldown = self.playerCharacter.attackCooldown
                self.playerCharacter.powerUp:play()
                end
                table.remove(objectgeneration.points,_)
            end
        end
    end

    --knight3 was naturally able to go out of map bounds by wandering. I didn't bother adding constraints to this because it encourages the player
    --even more to deal with them as soon as they are detected so they don't go out of bounds.
    for _, obj in ipairs(enemyTable) do if getmetatable(obj) ~= Knight3 then self:BoundryCheck(obj) end end
    self:BoundryCheck(self.playerCharacter)
end



function collisionhandler:draw()
    self.playerCharacter:draw()
    for key, value in pairs(self.enemyTable) do
        value:draw()
    end

    self:DrawBoundries()
end





--Standard rectangle collision
function collisionhandler:rectsCollide(a, b)
    local aLeft = a.x - a.width/2
    local aRight = a.x + a.width/2
    local aTop = a.y - a.height/2
    local aBottom = a.y + a.height/2
    
    local bLeft = b.x - b.width/2
    local bRight = b.x + b.width/2
    local bTop = b.y - b.height/2
    local bBottom = b.y + b.height/2 

    return aLeft < bRight and aRight > bLeft and aTop < bBottom and aBottom > bTop
end

--Custom function for world object collisions
function collisionhandler:rectsCollideforObjects(a, b)
    local playerhitBoxX = 64
    local playerhitboxY = 64
    local offsetY = playerhitboxY / 2
    local aLeft   = a.x - playerhitBoxX / 2
    local aRight  = a.x + playerhitBoxX / 2
    local aTop    = a.y - playerhitboxY / 2 + offsetY
    local aBottom = a.y + playerhitboxY / 2 + offsetY

    local scaleWidth = b.width / 2
    local scaleHeight = b.height / 2
    local bLeft   = b.x + scaleWidth / 2
    local bRight  = b.x + b.width - scaleWidth / 2
    local bTop    = b.y + scaleHeight / 2
    local bBottom = b.y + b.height - scaleHeight / 2

    return aLeft < bRight and aRight > bLeft and aTop < bBottom and aBottom > bTop
end

--Almost same function as above, except player is able to walk through very top part of pines so collisions feel more natural.
function collisionhandler:rectsCollideforPines(a, b)
    local playerhitBoxX = 64
    local playerhitboxY = 64
    local offsetY = playerhitboxY / 2
    local aLeft   = a.x - playerhitBoxX / 2
    local aRight  = a.x + playerhitBoxX / 2
    local aTop    = a.y - playerhitboxY / 2 + offsetY
    local aBottom = a.y + playerhitboxY / 2 + offsetY

    local scaleWidth = b.width / 2
    local scaleHeight = b.height / 2
    local bLeft   = b.x + scaleWidth / 2
    local bRight  = b.x + b.width - scaleWidth / 2
    local bTop    = b.y + scaleHeight / 1.5
    local bBottom = b.y + b.height - scaleHeight / 2

    return aLeft < bRight and aRight > bLeft and aTop < bBottom and aBottom > bTop
end


--Boundries of the world. UI, camera and other stuff was the reason why boundry doesnt start from (0,0).
function collisionhandler:BoundryCheck(character)
    local worldWidth = Config.STANDARD_WIDTH * Config.GLOBAL_SIZE_MULTIPLIER
    local worldHeight = Config.STANDARD_HEIGHT * Config.GLOBAL_SIZE_MULTIPLIER

    if character.x < Config.STANDARD_WIDTH / 2 then character.x = Config.STANDARD_WIDTH / 2
    elseif character.x + character.width > worldWidth then character.x = worldWidth - character.width end
    if character.y < Config.STANDARD_HEIGHT / 2 then character.y = Config.STANDARD_HEIGHT / 2
    elseif character.y + character.height > worldHeight then character.y = worldHeight - character.height end
end

--There should be much better approach than this to visually draw boundries. Since boundries are just coordinates in the function above and also since
--minimum boundries start not from (0,0) but from half of standard width and height, it was very frustrating to perfectly allign these lines visually. 
function collisionhandler:DrawBoundries()
    local screenWidth = Config.STANDARD_WIDTH * 5
    local screenHeight = Config.STANDARD_HEIGHT * 5
    local horizontalOffset = Config.STANDARD_WIDTH / 2
    local verticalOffset = Config.STANDARD_HEIGHT / 2
    love.graphics.setColor(1,0,0,0.8) --red looks good
    love.graphics.rectangle("fill",horizontalOffset,verticalOffset,5,screenHeight - verticalOffset - self.playerCharacter.height/2) --left
    love.graphics.rectangle("fill",horizontalOffset,verticalOffset,screenWidth - horizontalOffset - self.playerCharacter.height,5) --top

    love.graphics.rectangle("fill",horizontalOffset,screenHeight - self.playerCharacter.height/2,screenWidth - horizontalOffset - self.playerCharacter.width + 5,5) --bottom
    love.graphics.rectangle("fill",screenWidth - self.playerCharacter.width,verticalOffset,5,screenHeight - verticalOffset - self.playerCharacter.height/2) -- right
end

return collisionhandler