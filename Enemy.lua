local love = require "love"

-- Function to draw a six-spiked shuriken
local function drawShuriken(x, y, radius)
    local spikes = 6
    local angleStep = math.pi / spikes
    local points = {}

    for i = 0, spikes * 2 - 1 do
        local angle = i * angleStep
        local len = (i % 2 == 0) and radius or radius / 2 -- Alternating between outer and inner points
        local px = x + math.cos(angle) * len
        local py = y + math.sin(angle) * len
        table.insert(points, px)
        table.insert(points, py)
    end

    love.graphics.setColor(0.5, 0.5, 0.5)  -- Set color for the shuriken (grayish)
    love.graphics.polygon("fill", points)   -- Draw the shuriken
    love.graphics.setColor(1, 1, 1)         -- Reset color to white
end

-- Function to load the shuriken image
local shurikenImage = love.graphics.newImage("images/shuriken2.png")

function Enemy(level)
    local dice = math.random(1, 4) -- side which the enemy will appear from
    local _x, _y
    local _radius = 20 -- default size for enemies

    -- position initialization

    if dice == 1 then 
        _x = math.random(_radius, love.graphics.getWidth())
        _y = -_radius * 4
    elseif dice == 2 then 
        _x = -_radius * 4
        _y = math.random(_radius, love.graphics.getHeight())
    elseif dice == 3 then 
        _x = math.random(_radius, love.graphics.getWidth())
        _y = love.graphics.getHeight() + (_radius * 4)
    else 
        _x = love.graphics.getWidth() + (_radius * 4)
        _y = math.random(_radius, love.graphics.getHeight())
    end

    return {
        level = level or 1,
        radius = _radius,
        x = _x,
        y = _y,
        frozen = false,
        freezeTimer = 0,
        rotation = 0,  -- Add rotation property
        rotationSpeed = 3, -- Speed of rotation, adjust this for faster/slower spinning

        checkTouched = function (self, player_x, player_y, cursor_radius)
            return math.sqrt((self.x - player_x) ^ 2 + (self.y - player_y) ^ 2) <= cursor_radius * 2
        end,

        move = function (self, player_x, player_y)
            if not self.frozen then
                if player_x - self.x > 0 then
                    self.x = self.x + self.level
                elseif player_x - self.x < 0 then
                    self.x = self.x - self.level
                end

                if player_y - self.y > 0 then
                    self.y = self.y + self.level
                elseif player_y - self.y < 0 then
                    self.y = self.y - self.level
                end
            end
        end,

        freeze = function (self)
            self.frozen = true
            self.freezeTimer = 5 -- Freeze for 5 seconds
        end,

        update = function (self, dt)
            if self.frozen then
                self.freezeTimer = self.freezeTimer - dt
                if self.freezeTimer <= 0 then
                    self.frozen = false -- Unfreeze after 5 seconds
                end
            else
                -- Update rotation for spinning effect only if not frozen
                self.rotation = self.rotation + self.rotationSpeed * dt

                -- Ensure the rotation angle doesn't grow indefinitely
                if self.rotation >= 2 * math.pi then
                    self.rotation = self.rotation - 2 * math.pi
                end
            end

        end,

        draw = function (self)
            love.graphics.setColor(self.frozen and 0.5 or 1, 0.5, 0.5) -- Change color if frozen
            -- love.graphics.setColor(1, 0.5, 0.7)
            -- love.graphics.circle("fill", self.x, self.y, self.radius)
            -- love.graphics.setColor(1, 1, 1)
            -- drawShuriken(self.x, self.y, self.radius) -- shuriken drawing

            local scale = self.radius / (shurikenImage:getWidth() / 3)  -- Adjust the scale based on the radius
            love.graphics.draw(shurikenImage, self.x, self.y, self.rotation, scale, scale, shurikenImage:getWidth() / 2, shurikenImage:getHeight() / 2)
        end
    }
end

return Enemy