--I found this particle online which was supposed to be fireworks. By modifying color and size of particles fireworks were remade into blood effects.

swordParticle = {}
swordParticle.__index = swordParticle

function swordParticle:new()
    local obj = setmetatable({}, self)
    obj.particles = {}
    return obj 
end

function swordParticle:update(dt)
    for i = #self.particles, 1, -1 do
        local p = self.particles[i]
        p.x,p.y = p.x + p.vx * dt, p.y + p.vy * dt
        p.vy, p.life = p.vy + 400 * dt, p.life - dt
        if p.life <= 0 then
            table.remove(self.particles,i)
        end
    end
end

function swordParticle:draw()
    for _, p in ipairs(self.particles) do
        love.graphics.setColor(1,p.life/5,0.2)
        love.graphics.circle("fill",p.x,p.y,1)
    end
    love.graphics.setColor(1,1,1)
end

return swordParticle