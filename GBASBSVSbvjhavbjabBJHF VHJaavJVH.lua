-- ForceHit-Section2.lua
-- Section 2: Highlight and Indicator Functions

local SECTION_2 = {}

-- Get services
local PLAYERS = game:GetService("Players")

-- Constants - duplicated to ensure they're available
local HIGHLIGHT_ALIVE_COLOR = Color3.fromRGB(100, 255, 100)
local HIGHLIGHT_DEAD_COLOR = Color3.fromRGB(255, 100, 100)
local HIGHLIGHT_OUTLINE_COLOR = Color3.new(1, 1, 1)

-- Default colors that can be overridden by the main script
SECTION_2.HIGHLIGHT_COLORS = {
    ALIVE = HIGHLIGHT_ALIVE_COLOR,
    DEAD = HIGHLIGHT_DEAD_COLOR,
    OUTLINE = HIGHLIGHT_OUTLINE_COLOR
}

-- This function creates a highlight around a target character
function SECTION_2.CREATE_HIGHLIGHT(TARGET_CHARACTER)
    if not TARGET_CHARACTER then return nil end
    
    -- Use colors from the module or defaults
    local ALIVE_COLOR = SECTION_2.HIGHLIGHT_COLORS.ALIVE or HIGHLIGHT_ALIVE_COLOR
    local DEAD_COLOR = SECTION_2.HIGHLIGHT_COLORS.DEAD or HIGHLIGHT_DEAD_COLOR
    local OUTLINE_COLOR = SECTION_2.HIGHLIGHT_COLORS.OUTLINE or HIGHLIGHT_OUTLINE_COLOR
    
    -- Get the target highlight from global or create it
    local TARGET_HIGHLIGHT = _G.TARGET_HIGHLIGHT
    
    -- Get references from main script
    local DOWN_CHECK = _G.DOWN_CHECK
    local IS_PLAYER_DOWNED_OR_DEAD = _G.IS_PLAYER_DOWNED_OR_DEAD
    
    local PLAYER = PLAYERS:GetPlayerFromCharacter(TARGET_CHARACTER)
    local IS_ALIVE = true

    -- Check if player is downed
    if PLAYER and DOWN_CHECK and IS_PLAYER_DOWNED_OR_DEAD and type(IS_PLAYER_DOWNED_OR_DEAD) == "function" then
        IS_ALIVE = not IS_PLAYER_DOWNED_OR_DEAD(PLAYER)
    end

    -- Update existing highlight if it exists
    if TARGET_HIGHLIGHT and TARGET_HIGHLIGHT.Parent then
        TARGET_HIGHLIGHT.FillColor = IS_ALIVE and ALIVE_COLOR or DEAD_COLOR
        return TARGET_HIGHLIGHT
    end

    -- Create new highlight
    local HIGHLIGHT = Instance.new("Highlight")
    HIGHLIGHT.Name = "TargetHighlight"
    HIGHLIGHT.FillColor = IS_ALIVE and ALIVE_COLOR or DEAD_COLOR
    HIGHLIGHT.OutlineColor = OUTLINE_COLOR
    HIGHLIGHT.OutlineTransparency = 0.5
    HIGHLIGHT.FillTransparency = 0.5
    HIGHLIGHT.Adornee = TARGET_CHARACTER
    HIGHLIGHT.Parent = TARGET_CHARACTER
    
    -- Update the global reference
    _G.TARGET_HIGHLIGHT = HIGHLIGHT
    
    return HIGHLIGHT
end

-- This function creates a lock indicator for a target
function SECTION_2.CREATE_LOCK_INDICATOR(TARGET_CHARACTER)
    if not TARGET_CHARACTER then return nil, nil end
    
    -- Get the lock indicator from global
    local LOCK_INDICATOR = _G.LOCK_INDICATOR
    
    -- Clean up existing lock indicator
    if LOCK_INDICATOR and LOCK_INDICATOR.Parent then
        LOCK_INDICATOR:Destroy()
    end

    -- Create billboard gui
    local BILLBOARD = Instance.new("BillboardGui")
    BILLBOARD.Name = "LockIndicator"
    BILLBOARD.Size = UDim2.new(0, 1, 0, 1)
    BILLBOARD.StudsOffset = Vector3.new(0, 2.5, 0)
    BILLBOARD.Adornee = TARGET_CHARACTER
    BILLBOARD.AlwaysOnTop = true
    BILLBOARD.Parent = TARGET_CHARACTER
    
    -- Update the global reference
    _G.LOCK_INDICATOR = BILLBOARD
    
    -- Create highlight
    local HIGHLIGHT = SECTION_2.CREATE_HIGHLIGHT(TARGET_CHARACTER)
    
    return BILLBOARD, HIGHLIGHT
end

-- Setup function to bind Section 2 with globals and references
function SECTION_2.SETUP(DOWN_CHECK_VALUE, SECTION_1_REF)
    -- Setup global references
    _G.DOWN_CHECK = DOWN_CHECK_VALUE
    
    if SECTION_1_REF and SECTION_1_REF.IS_PLAYER_DOWNED_OR_DEAD then
        _G.IS_PLAYER_DOWNED_OR_DEAD = SECTION_1_REF.IS_PLAYER_DOWNED_OR_DEAD
    end
    
    return SECTION_2
end

return SECTION_2
