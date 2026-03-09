--UI for the game. Main HUD is attached to game's resolution and everything else is attached to main HUD.
--I wanted not to use any numbers for any HUD elements since I think visual representation is much better.

UI = {}
UI.__index = UI

function UI:new(playerCharacter)
    local obj = setmetatable({},self)
    obj.mainHUD = love.graphics.newImage("Sprites/UI/mainHUD.png")
    obj.HPpoint = love.graphics.newImage("Sprites/UI/health.png")
    obj.bloodmoon = love.graphics.newImage("Sprites/UI/bloodmoon.png")
    obj.monsterpic = love.graphics.newImage("Sprites/UI/monsterpicture.png")
    obj.NPC = love.graphics.newImage("Sprites/UI/NPC.png")
    obj.NPC2 = love.graphics.newImage("Sprites/UI/NPC2.png")
    obj.sword = love.graphics.newImage("Sprites/UI/sword.png")
    return obj
end

function UI:update(dt)
end

function UI:draw(playerCharacter,gameStartHandler)
    --Main HUD
    local width = love.graphics.getWidth() - self.mainHUD:getWidth() - self.mainHUD:getWidth() / 8
    local height = 0 + self.mainHUD:getHeight() / 4
    love.graphics.draw(self.mainHUD,width,height)

    --HP
    local HUDwidth = self.mainHUD:getWidth() - self.mainHUD:getWidth() / 3.4
    local HUDHeight = self.mainHUD:getHeight() - self.mainHUD:getHeight() / 4
    local HPoffsetPerBar = 0

    for i = 1, playerCharacter.health do
        love.graphics.draw(self.HPpoint,width + HUDwidth - HPoffsetPerBar,height + HUDHeight,0,0.27)
        HPoffsetPerBar = HPoffsetPerBar + 18
    end

    --Blood moon timer
    local HUDwidthformoon = self.mainHUD:getWidth() - self.mainHUD:getWidth() / 12
    local HUDheightformoon = self.mainHUD:getHeight() - self.mainHUD:getHeight() / 2.3
    love.graphics.draw(self.bloodmoon,width + HUDwidthformoon,HUDheightformoon,0,0.4)

    local normalizedMonsterPictures = gameStartHandler.bloodMoonTimer / 8
    if normalizedMonsterPictures > 15 then normalizedMonsterPictures = 15 end

    local monsteroffsetPerMonster = 0
    for i = 1, normalizedMonsterPictures do
    love.graphics.draw(self.monsterpic, width + HUDwidth - monsteroffsetPerMonster, HUDheightformoon, 0,0.5)
    monsteroffsetPerMonster = monsteroffsetPerMonster + 20
    end


    --Number of knights and monsters
    local HUDwidthforNPC = self.mainHUD:getWidth() - self.mainHUD:getWidth() / 12
    local HUDheightforNPC = self.mainHUD:getHeight() - self.mainHUD:getHeight() / 1.5
    love.graphics.draw(self.NPC,width + HUDwidthforNPC,HUDheightforNPC,0,0.4)

    local normalizedNPCPictures = #gameStartHandler.enemyTable / 2
    local NPCoffsetPerNPC = 0
    if gameStartHandler.bloodMoonActive == true then
        self.NPC = self.monsterpic
        self.NPC2 = self.monsterpic
    end
    for i = 1, normalizedNPCPictures do
        love.graphics.draw(self.NPC2, width + HUDwidth - NPCoffsetPerNPC, HUDheightforNPC, 0,0.35)
        NPCoffsetPerNPC = NPCoffsetPerNPC + 20
    end

    if gameStartHandler.playerCharacter.attackTimer <= gameStartHandler.playerCharacter.attackCooldown then love.graphics.setColor(0,0,0,0.3) end
    love.graphics.draw(self.sword,
    love.graphics.getWidth() / 2 - 10,
    love.graphics.getHeight() / 2 - gameStartHandler.playerCharacter.height,
    0,
    0.3)
    love.graphics.setColor(1,1,1,1)
end

return UI