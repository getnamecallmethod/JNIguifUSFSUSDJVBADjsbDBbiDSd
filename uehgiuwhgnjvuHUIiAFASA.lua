-- // Spectating Module for ForceHit

local MODULE = {}

-- // Services
local PLAYERS = game:GetService("Players")
local RUN_SERVICE = game:GetService("RunService")
local STARTER_GUI = game:GetService("StarterGui")

-- // Variables
local LOCAL_PLAYER = PLAYERS.LocalPlayer
local CAMERA = workspace.CurrentCamera

local IS_SPECTATING = false
local ORIGINAL_CAMERA_CFRAME = nil
local SPECTATE_CONNECTION = nil
local SPECTATE_TARGET = nil

-- // Functions
function MODULE.START_SPECTATING(TARGET_PLAYER)
    if not TARGET_PLAYER or not TARGET_PLAYER.Character then
        return false
    end
    
    -- Safety check to prevent multiple connections
    if SPECTATE_CONNECTION then
        SPECTATE_CONNECTION:Disconnect()
        SPECTATE_CONNECTION = nil
    end

    -- Store current state before changing anything
    if not IS_SPECTATING then
        ORIGINAL_CAMERA_CFRAME = CAMERA.CFrame
    end

    -- Check if humanoid exists
    local HUMANOID = TARGET_PLAYER.Character:FindFirstChildOfClass("Humanoid")
    if not HUMANOID then
        return false
    end
    
    -- Set camera subject
    CAMERA.CameraSubject = HUMANOID
    
    IS_SPECTATING = true
    SPECTATE_TARGET = TARGET_PLAYER
    
    -- Set up monitoring connection
    SPECTATE_CONNECTION = RUN_SERVICE.RenderStepped:Connect(function()
        if not TARGET_PLAYER or not TARGET_PLAYER.Character or not TARGET_PLAYER.Character:FindFirstChild("Head") then
            MODULE.STOP_SPECTATING()
            return
        end
        
        -- Keep the humanoid reference updated
        if TARGET_PLAYER and TARGET_PLAYER.Character then
            local CURRENT_HUMANOID = TARGET_PLAYER.Character:FindFirstChildOfClass("Humanoid")
            if CURRENT_HUMANOID and CURRENT_HUMANOID ~= CAMERA.CameraSubject then
                CAMERA.CameraSubject = CURRENT_HUMANOID
            end
        end
    end)

    STARTER_GUI:SetCore("SendNotification", {
        Title = "Spectating",
        Text = "Now spectating " .. TARGET_PLAYER.Name,
        Duration = 2
    })

    return true
end

function MODULE.STOP_SPECTATING()
    -- Safety check for connection
    if SPECTATE_CONNECTION then
        SPECTATE_CONNECTION:Disconnect()
        SPECTATE_CONNECTION = nil
    end

    -- Restore camera to local player if possible
    if LOCAL_PLAYER and LOCAL_PLAYER.Character then
        local HUMANOID = LOCAL_PLAYER.Character:FindFirstChildOfClass("Humanoid")
        if HUMANOID then
            CAMERA.CameraSubject = HUMANOID
        end
    end

    -- Restore original camera position if available
    if ORIGINAL_CAMERA_CFRAME then
        CAMERA.CFrame = ORIGINAL_CAMERA_CFRAME
    end

    IS_SPECTATING = false
    SPECTATE_TARGET = nil

    STARTER_GUI:SetCore("SendNotification", {
        Title = "Spectating",
        Text = "Stopped spectating",
        Duration = 2
    })
end

function MODULE.IS_CURRENTLY_SPECTATING()
    return IS_SPECTATING
end

function MODULE.GET_SPECTATE_TARGET()
    return SPECTATE_TARGET
end

return MODULE
