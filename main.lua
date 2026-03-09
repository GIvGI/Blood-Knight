--I tried to make main.lua as clean and readable as possible. I took everything that was possible outside of main.lua into their own separate files.
local Config = require("config")

local Knight1 = require("Enemies/knight1")
local Knight2 = require("Enemies/knight2")
local Knight3 = require("Enemies/knight3")
local Monster1 = require("Enemies/monster1")

local BloodMoonHandler = require("Events/bloodmoonhandler")
local CRT = require("Shaders/CRTshader")

local CollisionHandler = require("Events/collisionhandler")
local TileMapGeneration = require("Events/tileMapGeneration")
local ObjectGeneration = require("Events/objectGeneration")
local GameStartHandler = require("Events/gameStartHandler")
local Player = require("player")

local Menu = require("menu")
local UI = require("UI")
require "camera"
function love.load()
    font = love.graphics.newFont("Fonts/gameFont.ttf",32)
    fullMoon = love.graphics.newImage("Sprites/World/fullMoon.png")
    CRTShader = CRT:new()
    menu = Menu:new()
    gameStartHandler = GameStartHandler:new()
    ui = UI:new(gameStartHandler.playerCharacter)

    fullMoonY = 3000
    --Rising speed of the moon
    fullMoonRiseSpeed = 1000

    --Game needs to use canvas for CRT Shader.
    canvas = love.graphics.newCanvas(
        love.graphics.getWidth(),
        love.graphics.getHeight()
    )
end

function love.update(dt)
    --Game handles its main state's updating and when it ends in main

    --If player dies or wins, then game ends.
    if gameStartHandler.collisionhandler.playerCharacter.health <= 0 then
        gameStartHandler.hasLost = true
        gameStartHandler.restartTimer = gameStartHandler.restartTimer + dt
        if gameStartHandler.restartTimer > gameStartHandler.restartCooldown then
            love.event.quit('restart')
        end
    end

    if gameStartHandler.bloodmoonhandler.playerWon == true then
        gameStartHandler.restartTimer = gameStartHandler.restartTimer + dt
        if gameStartHandler.restartTimer > gameStartHandler.restartCooldown then
            love.event.quit('restart')
        end
    end


    if menu.isGameStarted == true then
    gameStartHandler:update(dt)

    --Handling of camera
    if gameStartHandler.collisionhandler.playerCharacter.x > love.graphics.getWidth() / 2 then
    camera.x = gameStartHandler.collisionhandler.playerCharacter.x - love.graphics.getWidth() / 2
    end
    if gameStartHandler.collisionhandler.playerCharacter.y > love.graphics.getHeight() / 2 then
    camera.y = gameStartHandler.collisionhandler.playerCharacter.y - love.graphics.getHeight() / 2
    end

    --Blood moon rise "effect"
    if gameStartHandler.bloodMoonActive == true and fullMoonY > 50 then
        fullMoonY = fullMoonY - fullMoonRiseSpeed * dt
    end
end
end

function love.draw(dt)
    --Menu
    if menu.isGameStarted == false then
    menu:draw()
    end

    --Game
    if menu.isGameStarted == true then
    love.graphics.setCanvas(canvas)
    love.graphics.clear()
    camera:set()
    gameStartHandler:draw()
    camera:unset()

    if gameStartHandler.bloodMoonActive == true then
    love.graphics.draw(fullMoon,50,fullMoonY)
    end
    ui:draw(gameStartHandler.playerCharacter,gameStartHandler)

    --Text for game over
    love.graphics.setFont(font)
    if gameStartHandler.hasLost == true then
        local gameOverText = "GAME OVER!"
        local scale = 3
        love.graphics.setColor(1,0,0)
        love.graphics.rectangle("fill",0,0,love.graphics.getWidth(),love.graphics.getHeight())
        love.graphics.setColor(0,0,0)
        love.graphics.print(gameOverText,love.graphics.getWidth()/2 - font:getWidth(gameOverText)*scale/2,love.graphics.getHeight()/2 - font:getHeight(gameOverText)*scale/2,0,scale)
        love.graphics.setColor(1,0,0)
    end

    --Text when winning the game
    if gameStartHandler.bloodmoonhandler.playerWon == true then
        local gameOverText = "YOU WON!"
        local scale = 3
        love.graphics.setColor(0,0,0)
        love.graphics.print(gameOverText,love.graphics.getWidth()/2 - font:getWidth(gameOverText)*scale/2,love.graphics.getHeight()/2 - font:getHeight(gameOverText)*scale/2,0,scale)
        love.graphics.setColor(1,0,0)
    end

    love.graphics.setCanvas()

    CRTShader:draw()
    love.graphics.draw(canvas,0,0)
    love.graphics.setShader()
end
end

function love.keypressed(key)
    --Detecting player's attacks.
    if key == "space" then
        if gameStartHandler.collisionhandler.playerCharacter.attackTimer >= gameStartHandler.collisionhandler.playerCharacter.attackCooldown then
            gameStartHandler.collisionhandler.playerCharacter:Attack()

        --Blood particles is attached to pressing the key. vx and vy determines the range where blood particles spread. Life variable
        --determines how long these particles will stay in air. Number of iterations for the loop determines the number of particles in air.
        if gameStartHandler.playerCharacter.swordParticleActivated == true then   
            for i = 1,100 do
                gameStartHandler.swordParticle.particles[#gameStartHandler.swordParticle.particles + 1] = {
                x = gameStartHandler.playerCharacter.x + (40 * gameStartHandler.playerCharacter.direction),
                y = gameStartHandler.playerCharacter.y + 20,
                vx = love.math.random(-50,100),
                vy = love.math.random(-50,100),
                life = 1
            }
            end
        end
        end
    end
end