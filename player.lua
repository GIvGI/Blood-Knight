--Player class

local Player = {}
Player.__index = Player

function Player:new(x,y)
    local obj = setmetatable({},self)

    --main variables
    obj.x = x
    obj.y = y
    obj.speed = 170
    obj.health = 15
    obj.PlayerStates = {RUN = "run", IDLE = "idle", HURT = "hurt", DEAD = "dead", ATTACK1 = "attack", ATTACK2 = "attack2", ATTACK3 = "attack3"}

    --auxiliary variables
    obj.currentState = obj.PlayerStates.IDLE
    obj.animations = {}
    obj.direction = 1
    obj.quadWidth = 128
    obj.width = 64
    obj.height = 75

    obj.attackCooldown = 3
    obj.attackTimer = obj.attackCooldown
    obj.isAttacking = false
    obj.isAttackingTimer = 0
    obj.isAttackingCooldown = 1
    obj.swordParticleActivated = false

    obj.hit = love.audio.newSource("Audio/hitHurt.wav","static")
    obj.powerUp = love.audio.newSource("Audio/powerUp.wav","static")



-- #region ANIMATIONS
    obj.animations.Run = {
        frames = {},
        currentFrame = 1,
        animationTimer = 0,
        frameRate = 0.2,
        spriteSheet = love.graphics.newImage("Sprites/Player/Run.png")
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
        spriteSheet = love.graphics.newImage("Sprites/Player/Idle.png")
    }
    for i = 0, 3 do
        table.insert(obj.animations.Idle.frames,
        love.graphics.newQuad(i* obj.quadWidth, 0, obj.quadWidth,obj.height, obj.animations.Idle.spriteSheet:getDimensions())
    )
    end



        obj.animations.Hurt = {
        frames = {},
        currentFrame = 1,
        animationTimer = 0,
        frameRate = 0.2,
        spriteSheet = love.graphics.newImage("Sprites/Player/Hurt.png")
    }
    for i = 0, 1 do
        table.insert(obj.animations.Hurt.frames,
        love.graphics.newQuad(i* obj.quadWidth, 0, obj.quadWidth,obj.height, obj.animations.Hurt.spriteSheet:getDimensions())
    )
    end



        obj.animations.Dead = {
        frames = {},
        currentFrame = 1,
        animationTimer = 0,
        frameRate = 0.2,
        spriteSheet = love.graphics.newImage("Sprites/Player/Dead.png")
    }
    for i = 0, 5 do
        table.insert(obj.animations.Dead.frames,
        love.graphics.newQuad(i* obj.quadWidth, 0, obj.quadWidth,obj.height, obj.animations.Dead.spriteSheet:getDimensions())
    )
    end

        obj.animations.Attack1 = {
        frames = {},
        currentFrame = 1,
        animationTimer = 0,
        frameRate = 0.15,
        spriteSheet = love.graphics.newImage("Sprites/Player/Attack1.png")
    }
    for i = 0, 4 do
        table.insert(obj.animations.Attack1.frames,
        love.graphics.newQuad(i* obj.quadWidth, 0, obj.quadWidth,obj.height, obj.animations.Attack1.spriteSheet:getDimensions())
    )
    end


        obj.animations.Attack2 = {
        frames = {},
        currentFrame = 1,
        animationTimer = 0,
        frameRate = 0.15,
        spriteSheet = love.graphics.newImage("Sprites/Player/Attack2.png")
    }
    for i = 0, 3 do
        table.insert(obj.animations.Attack2.frames,
        love.graphics.newQuad(i* obj.quadWidth, 0, obj.quadWidth,obj.height, obj.animations.Attack2.spriteSheet:getDimensions())
    )
    end


        obj.animations.Attack3 = {
        frames = {},
        currentFrame = 1,
        animationTimer = 0,
        frameRate = 0.15,
        spriteSheet = love.graphics.newImage("Sprites/Player/Attack3.png")
    }
    for i = 0, 3 do
        table.insert(obj.animations.Attack3.frames,
        love.graphics.newQuad(i* obj.quadWidth, 0, obj.quadWidth,obj.height, obj.animations.Attack3.spriteSheet:getDimensions())
    )
    end
    obj.currentAnimation = obj.animations.Idle
-- #endregion

    return obj
end

function Player:update(dt)
    self.attackTimer = self.attackTimer + dt

    self:StateController(dt)

    if self.health > 15 then self.health = 15 end
end


function Player:draw()
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

    --Visual collision box just in case for debugging.
    --love.graphics.setColor(1,0,0,0.5)
    --love.graphics.rectangle("fill", left, top, self.width, self.height)
    --love.graphics.setColor(1,1,1,1)
end

function Player:StateController(dt)
    if not self.isAttacking then
        self.currentState = self.PlayerStates.IDLE
    else
        self.isAttackingTimer = self.isAttackingTimer + dt
    end
    if self.isAttackingTimer >= self.isAttackingCooldown then
        self.isAttacking = false
        self.isAttackingTimer = 0
    end
    self.currentAnimation.animationTimer = self.currentAnimation.animationTimer + dt
    if self.currentAnimation.animationTimer >= self.currentAnimation.frameRate then
        self.currentAnimation.animationTimer = self.currentAnimation.animationTimer - self.currentAnimation.frameRate
        self.currentAnimation.currentFrame = self.currentAnimation.currentFrame  % #self.currentAnimation.frames + 1
    end

    self:MovementController(dt)

    if self.currentState == self.PlayerStates.RUN then
        self.currentAnimation = self.animations.Run
    end
    if self.currentState == self.PlayerStates.IDLE then
        self.currentAnimation = self.animations.Idle
    end
    if self.currentState == self.PlayerStates.DEAD then
        self.currentAnimation = self.animations.Dead
    end
    if self.currentState == self.PlayerStates.HURT then
        self.currentAnimation = self.animations.Hurt
    end
    if self.currentState == self.PlayerStates.ATTACK1 then
        self.currentAnimation = self.animations.Attack1
    end
    if self.currentState == self.PlayerStates.ATTACK2 then
        self.currentAnimation = self.animations.Attack2
    end
    if self.currentState == self.PlayerStates.ATTACK3 then
        self.currentAnimation = self.animations.Attack3
    end
end

function Player:MovementController(dt)
    local move_v = 0
    local move_h = 0
    if love.keyboard.isDown("s") and not self.isAttacking then move_v = 1 self.currentState = self.PlayerStates.RUN end
    if love.keyboard.isDown("w") and not self.isAttacking then move_v = -1 self.currentState = self.PlayerStates.RUN end
    if love.keyboard.isDown("a") and not self.isAttacking then move_h = -1 self.currentState = self.PlayerStates.RUN end
    if love.keyboard.isDown("d") and not self.isAttacking then move_h = 1 self.currentState = self.PlayerStates.RUN end
    if love.keyboard.isDown("f") then self.currentState = self.PlayerStates.DEAD end
    if love.keyboard.isDown("r") then self.currentState = self.PlayerStates.HURT end
    
    local dir = math.atan2(move_v,move_h)

    if move_v ~= 0 or move_h ~= 0 then
        if move_h < 0 then self.direction = -1
        elseif move_h > 0 then self.direction = 1 end
        self.x = self.x + math.cos(dir) * self.speed * dt
        self.y = self.y + math.sin(dir) * self.speed * dt
    end
end

function Player:Attack(target)
    self.animations.Attack1.currentFrame = 1
    self.animations.Attack2.currentFrame = 1
    self.animations.Attack3.currentFrame = 1

    --The player has 3 attack animations, which is picked randomly during attacking.
    --First animation is 0.15 seconds longer than others so it takes more time for player to attack.
    local attackRandomAnimation = math.random(1,3)
    if attackRandomAnimation == 1 then
        self.currentState = self.PlayerStates.ATTACK1
        self.isAttackingCooldown = 0.8
    end
    if attackRandomAnimation == 2 then
        self.currentState = self.PlayerStates.ATTACK2
        self.isAttackingCooldown = 0.65
    end
    if attackRandomAnimation == 3 then
        self.currentState = self.PlayerStates.ATTACK3
        self.isAttackingCooldown = 0.65
    end
    self.attackTimer = 0
    self.isAttacking = true
    self.isAttackingTimer = 0
end

return Player