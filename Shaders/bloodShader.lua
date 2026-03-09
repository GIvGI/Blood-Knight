--Simple shader for blood moon
bloodShader = {}
bloodShader.__index = bloodShader
local shader_code = [[
#define NUM_LIGHTS 32
struct Light {
vec2 position;
vec3 diffuse;
float power;
};

extern Light lights[NUM_LIGHTS];
extern int num_lights;

extern vec2 screen;
const float constant = 1.0;
const float linear = 0.09;
const float quadratic = 0.032;

vec4 effect(vec4 color, Image image, vec2 uvs, vec2 screen_coords){
vec4 pixel = Texel(image, uvs);

vec2 norm_screen = screen_coords / screen;
vec3 diffuse = vec3(0);

for(int i = 0; i < num_lights; i++){
Light light = lights[i];
vec2 norm_pos = light.position / screen;
float distance = length(norm_pos - norm_screen) * light.power;
float attenuation = 1.0 / (constant + linear * distance + quadratic *
(distance * distance));

diffuse += light.diffuse * attenuation;
diffuse = clamp(diffuse, 0.0,1.0);
}

return pixel * vec4(diffuse, 1.0);
}
]]

function bloodShader:new()
    local obj = setmetatable({}, self)
    obj.shader = love.graphics.newShader(shader_code)

    obj.fullMoonY = 3000
    obj.fullMoonRiseSpeed = 800
    --Where the "brightness" of light starts and spreads to.
    obj.lightDiffusion = 600
    obj.brightnessLimit = 8
    return obj
end

function bloodShader:update(dt)
    if self.fullMoonY > 50 then
        self.fullMoonY = self.fullMoonY - self.fullMoonRiseSpeed * dt
        if self.lightDiffusion > self.brightnessLimit then
            self.lightDiffusion = self.lightDiffusion - 5
        end
    end
end

function bloodShader:draw()
    love.graphics.setShader(self.shader)
    self.shader:send("screen",{
        love.graphics.getWidth(),
        love.graphics.getHeight()
    })

    self.shader:send("num_lights",1)
    self.shader:send("lights[0].position", {
        love.graphics.getWidth() / 8,
        love.graphics.getHeight() / 8
    })
    self.shader:send("lights[0].diffuse",{
        1.0,0.0,0.0
    })
    self.shader:send("lights[0].power",self.lightDiffusion)

    love.graphics.setColor(1.0,0.0,0.0,1.0)
end

return bloodShader