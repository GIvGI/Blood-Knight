--Documentation for this class is written in knight1.lua

local Enemy = {}
Enemy.__index = Enemy

function Enemy:new(x,y)
    local obj = setmetatable({},self)

    --main variables
    obj.x = x
    obj.y = y
    obj.speed = 50
    obj.health = 5
    obj.chaseDistance = 250
    obj.attackCloseness = 80
    obj.PlayerStates = {RUN = "run", IDLE = "idle", DEAD = "dead", ATTACK = "attack"}

-- #region auxiliary variables    
    obj.currentState = obj.PlayerStates.IDLE
    obj.animations = {}
    obj.quadWidth = 128
    obj.width = 64
    obj.height = 64
    obj.direction = 1

    obj.attackTimer = 0
    obj.attackCooldown = 1

    obj.deathTimer = 0
    obj.deathCooldown = 1
-- #endregion

-- #region Animations
        obj.animations.Run = {
        frames = {},
        currentFrame = 1,
        animationTimer = 0,
        frameRate = 0.2,
        spriteSheet = love.graphics.newImage("Sprites/Knight2/Walk.png")
    }
    for i = 0, 7 do
        table.insert(obj.animations.Run.frames,
        love.graphics.newQuad(i* obj.quadWidth, 0, obj.quadWidth,obj.height, obj.animations.Run.spriteSheet:getDimensions())
    )
    end

        obj.animations.Idle = {
        frames = {},
        currentFrame = 1,
        animationTimer = 0,
        frameRate = 0.2,
        spriteSheet = love.graphics.newImage("Sprites/Knight2/Idle.png")
    }
    for i = 0, 3 do
        table.insert(obj.animations.Idle.frames,
        love.graphics.newQuad(i* obj.quadWidth, 0, obj.quadWidth,obj.height, obj.animations.Idle.spriteSheet:getDimensions())
    )
    end


        obj.animations.Attack = {
        frames = {},
        currentFrame = 1,
        animationTimer = 0,
        frameRate = 0.2,
        spriteSheet = love.graphics.newImage("Sprites/Knight2/Protect.png")
    }
    for i = 0, 0 do
        table.insert(obj.animations.Attack.frames,
        love.graphics.newQuad(i* obj.quadWidth, 0, obj.quadWidth,obj.height, obj.animations.Attack.spriteSheet:getDimensions())
    )
    end


        obj.animations.Dead = {
        frames = {},
        currentFrame = 1,
        animationTimer = 0,
        frameRate = 0.2,
        spriteSheet = love.graphics.newImage("Sprites/Knight2/Dead.png")
    }
    for i = 0, 5 do
        table.insert(obj.animations.Dead.frames,
        love.graphics.newQuad(i* obj.quadWidth, 0, obj.quadWidth,obj.height, obj.animations.Dead.spriteSheet:getDimensions())
    )
    end

    obj.currentAnimation = obj.animations.Idle
-- #endregion

    return obj
end

function Enemy:update(dt,target)
    self:StateController(target,dt)
end

function Enemy:draw()
    local currentQuad = self.currentAnimation.frames[self.currentAnimation.currentFrame]
    love.graphics.draw(
        self.currentAnimation.spriteSheet,
        currentQuad,
        self.x,
        self.y,
        0,
        self.direction,
        1,
        self.width / 2,
        self.height / 2
    )

    local left = self.x - self.width/2
    local top  = self.y - self.height/2
end

function Enemy:Attack(target,dt)
    local dx = target.x - self.x 
    local dy = target.y - self.y
    local angle = math.atan2(dy,dx)
    local distance = math.sqrt(dx^2 + dy^2)

    if dx < 0 then self.direction = -1 end
    if dx > 0 then self.direction = 1 end
    
    --chase
    if distance < self.chaseDistance and distance > self.attackCloseness then
        self.currentState = self.PlayerStates.RUN
        self.x = self.x + math.cos(angle) * self.speed * dt
        self.y = self.y + math.sin(angle) * self.speed * dt
    end
    --attack
    if distance <= self.attackCloseness then
        self.currentState = self.PlayerStates.ATTACK
    end
end


function Enemy:StateController(target,dt)
    self.currentState = self.PlayerStates.IDLE
    self.currentAnimation.animationTimer = self.currentAnimation.animationTimer + dt
    if self.currentAnimation.animationTimer >= self.currentAnimation.frameRate then
        self.currentAnimation.animationTimer = self.currentAnimation.animationTimer - self.currentAnimation.frameRate
        self.currentAnimation.currentFrame = self.currentAnimation.currentFrame  % #self.currentAnimation.frames + 1
    end

    
    if self.health > 0 then self:Attack(target,dt) end

    
    if self.health <= 0 then
        self.currentState = self.PlayerStates.DEAD
        self.deathTimer = self.deathTimer + dt
        if self.deathTimer >= self.deathCooldown then
            self.health = -50 --wipe logic
            self.deathTimer = 0
        end
    end


    if self.currentState == self.PlayerStates.IDLE then
        self.currentAnimation = self.animations.Idle
    end
    if self.currentState == self.PlayerStates.ATTACK then
        self.currentAnimation = self.animations.Attack
    end
    if self.currentState == self.PlayerStates.RUN then
        self.currentAnimation = self.animations.Run
    end
    if self.currentState == self.PlayerStates.DEAD then
        self.currentAnimation = self.animations.Dead
    end
end

return Enemy