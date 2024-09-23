local love = require "love"
local enemy = require "Enemy"
local button = require "Button"
local SFX = require "SFX"

math.randomseed(os.time()) -- making enemies to always start from different places

local background -- declare the background variable 

local game = {
    difficulty = 1,
    state = {
        menu = true,
        paused = false,
        running = false,
        ended = false,
    },
    points = 0,
    levels = {15, 30, 60, 120} -- these are the levels which new enemies will spawn
}

local fonts = {
    medium = {
        font = love.graphics.newFont(12),
        size = 12
    },
    large = {
        font = love.graphics.newFont(24),
        size = 24
    },
    massive = {
        font = love.graphics.newFont(60),
        size = 60
    }
}

local bombs = {}
local bombExists = false -- Track if a bomb is active

-- Variables for shockwave effect for bomb
local shockwaveActive = false
local shockwaveRadius = 0
local maxShockwaveRadius = 100
local shockwaveSpeed = 200

local speed = 200 -- speed of the player movement

local sfx = SFX() -- Importing the Sound Effects

local player = {
    radius = 20,
    x = 30,
    y = 30
}

local buttons = {
    menu_state = {},
    ended_state = {}
}

local enemies = {}

local speedMessage = "" -- Message to display when speed increases
local speedMessageTimer = 0 -- Timer to control how long the message is displayed

local function changeGameState(state)
    game.state["menu"] = state == "menu"
    game.state["paused"] = state == "paused"
    game.state["running"] = state == "running"
    game.state["ended"] = state == "ended"
    game.state["help"] = state == "help"
end

local function showHelp()
    changeGameState("help")
end

local function startNewGame()
    changeGameState("running")

    game.points = 0

    enemies = {
        enemy(1)
    }
end

-- Create a bomb at player's location
function love.keypressed(key)
    if key == "space" and game.state["running"] then
        -- Only drop a bomb if there isn't one active
        if not bombExists then
            sfx:playFX("bomb_drop") -- Play bomb drop sound effect
            -- Create a bomb at the player's current position
            local bomb = {
                x = player.x,
                y = player.y,
                timer = 5 -- bomb will last 5 seconds before disappearing
            }
            table.insert(bombs, bomb) -- Add bomb to the list of bombs
            bombExists = true -- Mark that a bomb exists
        end
    elseif key == "escape" then
        -- Toggle between "paused" and "running" states when escape is pressed
        if game.state["paused"] then
            game.state["paused"] = false
            game.state["running"] = true
        elseif game.state["running"] then
            game.state["running"] = false
            game.state["paused"] = true
        end
    end
end

function activateShockwave(x, y)
    shockwaveActive = true
    shockwaveX = x
    shockwaveY = y
    shockwaveRadius = 0
end

function updateShockwave(dt)
    if shockwaveActive then
        shockwaveRadius = shockwaveRadius + shockwaveSpeed * dt
        if shockwaveRadius > maxShockwaveRadius then
            shockwaveActive = false
        end
    end
end

function drawShockwave()
    if shockwaveActive then
        love.graphics.setColor(0.5, 0.5, 1, 1) -- Increase opacity to 1
        love.graphics.circle("line", shockwaveX, shockwaveY, shockwaveRadius)
        love.graphics.setColor(1, 1, 1, 1) -- Reset color
    end
end


function love.mousepressed(x, y, button, istouch, presses)
    if not game.state["running"] then
        if button == 1 then
            if game.state["menu"] then
                for index in pairs(buttons.menu_state) do
                    buttons.menu_state[index]:checkPressed(x, y, player.radius)
                end
            elseif game.state["ended"] then
                for index in pairs(buttons.ended_state) do
                    buttons.ended_state[index]:checkPressed(x, y, player.radius)
                end
            elseif game.state["help"] then 
                buttons.help_state.back_to_menu:checkPressed(x, y, player.radius)
            end
        end
    end
end

function love.load()
    -- Load background image
    background = love.graphics.newImage("images/dojo2.png")

    -- Play Background Music
    sfx:playBGM()

    -- Load ninja image
    player.image = love.graphics.newImage("images/ninja1.png")

    love.mouse.setVisible(false)
    love.window.setTitle("Shuriken Ninja")

    buttons.menu_state.play_game = button("Play Game", startNewGame, nil, 120, 40)
    buttons.menu_state.help = button("Help", showHelp, nil, 120, 40)
    buttons.menu_state.exit_game = button("Exit Game", love.event.quit, nil, 120, 40)

    buttons.ended_state.replay_game = button("Replay", startNewGame, nil, 100, 50)
    buttons.ended_state.menu = button("Menu", changeGameState, "menu", 100, 50)
    buttons.ended_state.exit_game = button("Quit", love.event.quit, nil, 100, 50)

    -- Back button for help screen
    buttons.help_state = {}
    buttons.help_state.back_to_menu = button("Back", changeGameState, "menu", 120, 40)
end

function love.update(dt)
    if game.state["paused"] then
        return -- Stop updating if the game is paused
    end

    -- Bomb timer logic
    for i = #bombs, 1, -1 do
        bombs[i].timer = bombs[i].timer - dt
        if bombs[i].timer <= 0 then
            table.remove(bombs, i) -- Remove bomb after 5 seconds
            bombExists = false -- Allow a new bomb to be dropped
        end
    end

    -- Check for bomb collisions with enemies
    for _, bomb in ipairs(bombs) do
        for _, enemy in ipairs(enemies) do
            local distance = math.sqrt((bomb.x - enemy.x)^2 + (bomb.y - enemy.y)^2)
            if distance <= (bomb.radius or 10) + enemy.radius then -- Adjust the bomb radius if needed
                enemy:freeze() -- Freeze the enemy
                activateShockwave(bomb.x, bomb.y) -- Trigger the shockwave at bomb location
                break -- Exit the loop once a collision is detected
            end
            sfx:playFX("freeze") -- Play freeze sound effect
        end
    end

    -- Update shockwave effect
    updateShockwave(dt)

    -- Update enemies
    for _, enemy in ipairs(enemies) do
        enemy:update(dt)
    end

    -- player.x, player.y = love.mouse.getPosition()
    -- local speed = 200 -- speed of the player movement

    -- this makes the enemies chase the character only when the game is running
    if game.state["running"] then 
        -- Handle movement controls
        if love.keyboard.isDown("w") then
            player.y = player.y - speed * dt -- Move up
        end
        if love.keyboard.isDown("s") then
            player.y = player.y + speed * dt -- Move down
        end
        if love.keyboard.isDown("a") then
            player.x = player.x - speed * dt -- Move left
        end
        if love.keyboard.isDown("d") then
            player.x = player.x + speed * dt -- Move right
        end

        -- Clamp player position within the game window
        player.x = math.max(player.radius, math.min(player.x, love.graphics.getWidth() - player.radius))
        player.y = math.max(player.radius, math.min(player.y, love.graphics.getHeight() - player.radius))

        for i = 1, #enemies do
            if not enemies[i]:checkTouched(player.x, player.y, player.radius) then
                enemies[i]:move(player.x, player.y)

                -- Handle spawning new enemies at certain levels
                for i = 1, #game.levels do
                    if math.floor(game.points) == game.levels[i] then
                        table.insert(enemies, 1, enemy(game.difficulty * (i + 1)))

                        -- Increase player's speed by 5 when a new enemy spawns
                        speed = speed + 5 

                        -- Set the message and reset the timer when speed increases
                        speedMessage = "PLAYER SPEED + 5"
                        speedMessageTimer = 2 -- Display message for 2 seconds

                        game.points = game.points + 1
                    end
                end
            else
                changeGameState("ended")

                sfx:playFX("game_over")
            end
        end

        game.points = game.points + dt --adding a point every second

        -- Reduce the timer for the speed message
        if speedMessageTimer > 0 then
            speedMessageTimer = speedMessageTimer - dt
            if speedMessageTimer <= 0 then
                speedMessage = "" -- Clear the message when the timer ends
            end
        end

    else
        -- When the game is not running, use the mouse for menu interaction
        player.x, player.y = love.mouse.getPosition()
    end
end

function love.draw()
    -- scaling the background
    local bgWidth = background:getWidth()
    local bgHeight = background:getHeight()

    -- Calculate scale factors to fit the screen
    local scaleX = love.graphics.getWidth() / bgWidth
    local scaleY = love.graphics.getHeight() / bgHeight

    -- Draw and scale the background
    love.graphics.draw(background, 0, 0, 0, scaleX, scaleY)

    -- love.graphics.clear(43/255, 8/255, 66/255) -- for purple background color
    love.graphics.setFont(fonts.medium.font)
    love.graphics.printf("FPS: " .. love.timer.getFPS(), fonts.medium.font, 10, love.graphics.getHeight() - 30, love.graphics.getWidth()
)

    -- Draw the shockwave
    drawShockwave()

    if game.state["running"] then
        -- Draw the speed increase message at the top left corner
        if speedMessage ~= "" then
            love.graphics.setFont(fonts.medium.font)
            love.graphics.setColor(1, 1, 0) -- Set color to yellow for visibility
            love.graphics.printf(speedMessage, 10, 10, love.graphics.getWidth(), "left")
            love.graphics.setColor(1, 1, 1) -- Reset color to white
        end

        -- Draw game points
        love.graphics.printf(math.floor(game.points), fonts.large.font, 0, 10, love.graphics.getWidth(), "center")

        -- Draw enemies
        for i = 1, #enemies do
            enemies[i]:draw()
        end

        -- Draw player
        -- love.graphics.circle("fill", player.x, player.y, player.radius)

        -- Scale the image (e.g., 50% of its original size)
        local scale = 0.4

        -- Draw player(ninja) with scaling
        love.graphics.draw(player.image, player.x, player.y, 0, scale, scale, player.image:getWidth() / 2, player.image:getHeight() / 2)

        -- Draw the bombs
        for i = 1, #bombs do
            love.graphics.setColor(0, 0, 0) -- Set the color to black for the bomb
            love.graphics.circle("fill", bombs[i].x, bombs[i].y, 10) -- Draw bomb as a circle

            sfx:playFX("bomb_out")
        end

        -- Reset color back to white after drawing bombs
        love.graphics.setColor(1, 1, 1) -- Reset to white

    elseif game.state["paused"] then
        -- Draw the PAUSED text
        love.graphics.setFont(fonts.massive.font) -- Use a large font for the paused message
        love.graphics.setColor(1, 1, 1) -- Set text color to white
        love.graphics.printf("GAME PAUSED", 0, love.graphics.getHeight() / 2 - fonts.massive.size / 2, love.graphics.getWidth(), "center")
        
        -- Smaller note when paused "Press ESC to resume"
        love.graphics.setFont(fonts.large.font)
        love.graphics.printf("Press ESC to resume", 0, love.graphics.getHeight() / 2 + fonts.large.size, love.graphics.getWidth(), "center")

    elseif game.state["menu"] then
        buttons.menu_state.play_game:draw(10, 20, 10, 17)
        buttons.menu_state.help:draw(10, 70, 10, 17)
        buttons.menu_state.exit_game:draw(10, 120, 10, 17)

    elseif game.state["help"] then
        -- Set text color to black
        love.graphics.setColor(0, 0, 0) -- Black color (R, G, B)

        -- Help screen content
        love.graphics.setFont(fonts.large.font)
        love.graphics.printf("Objective: Escape the shurikens for as long as possible.\n Ninja Speed increases by 5 when a new enemy appears.\n Bombs Freeze shurikens.", 0, love.graphics.getHeight() / 4, love.graphics.getWidth(), "center")
        love.graphics.printf("Keys: \nW - Move Up\nS - Move Down\nA - Move Left\nD - Move Right\nSpace - Drop Bomb\nEscape - Pause", 0, love.graphics.getHeight() / 2 - 50, love.graphics.getWidth(), "center")

        -- Back button to return to the main menu
        buttons.help_state.back_to_menu:draw(10, love.graphics.getHeight() - 80, 10, 17)

    elseif game.state["ended"] then
        -- Draw end game screen
        love.graphics.setFont(fonts.large.font)

        buttons.ended_state.replay_game:draw(love.graphics.getWidth() / 2.25, love.graphics.getHeight() / 1.8, 10, 10)
        buttons.ended_state.menu:draw(love.graphics.getWidth() / 2.25, love.graphics.getHeight() / 1.53, 17, 10)
        buttons.ended_state.exit_game:draw(love.graphics.getWidth() / 2.25, love.graphics.getHeight() / 1.33, 22, 10)

        -- Draw score in the center of the screen
        love.graphics.printf(math.floor(game.points), fonts.massive.font, 0, love.graphics.getHeight() / 2 - fonts.massive.size, love.graphics.getWidth(), "center")
    end

    -- Draw smaller circle if not running
    if not game.state["running"] then
        love.graphics.circle("fill", player.x, player.y, player.radius / 2)
    end
end