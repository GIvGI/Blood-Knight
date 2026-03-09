--CRT shader to enhance the visuals of this game.

CRT = {}
CRT.__index = CRT

--This shader has 2 basic viarbles, warp and scan. Warp didn't look right so i lowered it to minimum. Most visually appealing effect is given by scan = 1.0
local shader_code = [[
extern vec2 resolution;

float warp = 0.1; // curvature
float scan = 1.0; // scanline intensity

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    // Normalize screen coordinates
    vec2 uv = screen_coords / resolution;

    // squared distance from center
    vec2 dc = abs(0.5 - uv);
    dc *= dc;

    // warp coordinates
    uv.x -= 0.5;
    uv.x *= 1.0 + (dc.y * (0.3 * warp));
    uv.x += 0.5;

    uv.y -= 0.5;
    uv.y *= 1.0 + (dc.x * (0.4 * warp));
    uv.y += 0.5;

    float apply = abs(sin(screen_coords.y) * 0.5 * scan);

    vec3 texColor = Texel(texture, uv).rgb;
    texColor = mix(texColor, vec3(0.0), apply);

    return vec4(texColor, 1.0) * color;
}
]]

function CRT:new()
    local obj = setmetatable({}, self)
    obj.shader = love.graphics.newShader(shader_code)
    obj.shader:send("resolution", {love.graphics.getWidth(), love.graphics.getHeight()})
    return obj
end

function CRT:update(dt)
    self.shader:send("resolution", {love.graphics.getWidth(), love.graphics.getHeight()})
end

function CRT:draw()
    love.graphics.setShader(self.shader)
end

return CRT
