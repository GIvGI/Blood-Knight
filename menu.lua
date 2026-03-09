--Very simple menu

Menu = {}
Menu.__index = Menu

BUTTON_HEIGHT = 64

local function newButton(text,fn)
    return {
        text = text,
        fn = fn,

        now = false,
        last = false
    }
end

local buttons = {}
local font = nil

function Menu:new()
    local obj = setmetatable({},self)
    font = love.graphics.newFont("Fonts/gameFont.ttf",32)
    Titlefont = love.graphics.newFont("Fonts/gameFont.ttf",128)
    obj.isGameStarted = false

    moonBackground = love.graphics.newImage("Sprites/World/moonBackground.png")
    obj.CRTShader = CRT:new()
    obj.canvas = love.graphics.newCanvas(
        love.graphics.getWidth(),
        love.graphics.getHeight()
    )

    table.insert(buttons, newButton(
        "Start Game",
        function()
            obj.isGameStarted = true
        end))

    table.insert(buttons, newButton(
        "Exit",
        function()
            love.event.quit(0)
        end))

    return obj
end
function Menu:draw()
    local ww = love.graphics.getWidth()
    local wh = love.graphics.getHeight()
    love.graphics.setColor(1,0,0,1)
    love.graphics.rectangle("fill",0,0,love.graphics.getWidth(),love.graphics.getHeight())
    love.graphics.draw(moonBackground,0,0,0,3,3)

    love.graphics.setFont(Titlefont)
    love.graphics.setColor(1,1,1,1)
    local title = "Blood Knight"
    local titleW = Titlefont:getWidth(title)
    local titleX = ww / 2 - titleW / 2
    love.graphics.print(title, titleX, BUTTON_HEIGHT )

    love.graphics.setFont(font)

    local button_width = ww * (1/4)
    local margin = 16
    local total_height = (BUTTON_HEIGHT + margin) * #buttons
    local cursor_y = 0
    for i, button in ipairs(buttons) do
        button.last = button.now
        local bx = (ww * 0.5) - (button_width * 0.5)
        local by = (wh * 0.5) - (total_height * 0.5) + cursor_y

        local color = {1,0.207,0.207,1.0}
        local mx,my = love.mouse.getPosition()
        local hot = mx > bx and mx < bx + button_width and
                    my > by and my < by + BUTTON_HEIGHT

        if hot then
            color = {1,0.27,0.27,1.0}
        end

        button.now = love.mouse.isDown(1)
        if button.now and not button.last and hot then
            button.fn()
        end

        love.graphics.setColor(unpack(color))
        love.graphics.rectangle(
            "fill",
            bx,
            by,
            button_width,
            BUTTON_HEIGHT
        )

        love.graphics.setColor(0,0,0,1)

        local textW = font:getWidth(button.text)
        local textH = font:getHeight(button.text)
        love.graphics.print(
            button.text,
            font,
            (ww * 0.5) - textW * 0.5,
            by + textH * 0.5
        )

        cursor_y = cursor_y + (BUTTON_HEIGHT + margin)
    end 
end

return Menu