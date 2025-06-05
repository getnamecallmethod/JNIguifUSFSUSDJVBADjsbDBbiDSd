-- Section 1 Functions (ForceHit-Extra.lua)
-- This file is designed to be loaded via loadstring from a raw GitHub URL

local PLAYERS = game:GetService("Players")
local LOCAL_PLAYER = PLAYERS.LocalPlayer
local CAMERA = workspace.CurrentCamera

local CACHED_HITBOXES = {}
local CACHED_HUMANOIDS = {}

local function CACHE_PLAYER_PARTS(PLAYER)
    if not PLAYER or not PLAYER.Character then return end

    CACHED_HITBOXES[PLAYER.Name] = PLAYER.Character:FindFirstChild("Hitbox")
    CACHED_HUMANOIDS[PLAYER.Name] = PLAYER.Character:FindFirstChildOfClass("Humanoid")
end

local function GET_CLOSEST_PLAYER_TO_MOUSE()
    local CLOSEST_PLAYER = nil
    local SHORTEST_DISTANCE = math.huge
    local MOUSE_POSITION = game:GetService("UserInputService"):GetMouseLocation()

    for _, PLAYER in ipairs(PLAYERS:GetPlayers()) do
        if PLAYER ~= LOCAL_PLAYER and PLAYER.Character then
            local HITBOX = CACHED_HITBOXES[PLAYER.Name] or PLAYER.Character:FindFirstChild("Hitbox")

            if HITBOX then
                local WORLD_POINT = HITBOX.Position
                local VECTOR, ON_SCREEN = CAMERA:WorldToViewportPoint(WORLD_POINT)

                if ON_SCREEN then
                    local DISTANCE = (Vector2.new(MOUSE_POSITION.X, MOUSE_POSITION.Y) - Vector2.new(VECTOR.X, VECTOR.Y)).Magnitude

                    if DISTANCE < SHORTEST_DISTANCE then
                        SHORTEST_DISTANCE = DISTANCE
                        CLOSEST_PLAYER = PLAYER
                    end
                end
            end
        end
    end

    return CLOSEST_PLAYER
end

local function IS_PLAYER_DOWNED_OR_DEAD(PLAYER)
    if not PLAYER or not PLAYER.Character then return false end

    local STATE = PLAYER.Character:FindFirstChild("State")
    local DOWN = STATE and STATE:FindFirstChild("Down")
    if DOWN and DOWN.Value then return true end
    return false
end

local function RESET_CACHE(PLAYER_NAME)
    CACHED_HITBOXES[PLAYER_NAME] = nil
    CACHED_HUMANOIDS[PLAYER_NAME] = nil
end

-- Return the module functions and variables
return {
    CACHE_PLAYER_PARTS = CACHE_PLAYER_PARTS,
    GET_CLOSEST_PLAYER_TO_MOUSE = GET_CLOSEST_PLAYER_TO_MOUSE,
    IS_PLAYER_DOWNED_OR_DEAD = IS_PLAYER_DOWNED_OR_DEAD,
    RESET_CACHE = RESET_CACHE,
    CACHED_HITBOXES = CACHED_HITBOXES,
    CACHED_HUMANOIDS = CACHED_HUMANOIDS
}
