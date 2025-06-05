return {
    INITIALIZE = function(SECTION_1, SECTION_2, SECTION_3, SECTION_4, VARS)
        local PLAYERS = game:GetService("Players")
        local USER_INPUT_SERVICE = game:GetService("UserInputService")
        local STARTER_GUI = game:GetService("StarterGui")

        local LOCKED_TARGET = VARS.LOCKED_TARGET
        local TARGET_PLAYER_NAME = VARS.TARGET_PLAYER_NAME
        local TARGET_HIGHLIGHT = VARS.TARGET_HIGHLIGHT
        local LOCK_INDICATOR = VARS.LOCK_INDICATOR
        local TARGET_LIST = VARS.TARGET_LIST
        local CURRENT_TARGET_INDEX = VARS.CURRENT_TARGET_INDEX
        local MULTI_TARGET_ENABLED = VARS.MULTI_TARGET_ENABLED
        local DOWN_CHECK = VARS.DOWN_CHECK
        local IS_SIGMA_SHOT_ENABLED = VARS.IS_SIGMA_SHOT_ENABLED
        local Q_ADD_TARGETS_ENABLED = VARS.Q_ADD_TARGETS_ENABLED
        local ATTACK_ALL_TARGETS = VARS.ATTACK_ALL_TARGETS

        local function HANDLE_INPUT(INPUT, GAME_PROCESSED)
            if GAME_PROCESSED then return end

            if INPUT.KeyCode == Enum.KeyCode.Q then
                LOCKED_TARGET = SECTION_1.GET_CLOSEST_PLAYER_TO_MOUSE()
                if not LOCKED_TARGET then return end

                TARGET_PLAYER_NAME = LOCKED_TARGET.Name
                if LOCKED_TARGET.Character then
                    local indicator, highlight = SECTION_2.CREATE_LOCK_INDICATOR(LOCKED_TARGET.Character, DOWN_CHECK, SECTION_1.IS_PLAYER_DOWNED_OR_DEAD, LOCKED_TARGET)
                    LOCK_INDICATOR = indicator
                    TARGET_HIGHLIGHT = highlight
                end

                if (Q_ADD_TARGETS_ENABLED or MULTI_TARGET_ENABLED) and not table.find(TARGET_LIST, LOCKED_TARGET) then
                    table.insert(TARGET_LIST, LOCKED_TARGET)
                    SECTION_2.UPDATE_TARGET_LIST_HIGHLIGHTS(TARGET_LIST, SECTION_1.IS_PLAYER_DOWNED_OR_DEAD, DOWN_CHECK)
                    STARTER_GUI:SetCore("SendNotification", {
                        Title = "Target Added", Text = LOCKED_TARGET.Name .. " (#" .. #TARGET_LIST .. ")",
                        Duration = 2, Icon = "rbxthumb://type=AvatarHeadShot&id=" .. LOCKED_TARGET.UserId .. "&w=150&h=150"
                    })
                end

                STARTER_GUI:SetCore("SendNotification", {
                    Title = "Target Locked (Q)", Text = LOCKED_TARGET.Name, Duration = 3,
                    Icon = "rbxthumb://type=AvatarHeadShot&id=" .. LOCKED_TARGET.UserId .. "&w=150&h=150"
                })

            elseif INPUT.KeyCode == Enum.KeyCode.C then
                if LOCKED_TARGET then
                    local updated_vars = SECTION_4.CLEAR_LOCK()

                    -- Update local variables from module
                    LOCK_INDICATOR = updated_vars.LOCK_INDICATOR
                    TARGET_HIGHLIGHT = updated_vars.TARGET_HIGHLIGHT
                    LOCKED_TARGET = updated_vars.LOCKED_TARGET
                    TARGET_PLAYER_NAME = updated_vars.TARGET_PLAYER_NAME
                    TARGET_LIST = updated_vars.TARGET_LIST
                    CURRENT_TARGET_INDEX = updated_vars.CURRENT_TARGET_INDEX

                    STARTER_GUI:SetCore("SendNotification", {
                        Title = "Target Unlocked", Text = "Lock removed",
                        Duration = 1, Icon = "rbxasset://textures/GunCursor.png"
                    })
                else
                    LOCKED_TARGET = SECTION_1.GET_CLOSEST_PLAYER_TO_MOUSE()
                    if not LOCKED_TARGET then return end

                    TARGET_PLAYER_NAME = LOCKED_TARGET.Name
                    if LOCKED_TARGET.Character then
                        local indicator, highlight = SECTION_2.CREATE_LOCK_INDICATOR(LOCKED_TARGET.Character, DOWN_CHECK, SECTION_1.IS_PLAYER_DOWNED_OR_DEAD, LOCKED_TARGET)
                        LOCK_INDICATOR = indicator
                        TARGET_HIGHLIGHT = highlight
                    end

                    STARTER_GUI:SetCore("SendNotification", {
                        Title = "Target Locked", Text = LOCKED_TARGET.Name, Duration = 3,
                        Icon = "rbxthumb://type=AvatarHeadShot&id=" .. LOCKED_TARGET.UserId .. "&w=150&h=150"
                    })
                end

            elseif INPUT.KeyCode == Enum.KeyCode.V then
                IS_SIGMA_SHOT_ENABLED = not IS_SIGMA_SHOT_ENABLED
                STARTER_GUI:SetCore("SendNotification", {
                    Title = "Sigma Shot", Text = IS_SIGMA_SHOT_ENABLED and "Enabled" or "Disabled", Duration = 1
                })

            elseif INPUT.KeyCode == Enum.KeyCode.F then
                MULTI_TARGET_ENABLED = not MULTI_TARGET_ENABLED
                Q_ADD_TARGETS_ENABLED = MULTI_TARGET_ENABLED
                TARGET_LIST = {}
                CURRENT_TARGET_INDEX = 1
                ATTACK_ALL_TARGETS = false
                SECTION_2.CLEAR_ALL_TARGET_HIGHLIGHTS()

                if MULTI_TARGET_ENABLED and LOCKED_TARGET then
                    table.insert(TARGET_LIST, LOCKED_TARGET)
                    SECTION_2.UPDATE_TARGET_LIST_HIGHLIGHTS(TARGET_LIST, SECTION_1.IS_PLAYER_DOWNED_OR_DEAD, DOWN_CHECK)
                end

                -- Update Section 4 with new values
                SECTION_4.UPDATE_VARS({
                    TARGET_LIST = TARGET_LIST,
                    CURRENT_TARGET_INDEX = CURRENT_TARGET_INDEX,
                    MULTI_TARGET_ENABLED = MULTI_TARGET_ENABLED
                })

                STARTER_GUI:SetCore("SendNotification", {
                    Title = "Multi-Target Mode",
                    Text = MULTI_TARGET_ENABLED and "Enabled - Press Q to add targets" or "Disabled",
                    Duration = MULTI_TARGET_ENABLED and 3 or 2
                })

            elseif INPUT.KeyCode == Enum.KeyCode.T then
                DOWN_CHECK = not DOWN_CHECK
                SECTION_4.SET_DOWN_CHECK(DOWN_CHECK)

                STARTER_GUI:SetCore("SendNotification", {
                    Title = "Down Check",
                    Text = DOWN_CHECK and "Enabled - Skip downed players" or "Disabled - Target all players",
                    Duration = 3
                })
                if MULTI_TARGET_ENABLED then SECTION_2.UPDATE_TARGET_LIST_HIGHLIGHTS(TARGET_LIST, SECTION_1.IS_PLAYER_DOWNED_OR_DEAD, DOWN_CHECK) end

            elseif INPUT.KeyCode == Enum.KeyCode.H then
                if not MULTI_TARGET_ENABLED or not LOCKED_TARGET then
                    STARTER_GUI:SetCore("SendNotification", {
                        Title = not MULTI_TARGET_ENABLED and "Multi-Target Mode" or "Add Target Error",
                        Text = not MULTI_TARGET_ENABLED and "Enable multi-target mode first with F" or "Lock onto a target first with C",
                        Duration = 2
                    })
                    return
                end

                if table.find(TARGET_LIST, LOCKED_TARGET) then
                    STARTER_GUI:SetCore("SendNotification", {
                        Title = "Target Already Added", Text = LOCKED_TARGET.Name .. " is already in the list", Duration = 2
                    })
                    return
                end

                table.insert(TARGET_LIST, LOCKED_TARGET)
                SECTION_2.UPDATE_TARGET_LIST_HIGHLIGHTS(TARGET_LIST, SECTION_1.IS_PLAYER_DOWNED_OR_DEAD, DOWN_CHECK)
                SECTION_4.UPDATE_VARS({TARGET_LIST = TARGET_LIST})

                STARTER_GUI:SetCore("SendNotification", {
                    Title = "Target Added", Text = LOCKED_TARGET.Name .. " (#" .. #TARGET_LIST .. ")", Duration = 2,
                    Icon = "rbxthumb://type=AvatarHeadShot&id=" .. LOCKED_TARGET.UserId .. "&w=150&h=150"
                })

            elseif INPUT.KeyCode == Enum.KeyCode.M then
                if not MULTI_TARGET_ENABLED or #TARGET_LIST == 0 then
                    STARTER_GUI:SetCore("SendNotification", {
                        Title = "Clear List Error",
                        Text = MULTI_TARGET_ENABLED and "No targets to clear" or "Enable multi-target mode (F) first",
                        Duration = 2
                    })
                    return
                end

                local TARGET_COUNT = #TARGET_LIST
                TARGET_LIST = {}
                CURRENT_TARGET_INDEX = 1
                SECTION_2.CLEAR_ALL_TARGET_HIGHLIGHTS()
                SECTION_4.UPDATE_VARS({
                    TARGET_LIST = TARGET_LIST,
                    CURRENT_TARGET_INDEX = CURRENT_TARGET_INDEX
                })

                for _, PLAYER in ipairs(PLAYERS:GetPlayers()) do
                    if PLAYER.Character then
                        for _, CHILD in ipairs(PLAYER.Character:GetChildren()) do
                            if CHILD:IsA("Highlight") or CHILD:IsA("BillboardGui") then CHILD:Destroy() end
                        end
                    end
                end

                STARTER_GUI:SetCore("SendNotification", {
                    Title = "Target List Cleared", Text = "Removed " .. TARGET_COUNT .. " targets", Duration = 2
                })

            elseif INPUT.KeyCode == Enum.KeyCode.N then
                if not LOCKED_TARGET then
                    STARTER_GUI:SetCore("SendNotification", {
                        Title = "Spectate Error", Text = "No target locked to spectate", Duration = 2
                    })
                    return
                end

                if SECTION_3 and SECTION_3.IS_CURRENTLY_SPECTATING and SECTION_3.IS_CURRENTLY_SPECTATING() then
                    SECTION_3.STOP_SPECTATING()
                else
                    SECTION_3.START_SPECTATING(LOCKED_TARGET)
                end

            elseif INPUT.KeyCode == Enum.KeyCode.LeftAlt then
                if not MULTI_TARGET_ENABLED or #TARGET_LIST == 0 then return end

                local TARGET_TO_REMOVE = SECTION_4.GET_CLOSEST_TARGET_FROM_LIST()
                if TARGET_TO_REMOVE and SECTION_4.REMOVE_TARGET_FROM_LIST(TARGET_TO_REMOVE) then
                    STARTER_GUI:SetCore("SendNotification", {
                        Title = "Removed Target", Text = TARGET_TO_REMOVE.Name, Duration = 1,
                        Icon = "rbxthumb://type=AvatarHeadShot&id=" .. TARGET_TO_REMOVE.UserId .. "&w=150&h=150"
                    })

                    -- Get updated target list from Section 4
                    TARGET_LIST = SECTION_4.GET_TARGET_LIST()

                    if CURRENT_TARGET_INDEX > #TARGET_LIST then CURRENT_TARGET_INDEX = 1 end
                end

                STARTER_GUI:SetCore("SendNotification", {
                    Title = "Target Count", Text = tostring(#TARGET_LIST), Duration = 1
                })
            end

            -- Return updated variables
            return {
                LOCKED_TARGET = LOCKED_TARGET,
                TARGET_PLAYER_NAME = TARGET_PLAYER_NAME,
                TARGET_HIGHLIGHT = TARGET_HIGHLIGHT,
                LOCK_INDICATOR = LOCK_INDICATOR,
                TARGET_LIST = TARGET_LIST,
                CURRENT_TARGET_INDEX = CURRENT_TARGET_INDEX,
                MULTI_TARGET_ENABLED = MULTI_TARGET_ENABLED,
                DOWN_CHECK = DOWN_CHECK,
                IS_SIGMA_SHOT_ENABLED = IS_SIGMA_SHOT_ENABLED,
                Q_ADD_TARGETS_ENABLED = Q_ADD_TARGETS_ENABLED,
                ATTACK_ALL_TARGETS = ATTACK_ALL_TARGETS
            }
        end

        -- Set up the input connection
        local function SETUP_INPUT_HANDLER()
            USER_INPUT_SERVICE.InputBegan:Connect(function(INPUT, GAME_PROCESSED)
                local updated_vars = HANDLE_INPUT(INPUT, GAME_PROCESSED)
                if updated_vars then
                    LOCKED_TARGET = updated_vars.LOCKED_TARGET
                    TARGET_PLAYER_NAME = updated_vars.TARGET_PLAYER_NAME
                    TARGET_HIGHLIGHT = updated_vars.TARGET_HIGHLIGHT
                    LOCK_INDICATOR = updated_vars.LOCK_INDICATOR
                    TARGET_LIST = updated_vars.TARGET_LIST
                    CURRENT_TARGET_INDEX = updated_vars.CURRENT_TARGET_INDEX
                    MULTI_TARGET_ENABLED = updated_vars.MULTI_TARGET_ENABLED
                    DOWN_CHECK = updated_vars.DOWN_CHECK
                    IS_SIGMA_SHOT_ENABLED = updated_vars.IS_SIGMA_SHOT_ENABLED
                    Q_ADD_TARGETS_ENABLED = updated_vars.Q_ADD_TARGETS_ENABLED
                    ATTACK_ALL_TARGETS = updated_vars.ATTACK_ALL_TARGETS
                end
            end)

            return {
                LOCKED_TARGET = LOCKED_TARGET,
                TARGET_PLAYER_NAME = TARGET_PLAYER_NAME,
                TARGET_HIGHLIGHT = TARGET_HIGHLIGHT,
                LOCK_INDICATOR = LOCK_INDICATOR,
                TARGET_LIST = TARGET_LIST,
                CURRENT_TARGET_INDEX = CURRENT_TARGET_INDEX,
                MULTI_TARGET_ENABLED = MULTI_TARGET_ENABLED,
                DOWN_CHECK = DOWN_CHECK,
                IS_SIGMA_SHOT_ENABLED = IS_SIGMA_SHOT_ENABLED,
                Q_ADD_TARGETS_ENABLED = Q_ADD_TARGETS_ENABLED,
                ATTACK_ALL_TARGETS = ATTACK_ALL_TARGETS
            }
        end

        -- Return the module's public interface
        return {
            SETUP_INPUT_HANDLER = SETUP_INPUT_HANDLER,
            GET_VARIABLES = function()
                return {
                    LOCKED_TARGET = LOCKED_TARGET,
                    TARGET_PLAYER_NAME = TARGET_PLAYER_NAME,
                    TARGET_HIGHLIGHT = TARGET_HIGHLIGHT,
                    LOCK_INDICATOR = LOCK_INDICATOR,
                    TARGET_LIST = TARGET_LIST,
                    CURRENT_TARGET_INDEX = CURRENT_TARGET_INDEX,
                    MULTI_TARGET_ENABLED = MULTI_TARGET_ENABLED,
                    DOWN_CHECK = DOWN_CHECK,
                    IS_SIGMA_SHOT_ENABLED = IS_SIGMA_SHOT_ENABLED,
                    Q_ADD_TARGETS_ENABLED = Q_ADD_TARGETS_ENABLED,
                    ATTACK_ALL_TARGETS = ATTACK_ALL_TARGETS
                }
            end,
            UPDATE_VARIABLES = function(NEW_VARS)
                if NEW_VARS.LOCKED_TARGET ~= nil then LOCKED_TARGET = NEW_VARS.LOCKED_TARGET end
                if NEW_VARS.TARGET_PLAYER_NAME ~= nil then TARGET_PLAYER_NAME = NEW_VARS.TARGET_PLAYER_NAME end
                if NEW_VARS.TARGET_HIGHLIGHT ~= nil then TARGET_HIGHLIGHT = NEW_VARS.TARGET_HIGHLIGHT end
                if NEW_VARS.LOCK_INDICATOR ~= nil then LOCK_INDICATOR = NEW_VARS.LOCK_INDICATOR end
                if NEW_VARS.TARGET_LIST ~= nil then TARGET_LIST = NEW_VARS.TARGET_LIST end
                if NEW_VARS.CURRENT_TARGET_INDEX ~= nil then CURRENT_TARGET_INDEX = NEW_VARS.CURRENT_TARGET_INDEX end
                if NEW_VARS.MULTI_TARGET_ENABLED ~= nil then MULTI_TARGET_ENABLED = NEW_VARS.MULTI_TARGET_ENABLED end
                if NEW_VARS.DOWN_CHECK ~= nil then DOWN_CHECK = NEW_VARS.DOWN_CHECK end
                if NEW_VARS.IS_SIGMA_SHOT_ENABLED ~= nil then IS_SIGMA_SHOT_ENABLED = NEW_VARS.IS_SIGMA_SHOT_ENABLED end
                if NEW_VARS.Q_ADD_TARGETS_ENABLED ~= nil then Q_ADD_TARGETS_ENABLED = NEW_VARS.Q_ADD_TARGETS_ENABLED end
                if NEW_VARS.ATTACK_ALL_TARGETS ~= nil then ATTACK_ALL_TARGETS = NEW_VARS.ATTACK_ALL_TARGETS end

                return {
                    LOCKED_TARGET = LOCKED_TARGET,
                    TARGET_PLAYER_NAME = TARGET_PLAYER_NAME,
                    TARGET_HIGHLIGHT = TARGET_HIGHLIGHT,
                    LOCK_INDICATOR = LOCK_INDICATOR,
                    TARGET_LIST = TARGET_LIST,
                    CURRENT_TARGET_INDEX = CURRENT_TARGET_INDEX,
                    MULTI_TARGET_ENABLED = MULTI_TARGET_ENABLED,
                    DOWN_CHECK = DOWN_CHECK,
                    IS_SIGMA_SHOT_ENABLED = IS_SIGMA_SHOT_ENABLED,
                    Q_ADD_TARGETS_ENABLED = Q_ADD_TARGETS_ENABLED,
                    ATTACK_ALL_TARGETS = ATTACK_ALL_TARGETS
                }
            end
        }
    end
}
