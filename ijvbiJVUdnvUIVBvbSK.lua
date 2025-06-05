local MODULE = {}

local PLAYERS = game:GetService("Players")
local USER_INPUT_SERVICE = game:GetService("UserInputService")
local STARTER_GUI = game:GetService("StarterGui")

local CAMERA = workspace.CurrentCamera

local LOCK_INDICATOR = nil
local TARGET_HIGHLIGHT = nil
local LOCKED_TARGET = nil
local TARGET_PLAYER_NAME = nil
local TARGET_LIST = {}
local CURRENT_TARGET_INDEX = 1
local MULTI_TARGET_ENABLED = false
local DOWN_CHECK = true

local SECTION_1 = nil
local SECTION_2 = nil
local SECTION_3 = nil

function MODULE.INIT(S1, S2, S3, VARS)
    SECTION_1 = S1
    SECTION_2 = S2
    SECTION_3 = S3
    
    if VARS then
        LOCK_INDICATOR = VARS.LOCK_INDICATOR
        TARGET_HIGHLIGHT = VARS.TARGET_HIGHLIGHT
        LOCKED_TARGET = VARS.LOCKED_TARGET
        TARGET_PLAYER_NAME = VARS.TARGET_PLAYER_NAME
        TARGET_LIST = VARS.TARGET_LIST or {}
        CURRENT_TARGET_INDEX = VARS.CURRENT_TARGET_INDEX or 1
        MULTI_TARGET_ENABLED = VARS.MULTI_TARGET_ENABLED or false
        DOWN_CHECK = VARS.DOWN_CHECK or true
    end
    
    return MODULE
end

function MODULE.UPDATE_VARS(VARS)
    if VARS then
        LOCK_INDICATOR = VARS.LOCK_INDICATOR
        TARGET_HIGHLIGHT = VARS.TARGET_HIGHLIGHT
        LOCKED_TARGET = VARS.LOCKED_TARGET
        TARGET_PLAYER_NAME = VARS.TARGET_PLAYER_NAME
        TARGET_LIST = VARS.TARGET_LIST or TARGET_LIST
        CURRENT_TARGET_INDEX = VARS.CURRENT_TARGET_INDEX or CURRENT_TARGET_INDEX
        MULTI_TARGET_ENABLED = VARS.MULTI_TARGET_ENABLED or MULTI_TARGET_ENABLED
        DOWN_CHECK = VARS.DOWN_CHECK or DOWN_CHECK
    end
    
    return {
        LOCK_INDICATOR = LOCK_INDICATOR,
        TARGET_HIGHLIGHT = TARGET_HIGHLIGHT,
        LOCKED_TARGET = LOCKED_TARGET,
        TARGET_PLAYER_NAME = TARGET_PLAYER_NAME,
        TARGET_LIST = TARGET_LIST,
        CURRENT_TARGET_INDEX = CURRENT_TARGET_INDEX,
        MULTI_TARGET_ENABLED = MULTI_TARGET_ENABLED,
        DOWN_CHECK = DOWN_CHECK
    }
end

function MODULE.CLEAR_LOCK()
    if LOCK_INDICATOR then
        LOCK_INDICATOR:Destroy()
        LOCK_INDICATOR = nil
    end
    if TARGET_HIGHLIGHT then
        TARGET_HIGHLIGHT:Destroy()
        TARGET_HIGHLIGHT = nil
    end

    if SECTION_3 and SECTION_3.IS_CURRENTLY_SPECTATING and SECTION_3.IS_CURRENTLY_SPECTATING() then
        SECTION_3.STOP_SPECTATING()
    end

    LOCKED_TARGET = nil
    TARGET_PLAYER_NAME = nil

    if not MULTI_TARGET_ENABLED then
        TARGET_LIST = {}
        CURRENT_TARGET_INDEX = 1
        if SECTION_2 and SECTION_2.CLEAR_ALL_TARGET_HIGHLIGHTS then
            SECTION_2.CLEAR_ALL_TARGET_HIGHLIGHTS()
        end
    end
    
    return MODULE.UPDATE_VARS()
end

function MODULE.SETUP_TARGET_TRACKING(PLAYER)
    if not PLAYER then return end
    
    local function ON_CHARACTER_ADDED(CHARACTER)
        if not CHARACTER then return end

        if PLAYER.Name == TARGET_PLAYER_NAME then
            LOCKED_TARGET = PLAYER
            task.wait(0.5)
            if SECTION_2 and SECTION_2.CREATE_LOCK_INDICATOR and SECTION_1 and SECTION_1.IS_PLAYER_DOWNED_OR_DEAD then
                local indicator, highlight = SECTION_2.CREATE_LOCK_INDICATOR(CHARACTER, DOWN_CHECK, SECTION_1.IS_PLAYER_DOWNED_OR_DEAD, PLAYER)
                LOCK_INDICATOR = indicator
                TARGET_HIGHLIGHT = highlight
            end

            STARTER_GUI:SetCore("SendNotification", {
                Title = "Target Reconnected", 
                Text = "Lock reapplied to " .. PLAYER.Name,
                Duration = 1,
                Icon = "rbxthumb://type=AvatarHeadShot&id=" .. PLAYER.UserId .. "&w=150&h=150"
            })

            if SECTION_3 and SECTION_3.IS_CURRENTLY_SPECTATING and SECTION_3.IS_CURRENTLY_SPECTATING() then
                local HUMANOID = PLAYER.Character:FindFirstChildOfClass("Humanoid")
                if HUMANOID then
                    CAMERA.CameraSubject = HUMANOID
                end
            end
        end

        if MULTI_TARGET_ENABLED and table.find(TARGET_LIST, PLAYER) then
            local ALREADY_IN_LIST = false
            for _, TARGET in ipairs(TARGET_LIST) do
                if TARGET.Name == PLAYER.Name then
                    ALREADY_IN_LIST = true
                    break
                end
            end

            if not ALREADY_IN_LIST then
                table.insert(TARGET_LIST, PLAYER)
                if SECTION_2 and SECTION_2.UPDATE_TARGET_LIST_HIGHLIGHTS and SECTION_1 and SECTION_1.IS_PLAYER_DOWNED_OR_DEAD then
                    SECTION_2.UPDATE_TARGET_LIST_HIGHLIGHTS(TARGET_LIST, SECTION_1.IS_PLAYER_DOWNED_OR_DEAD, DOWN_CHECK)
                end

                STARTER_GUI:SetCore("SendNotification", {
                    Title = "Target Rejoined",
                    Text = PLAYER.Name .. " rejoined and was re-added to target list",
                    Duration = 2,
                    Icon = "rbxthumb://type=AvatarHeadShot&id=" .. PLAYER.UserId .. "&w=150&h=150"
                })
            end
        end
    end

    PLAYER.CharacterAdded:Connect(ON_CHARACTER_ADDED)

    if PLAYER.Character then
        ON_CHARACTER_ADDED(PLAYER.Character)
    end
    
    return MODULE.UPDATE_VARS()
end

function MODULE.GET_CLOSEST_TARGET_FROM_LIST()
    if #TARGET_LIST == 0 then return nil end

    local CLOSEST_TARGET = nil
    local SHORTEST_DISTANCE = math.huge
    local MOUSE_POSITION = USER_INPUT_SERVICE:GetMouseLocation()

    for _, PLAYER in ipairs(TARGET_LIST) do
        if PLAYER and PLAYER.Character and PLAYER.Character:FindFirstChild("Hitbox") then
            local SCREEN_POSITION, ON_SCREEN = CAMERA:WorldToViewportPoint(PLAYER.Character.Hitbox.Position)
            if ON_SCREEN then
                local DISTANCE = (Vector2.new(SCREEN_POSITION.X, SCREEN_POSITION.Y) - Vector2.new(MOUSE_POSITION.X, MOUSE_POSITION.Y)).Magnitude
                if DISTANCE < SHORTEST_DISTANCE then
                    SHORTEST_DISTANCE = DISTANCE
                    CLOSEST_TARGET = PLAYER
                end
            end
        end
    end

    return CLOSEST_TARGET
end

function MODULE.REMOVE_TARGET_FROM_LIST(PLAYER)
    if not PLAYER then return false end

    local INDEX = nil
    for I, TARGET in ipairs(TARGET_LIST) do
        if TARGET == PLAYER then
            INDEX = I
            break
        end
    end

    if INDEX then
        table.remove(TARGET_LIST, INDEX)

        if SECTION_2 and SECTION_2.TARGET_HIGHLIGHTS and SECTION_2.TARGET_HIGHLIGHTS[PLAYER.Name] and SECTION_2.TARGET_HIGHLIGHTS[PLAYER.Name].Parent then
            SECTION_2.TARGET_HIGHLIGHTS[PLAYER.Name]:Destroy()
            SECTION_2.TARGET_HIGHLIGHTS[PLAYER.Name] = nil
        end
        
        MODULE.UPDATE_VARS()
        return true
    end

    return false
end

function MODULE.GET_TARGET_LIST()
    return TARGET_LIST
end

function MODULE.SET_DOWN_CHECK(VALUE)
    DOWN_CHECK = VALUE
    return DOWN_CHECK
end

return MODULE
