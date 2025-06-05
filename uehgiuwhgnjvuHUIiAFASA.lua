local MODULE = {}

local PLAYERS = game:GetService("Players")
local RUN_SERVICE = game:GetService("RunService")
local STARTER_GUI = game:GetService("StarterGui")

local LOCAL_PLAYER = PLAYERS.LocalPlayer
local CAMERA = workspace.CurrentCamera

local IS_SPECTATING = false
local ORIGINAL_CAMERA_CFRAME = nil
local SPECTATE_CONNECTION = nil

function MODULE.START_SPECTATING(TARGET_PLAYER)
    if not TARGET_PLAYER or not TARGET_PLAYER.Character then
        return false
    end

    if IS_SPECTATING then
        MODULE.STOP_SPECTATING()
    end

    IS_SPECTATING = true
    ORIGINAL_CAMERA_CFRAME = CAMERA.CFrame

    local HUMANOID = TARGET_PLAYER.Character:FindFirstChildOfClass("Humanoid")
    if HUMANOID then
        CAMERA.CameraSubject = HUMANOID
    else
        return false
    end

    if SPECTATE_CONNECTION then
        SPECTATE_CONNECTION:Disconnect()
        SPECTATE_CONNECTION = nil
    end

    SPECTATE_CONNECTION = RUN_SERVICE.RenderStepped:Connect(function()
        if not TARGET_PLAYER or not TARGET_PLAYER.Character or not TARGET_PLAYER.Character:FindFirstChild("Head") then
            MODULE.STOP_SPECTATING()
            return
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
    if SPECTATE_CONNECTION then
        SPECTATE_CONNECTION:Disconnect()
        SPECTATE_CONNECTION = nil
    end

    if LOCAL_PLAYER and LOCAL_PLAYER.Character then
        local HUMANOID = LOCAL_PLAYER.Character:FindFirstChildOfClass("Humanoid")
        if HUMANOID then
            CAMERA.CameraSubject = HUMANOID
        end
    end

    if ORIGINAL_CAMERA_CFRAME then
        CAMERA.CFrame = ORIGINAL_CAMERA_CFRAME
    end

    IS_SPECTATING = false

    STARTER_GUI:SetCore("SendNotification", {
        Title = "Spectating",
        Text = "Stopped spectating",
        Duration = 2
    })
end

function MODULE.IS_CURRENTLY_SPECTATING()
    return IS_SPECTATING
end

return MODULE
