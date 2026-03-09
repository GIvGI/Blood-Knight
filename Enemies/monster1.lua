--After blood moon timer runs out every knight transforms into this enemy type. it is stronger and can teleport near the player after the player
--goes too far away from it.
local Enemy = {}
Enemy.__index = Enemy

function Enemy:new(x,y)
    local obj = setmetatable({},self)

    --main variables
    obj.x = x
    obj.y = y
    obj.speed = 70 --Can teleport, doesn't need to be fast.
    obj.health = 1
    obj.chaseDistance = 100000 --Since it can teleport, it can always detect/chase the player.
    obj.attackCloseness = 75
    obj.minTeleportDistance = 20 --Minimum offset range of teleport from the player.
    obj.maxTeleportDistance = 120 --Maximum offset range of teleport from the player.
    obj.teleportTriggerDistance = 400 --Starts teleporting after player goes this far from it.
    obj.PlayerStates = {RUN = "run", IDLE = "idle", DEAD = "dead", ATTACK = "attack", TELEPORT = "teleport"}

-- #region auxiliary variables    
    obj.currentState = obj.PlayerStates.IDLE
    obj.prevState = nil
    obj.animations = {}
    obj.widthAnim = 64
    obj.heightAnim = 64
    obj.width = 128
    obj.height = 128
    obj.direction = 1

    obj.attackTimer = 0
    obj.attackCooldown = 0.8 --Most important variable, in terms of difficulty for this enemy type.

    obj.deathTimer = 0
    obj.deathCooldown = 1

    obj.teleportTimer = 0
    obj.teleportCooldown = 1.3
    obj.teleportPosX = self.x
    obj.teleportPosY = self.y
    obj.teleportTrigger = false

    obj.hit = love.audio.newSource("Audio/hitHurt.wav","static")
    obj.teleport = love.audio.newSource("Audio/click.wav","static")
-- #endregion

-- #region Animations
        obj.animations.Idle = {
        frames = {},
        currentFrame = 1,
        animationTimer = 0,
        frameRate = 0.2,
        spriteSheet = love.graphics.newImage("Sprites/Monster/monster.png")
    }
    for i = 0, 5 do
        table.insert(obj.animations.Idle.frames,
        love.graphics.newQuad(
            i* obj.widthAnim * 2,
            0,
            obj.widthAnim,
            obj.widthAnim,
            obj.animations.Idle.spriteSheet:getDimensions())
    )
    end

        obj.animations.Run = {
        frames = {},
        currentFrame = 1,
        animationTimer = 0,
        frameRate = 0.2,
        spriteSheet = love.graphics.newImage("Sprites/Monster/monster.png")
    }
        for i = 0, 6 do
        table.insert(obj.animations.Run.frames,
        love.graphics.newQuad(
            i* obj.widthAnim * 2,
            3 * obj.heightAnim,
            obj.widthAnim,
            obj.widthAnim,
            obj.animations.Run.spriteSheet:getDimensions())
    )
    end


        obj.animations.Attack = {
        frames = {},
        currentFrame = 1,
        animationTimer = 0,
        frameRate = 0.2,
        spriteSheet = love.graphics.newImage("Sprites/Monster/monster.png")
    }
        for i = 3, 10 do
        table.insert(obj.animations.Attack.frames,
        love.graphics.newQuad(
            i* obj.widthAnim * 2,
            4 * obj.heightAnim,
            obj.widthAnim,
            obj.widthAnim,
            obj.animations.Attack.spriteSheet:getDimensions())
    )
    end

        obj.animations.Teleport = {
        frames = {},
        currentFrame = 1,
        animationTimer = 0,
        frameRate = 0.2,
        spriteSheet = love.graphics.newImage("Sprites/Monster/monster.png")
    }
        for i = 0, 1 do
        table.insert(obj.animations.Teleport.frames,
        love.graphics.newQuad(
            i* obj.widthAnim * 2,
            6 * obj.heightAnim,
            obj.widthAnim,
            obj.widthAnim,
            obj.animations.Teleport.spriteSheet:getDimensions())
    )
    end


        obj.animations.TeleportParticle = {
        frames = {},
        currentFrame = 1,
        animationTimer = 0,
        frameRate = 0.1,
        spriteSheet = love.graphics.newImage("Sprites/Monster/Teleport.png")
    }
        for i = 0, 16 do
        table.insert(obj.animations.TeleportParticle.frames,
        love.graphics.newQuad(
            i * obj.width,
            0,
            obj.width,
            obj.width,
            obj.animations.TeleportParticle.spriteSheet:getDimensions())
    )
    end

        obj.animations.Dead = {
        frames = {},
        currentFrame = 1,
        animationTimer = 0,
        frameRate = 0.2,
        spriteSheet = love.graphics.newImage("Sprites/Monster/monster.png")
    }
        for i = 0, 7 do
        table.insert(obj.animations.Dead.frames,
        love.graphics.newQuad(
            i* obj.widthAnim * 2,
            7 * obj.heightAnim,
            obj.widthAnim,
            obj.widthAnim,
            obj.animations.Dead.spriteSheet:getDimensions())
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
        self.direction * 2,
        2,
        self.heightAnim / 2,
        self.heightAnim / 2
    )

    if self.teleportTrigger == true then
    local teleportQuad = self.animations.TeleportParticle.frames[self.animations.TeleportParticle.currentFrame]
        love.graphics.draw(
        self.animations.TeleportParticle.spriteSheet,
        teleportQuad,
        self.teleportPosX - 30,
        self.teleportPosY - 30,
        0,
        self.direction,
        1,
        self.heightAnim / 2,
        self.heightAnim / 2
    )
end
end

function Enemy:Attack(target,dt)
    local dx = target.x - self.x 
    local dy = target.y - self.y
    local angle = math.atan2(dy,dx)
    local distance = math.sqrt(dx^2 + dy^2)

    if dx < 0 then self.direction = -1 end
    if dx > 0 then self.direction = 1 end

    --teleport
    if distance > self.teleportTriggerDistance then
        if not self.teleportTrigger then
        self.currentState = self.PlayerStates.TELEPORT
        self.teleport:play()
        self.teleportTimer = 0
        self.teleportTrigger = true

        local offset = math.random(self.minTeleportDistance,self.maxTeleportDistance)
        self.teleportPosX = target.x - math.cos(angle) * offset
        self.teleportPosY = target.y - math.sin(angle) * offset
        end

        self.teleportTimer = self.teleportTimer + dt
        if self.teleportTimer >= self.teleportCooldown then
        self.teleportTimer = 0
        self.x = self.teleportPosX
        self.y = self.teleportPosY
        self.teleportTrigger = false
        end
        return
    end

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


function Enemy:StateController(target,dt)
    self.currentState = self.PlayerStates.IDLE

    
    if self.health > 0 then self:Attack(target,dt) end

    
    if self.health <= 0 then
        self.currentState = self.PlayerStates.DEAD
        self.deathTimer = self.deathTimer + dt
        if self.deathTimer >= self.deathCooldown then
            self.health = -50 --wipe logic
            self.deathTimer = 0
        end
    end

    local newAnimation = nil
    if self.currentState == self.PlayerStates.IDLE then
        newAnimation= self.animations.Idle
    end
    if self.currentState == self.PlayerStates.ATTACK then
        newAnimation = self.animations.Attack
    end
    if self.currentState == self.PlayerStates.RUN then
        newAnimation = self.animations.Run
    end
    if self.currentState == self.PlayerStates.DEAD then
        newAnimation = self.animations.Dead
    end
    if self.currentState == self.PlayerStates.TELEPORT then
        newAnimation = self.animations.Teleport
    end

    if self.prevState ~= self.currentState then
        self.currentAnimation = newAnimation
        self.currentAnimation.currentFrame = 1
        self.currentAnimation.animationTimer = 0
        self.prevState = self.currentState
    else
        self.currentAnimation = newAnimation
    end

    self.currentAnimation.animationTimer = self.currentAnimation.animationTimer + dt
    if self.currentAnimation.animationTimer >= self.currentAnimation.frameRate then
        self.currentAnimation.animationTimer = self.currentAnimation.animationTimer - self.currentAnimation.frameRate
        self.currentAnimation.currentFrame = self.currentAnimation.currentFrame  % #self.currentAnimation.frames + 1
    end

      self.animations.TeleportParticle.animationTimer = self.animations.TeleportParticle.animationTimer + dt
    if self.animations.TeleportParticle.animationTimer >= self.animations.TeleportParticle.frameRate then
        self.animations.TeleportParticle.animationTimer = self.animations.TeleportParticle.animationTimer - self.animations.TeleportParticle.frameRate
        self.animations.TeleportParticle.currentFrame = self.animations.TeleportParticle.currentFrame  % #self.animations.TeleportParticle.frames + 1
    end
end

return Enemy