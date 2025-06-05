local MODULE = {}

local PLAYERS = game:GetService("Players")
local CAMERA = workspace.CurrentCamera

MODULE.HIGHLIGHT_UPDATE_INTERVAL = 1
MODULE.HIGHLIGHT_ALIVE_COLOR = Color3.fromRGB(100, 255, 100)
MODULE.HIGHLIGHT_DEAD_COLOR = Color3.fromRGB(255, 100, 100)
MODULE.HIGHLIGHT_OUTLINE_COLOR = Color3.new(1, 1, 1)

MODULE.TARGET_LIST_HIGHLIGHT_NAME = "TargetListHighlight"
MODULE.TARGET_LIST_ALIVE_COLOR = Color3.fromRGB(100, 255, 100)
MODULE.TARGET_LIST_DEAD_COLOR = Color3.fromRGB(255, 100, 100)
MODULE.TARGET_LIST_OUTLINE_COLOR = Color3.new(1, 1, 1)
MODULE.TARGET_LIST_FILL_TRANSPARENCY = 0.4
MODULE.TARGET_LIST_OUTLINE_TRANSPARENCY = 0.5
MODULE.TARGET_LIST_DEPTH_MODE = Enum.HighlightDepthMode.AlwaysOnTop

MODULE.TARGET_HIGHLIGHTS = {}
MODULE.LAST_HIGHLIGHT_UPDATE_TIME = 0

function MODULE.CREATE_HIGHLIGHT(TARGET_CHARACTER, IS_DOWN_CHECK_ENABLED, CHECK_DOWNED_FUNCTION, TARGET_PLAYER)
    if not TARGET_CHARACTER then return end

    local IS_ALIVE = true

    if TARGET_PLAYER and IS_DOWN_CHECK_ENABLED then
        if CHECK_DOWNED_FUNCTION and type(CHECK_DOWNED_FUNCTION) == "function" then
            IS_ALIVE = not CHECK_DOWNED_FUNCTION(TARGET_PLAYER)
        end
    end

    local EXISTING_HIGHLIGHT = TARGET_CHARACTER:FindFirstChild("TargetHighlight")
    if EXISTING_HIGHLIGHT then
        EXISTING_HIGHLIGHT.FillColor = IS_ALIVE and MODULE.HIGHLIGHT_ALIVE_COLOR or MODULE.HIGHLIGHT_DEAD_COLOR
        return EXISTING_HIGHLIGHT
    end

    local HIGHLIGHT = Instance.new("Highlight")
    HIGHLIGHT.Name = "TargetHighlight"
    HIGHLIGHT.FillColor = IS_ALIVE and MODULE.HIGHLIGHT_ALIVE_COLOR or MODULE.HIGHLIGHT_DEAD_COLOR
    HIGHLIGHT.OutlineColor = MODULE.HIGHLIGHT_OUTLINE_COLOR
    HIGHLIGHT.OutlineTransparency = 0.5
    HIGHLIGHT.FillTransparency = 0.5
    HIGHLIGHT.Adornee = TARGET_CHARACTER
    HIGHLIGHT.Parent = TARGET_CHARACTER
    
    return HIGHLIGHT
end

function MODULE.CREATE_LOCK_INDICATOR(TARGET_CHARACTER, DOWN_CHECK, CHECK_DOWNED_FUNCTION, TARGET_PLAYER)
    local EXISTING_INDICATOR = TARGET_CHARACTER:FindFirstChild("LockIndicator")
    if EXISTING_INDICATOR then
        EXISTING_INDICATOR:Destroy()
    end

    if not TARGET_CHARACTER then
        return nil
    end

    local BILLBOARD = Instance.new("BillboardGui")
    BILLBOARD.Name = "LockIndicator"
    BILLBOARD.Size = UDim2.new(0, 1, 0, 1)
    BILLBOARD.StudsOffset = Vector3.new(0, 2.5, 0)
    BILLBOARD.Adornee = TARGET_CHARACTER
    BILLBOARD.AlwaysOnTop = true
    BILLBOARD.Parent = TARGET_CHARACTER

    local HIGHLIGHT = MODULE.CREATE_HIGHLIGHT(TARGET_CHARACTER, DOWN_CHECK, CHECK_DOWNED_FUNCTION, TARGET_PLAYER)
    
    return BILLBOARD, HIGHLIGHT
end

function MODULE.CREATE_TARGET_LIST_HIGHLIGHT(PLAYER, DOWN_CHECK, CHECK_DOWNED_FUNCTION)
    if not PLAYER or not PLAYER.Character then return nil, false end

    local CHARACTER = PLAYER.Character
    local EXISTING_HIGHLIGHT = MODULE.TARGET_HIGHLIGHTS[PLAYER.Name]

    local IS_PRIORITY = false
    local IS_DOWNED = false
    
    if PLAYER and CHECK_DOWNED_FUNCTION and type(CHECK_DOWNED_FUNCTION) == "function" then
        IS_DOWNED = CHECK_DOWNED_FUNCTION(PLAYER)
    end

    if not IS_DOWNED then
        IS_PRIORITY = true
    end

    if EXISTING_HIGHLIGHT and EXISTING_HIGHLIGHT.Parent then
        EXISTING_HIGHLIGHT.FillColor = not IS_DOWNED and MODULE.TARGET_LIST_ALIVE_COLOR or MODULE.TARGET_LIST_DEAD_COLOR
        EXISTING_HIGHLIGHT.OutlineColor = MODULE.TARGET_LIST_OUTLINE_COLOR
        return EXISTING_HIGHLIGHT, IS_PRIORITY
    else
        local HIGHLIGHT = Instance.new("Highlight")
        HIGHLIGHT.Name = MODULE.TARGET_LIST_HIGHLIGHT_NAME
        HIGHLIGHT.FillColor = not IS_DOWNED and MODULE.TARGET_LIST_ALIVE_COLOR or MODULE.TARGET_LIST_DEAD_COLOR
        HIGHLIGHT.OutlineColor = MODULE.TARGET_LIST_OUTLINE_COLOR
        HIGHLIGHT.FillTransparency = MODULE.TARGET_LIST_FILL_TRANSPARENCY
        HIGHLIGHT.OutlineTransparency = MODULE.TARGET_LIST_OUTLINE_TRANSPARENCY
        HIGHLIGHT.DepthMode = MODULE.TARGET_LIST_DEPTH_MODE
        HIGHLIGHT.Adornee = CHARACTER
        HIGHLIGHT.Parent = CHARACTER

        MODULE.TARGET_HIGHLIGHTS[PLAYER.Name] = HIGHLIGHT
        return HIGHLIGHT, IS_PRIORITY
    end
end

function MODULE.CLEAR_ALL_TARGET_HIGHLIGHTS()
    for _, HIGHLIGHT in pairs(MODULE.TARGET_HIGHLIGHTS) do
        if HIGHLIGHT and HIGHLIGHT.Parent then
            HIGHLIGHT:Destroy()
        end
    end

    MODULE.TARGET_HIGHLIGHTS = {}

    for _, PLAYER in ipairs(PLAYERS:GetPlayers()) do
        if PLAYER and PLAYER.Character then
            for _, CHILD in ipairs(PLAYER.Character:GetChildren()) do
                if CHILD:IsA("Highlight") and (CHILD.Name == MODULE.TARGET_LIST_HIGHLIGHT_NAME or CHILD.Name == "TargetHighlight") then
                    CHILD:Destroy()
                end
                if CHILD:IsA("BillboardGui") and (CHILD.Name == "LockIndicator" or CHILD.Name == "TargetLabel") then
                    CHILD:Destroy()
                end
            end
        end
    end
end

function MODULE.UPDATE_TARGET_LIST_HIGHLIGHTS(TARGET_LIST, CHECK_DOWNED_FUNCTION, DOWN_CHECK)
    if tick() - MODULE.LAST_HIGHLIGHT_UPDATE_TIME < MODULE.HIGHLIGHT_UPDATE_INTERVAL then return end
    MODULE.LAST_HIGHLIGHT_UPDATE_TIME = tick()

    for _, PLAYER in ipairs(TARGET_LIST) do
        if PLAYER and PLAYER.Character then
            MODULE.CREATE_TARGET_LIST_HIGHLIGHT(PLAYER, DOWN_CHECK, CHECK_DOWNED_FUNCTION)
        end
    end

    for PLAYER_NAME, HIGHLIGHT in pairs(MODULE.TARGET_HIGHLIGHTS) do
        local STILL_IN_LIST = false
        for _, PLAYER in ipairs(TARGET_LIST) do
            if PLAYER and PLAYER.Name == PLAYER_NAME then
                STILL_IN_LIST = true
                break
            end
        end

        if not STILL_IN_LIST and HIGHLIGHT and HIGHLIGHT.Parent then
            HIGHLIGHT:Destroy()
            MODULE.TARGET_HIGHLIGHTS[PLAYER_NAME] = nil
        end
    end
end

return MODULE
