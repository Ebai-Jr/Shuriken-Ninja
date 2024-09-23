local love = require "love"

function SFX()
    -- bgm = background music
    local bgm = love.audio.newSource("sounds/background.mp3", "stream")
    bgm:setVolume(0.2)
    bgm:setLooping(true)

    local effects = {
        bomb_out = love.audio.newSource("sounds/bomb-out.mp3", "static"),
        game_over = love.audio.newSource("sounds/game-over.mp3", "static"),
        freeze = love.audio.newSource("sounds/freeze.mp3", "static"),
        bomb_drop = love.audio.newSource("sounds/bomb-drop.mp3", "static"),
    }

    return {
        fx_played = false,

        setFXPlayed = function (self, has_played)
            self.fx_played = has_played
        end, 

        playBGM = function (self)
            if not bgm:isPlaying() then
                bgm:play()
            end
        end,

        stopFX = function (self, effect)
            if effects[effect]:isPlaying() then
                effects[effect]:stop()
            end
        end,

        playFX = function (self, effect, mode)
            if mode == "single" then
                if not self.fx_played then
                    self:setFXPlayed(true)

                    if not effects[effect]:isPlaying() then
                        effects[effect]:play()
                    end
                end
            elseif mode == "slow" then
                if not effects[effect]:isPlaying() then
                    effects[effect]:play()
                end

            else
                self:stopFX(effect)

                effects[effect]:play()
            end
        end
    }
end

return SFX