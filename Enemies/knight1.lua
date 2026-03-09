--There are 3 types of basic enemies in this game. All three of them have very simple animations and AI states.
--1. First type just stands still on the map until he detects the player. After detecting the player, he starts attacking. He has 2 HP and upon taking a hit
--he starts running away from the player. [Since he can run, he encourages the player to pick up speed boost upgrades to catch up with him]
--Also, in his fleeing state if player gets too close to him, he starts panicking and freezes in place.

--2. Second type also stands still before he detects the player. He can't fight back, he can only shield himself. He has 5 HP.
--[Since he has 5HP, he encourages player to pick up attack cooldown upgrade to not waste teir valuable time]

--3. Third type walks randomly on the map. Has 1 HP and upon detecting the player he starts attacking.
--[Since he dies in one hit and wanders randomly, he encourages player to deal with him as soon the player detects him]

--StateController method handles animations and behaviours. Wipe logic is setting HP to -50 when knights die. Main update checks if hp == -50 then remove from table.
local Enemy = {}
Enemy.__index = Enemy

function Enemy:new(x,y)
    local obj = setmetatable({},self)

    --main variables
    obj.x = x
    obj.y = y
    obj.speed = 140 --Should be at most as player's speed.
    obj.health = 2
    obj.chaseDistance = 250 --Distance from where he starts chasing.
    obj.attackCloseness = 50 --Distance from where he starts attacking.
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

    obj.hit = love.audio.newSource("Audio/hitHurt.wav","static")
-- #endregion

-- #region Animations
        obj.animations.Run = {
        frames = {},
        currentFrame = 1,
        animationTimer = 0,
        frameRate = 0.2,
        spriteSheet = love.graphics.newImage("Sprites/Knight1/Run.png")
    }
    for i = 0, 6 do
        table.insert(obj.animations.Run.frames,
        love.graphics.newQuad(i* obj.quadWidth, 0, obj.quadWidth,obj.height, obj.animations.Run.spriteSheet:getDimensions())
    )
    end

        obj.animations.Idle = {
        frames = {},
        currentFrame = 1,
        animationTimer = 0,
        frameRate = 0.2,
        spriteSheet = love.graphics.newImage("Sprites/Knight1/Idle.png")
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
        spriteSheet = love.graphics.newImage("Sprites/Knight1/Attack.png")
    }
    for i = 0, 5 do
        table.insert(obj.animations.Attack.frames,
        love.graphics.newQuad(i* obj.quadWidth, 0, obj.quadWidth,obj.height, obj.animations.Attack.spriteSheet:getDimensions())
    )
    end


        obj.animations.Dead = {
        frames = {},
        currentFrame = 1,
        animationTimer = 0,
        frameRate = 0.2,
        spriteSheet = love.graphics.newImage("Sprites/Knight1/Dead.png")
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

    --flee
    if self.health == 1 then
        if distance < self.chaseDistance and distance > self.attackCloseness then
        self.currentState = self.PlayerStates.RUN
        self.x = self.x + math.cos(angle) * self.speed * dt * -1
        self.y = self.y + math.sin(angle) * self.speed * dt * -1
        self.direction = self.direction * -1
        end
    else
    
    --chase
    if distance < self.chaseDistance and distance > self.attackCloseness then
        self.currentState = self.PlayerStates.RUN
        self.x = self.x + math.cos(angle) * self.speed * dt
        self.y = self.y + math.sin(angle) * self.speed * dt
    end

    --attack
    if distance <= self.attackCloseness then
        self.currentState = self.PlayerStates.ATTACK
        self.attackTimer = self.attackTimer + dt
        if self.attackTimer >= self.attackCooldown then
        target.health = target.health - 1
        self.hit:play()
        self.attackTimer = 0
    end
    else
    self.attackTimer = 0
    end
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