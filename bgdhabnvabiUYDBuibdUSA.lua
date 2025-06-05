return {
    INITIALIZE = function(SECTION_1, SECTION_2, SECTION_3, SECTION_4, VARS)
        local PLAYERS = game:GetService("Players")
        local USER_INPUT_SERVICE = game:GetService("UserInputService")
        local STARTER_GUI = game:GetService("StarterGui")
        
        -- Initialize variables from passed parameters or use defaults
        local LOCAL_VARS = {
            LOCKED_TARGET = VARS and VARS.LOCKED_TARGET or nil,
            TARGET_PLAYER_NAME = VARS and VARS.TARGET_PLAYER_NAME or nil,
            TARGET_HIGHLIGHT = VARS and VARS.TARGET_HIGHLIGHT or nil,
            LOCK_INDICATOR = VARS and VARS.LOCK_INDICATOR or nil,
            TARGET_LIST = VARS and VARS.TARGET_LIST or {},
            CURRENT_TARGET_INDEX = VARS and VARS.CURRENT_TARGET_INDEX or 1,
            MULTI_TARGET_ENABLED = VARS and VARS.MULTI_TARGET_ENABLED or false,
            DOWN_CHECK = VARS and VARS.DOWN_CHECK or true,
            IS_SIGMA_SHOT_ENABLED = VARS and VARS.IS_SIGMA_SHOT_ENABLED or false,
            Q_ADD_TARGETS_ENABLED = VARS and VARS.Q_ADD_TARGETS_ENABLED or false,
            ATTACK_ALL_TARGETS = VARS and VARS.ATTACK_ALL_TARGETS or false
        }
        
        local inputConnection = nil
        
        -- Process input from key presses
        local function HANDLE_INPUT(INPUT, GAME_PROCESSED)
            if GAME_PROCESSED then return end

            if INPUT.KeyCode == Enum.KeyCode.Q then
                LOCAL_VARS.LOCKED_TARGET = SECTION_1.GET_CLOSEST_PLAYER_TO_MOUSE()
                if not LOCAL_VARS.LOCKED_TARGET then return LOCAL_VARS end

                LOCAL_VARS.TARGET_PLAYER_NAME = LOCAL_VARS.LOCKED_TARGET.Name
                if LOCAL_VARS.LOCKED_TARGET.Character then
                    local indicator, highlight = SECTION_2.CREATE_LOCK_INDICATOR(
                        LOCAL_VARS.LOCKED_TARGET.Character, 
                        LOCAL_VARS.DOWN_CHECK, 
                        SECTION_1.IS_PLAYER_DOWNED_OR_DEAD, 
                        LOCAL_VARS.LOCKED_TARGET
                    )
                    LOCAL_VARS.LOCK_INDICATOR = indicator
                    LOCAL_VARS.TARGET_HIGHLIGHT = highlight
                end

                if (LOCAL_VARS.Q_ADD_TARGETS_ENABLED or LOCAL_VARS.MULTI_TARGET_ENABLED) and 
                   not table.find(LOCAL_VARS.TARGET_LIST, LOCAL_VARS.LOCKED_TARGET) then
                    table.insert(LOCAL_VARS.TARGET_LIST, LOCAL_VARS.LOCKED_TARGET)
                    SECTION_2.UPDATE_TARGET_LIST_HIGHLIGHTS(LOCAL_VARS.TARGET_LIST, SECTION_1.IS_PLAYER_DOWNED_OR_DEAD, LOCAL_VARS.DOWN_CHECK)
                    STARTER_GUI:SetCore("SendNotification", {
                        Title = "Target Added", 
                        Text = LOCAL_VARS.LOCKED_TARGET.Name .. " (#" .. #LOCAL_VARS.TARGET_LIST .. ")",
                        Duration = 2, 
                        Icon = "rbxthumb://type=AvatarHeadShot&id=" .. LOCAL_VARS.LOCKED_TARGET.UserId .. "&w=150&h=150"
                    })
                end

                STARTER_GUI:SetCore("SendNotification", {
                    Title = "Target Locked (Q)", 
                    Text = LOCAL_VARS.LOCKED_TARGET.Name, 
                    Duration = 3,
                    Icon = "rbxthumb://type=AvatarHeadShot&id=" .. LOCAL_VARS.LOCKED_TARGET.UserId .. "&w=150&h=150"
                })

            elseif INPUT.KeyCode == Enum.KeyCode.C then
                if LOCAL_VARS.LOCKED_TARGET then
                    local updated_vars = SECTION_4.CLEAR_LOCK()

                    -- Update local variables from module
                    LOCAL_VARS.LOCK_INDICATOR = updated_vars.LOCK_INDICATOR
                    LOCAL_VARS.TARGET_HIGHLIGHT = updated_vars.TARGET_HIGHLIGHT
                    LOCAL_VARS.LOCKED_TARGET = updated_vars.LOCKED_TARGET
                    LOCAL_VARS.TARGET_PLAYER_NAME = updated_vars.TARGET_PLAYER_NAME
                    LOCAL_VARS.TARGET_LIST = updated_vars.TARGET_LIST
                    LOCAL_VARS.CURRENT_TARGET_INDEX = updated_vars.CURRENT_TARGET_INDEX

                    STARTER_GUI:SetCore("SendNotification", {
                        Title = "Target Unlocked", 
                        Text = "Lock removed",
                        Duration = 1, 
                        Icon = "rbxasset://textures/GunCursor.png"
                    })
                else
                    LOCAL_VARS.LOCKED_TARGET = SECTION_1.GET_CLOSEST_PLAYER_TO_MOUSE()
                    if not LOCAL_VARS.LOCKED_TARGET then return LOCAL_VARS end

                    LOCAL_VARS.TARGET_PLAYER_NAME = LOCAL_VARS.LOCKED_TARGET.Name
                    if LOCAL_VARS.LOCKED_TARGET.Character then
                        local indicator, highlight = SECTION_2.CREATE_LOCK_INDICATOR(
                            LOCAL_VARS.LOCKED_TARGET.Character, 
                            LOCAL_VARS.DOWN_CHECK, 
                            SECTION_1.IS_PLAYER_DOWNED_OR_DEAD, 
                            LOCAL_VARS.LOCKED_TARGET
                        )
                        LOCAL_VARS.LOCK_INDICATOR = indicator
                        LOCAL_VARS.TARGET_HIGHLIGHT = highlight
                    end

                    STARTER_GUI:SetCore("SendNotification", {
                        Title = "Target Locked", 
                        Text = LOCAL_VARS.LOCKED_TARGET.Name, 
                        Duration = 3,
                        Icon = "rbxthumb://type=AvatarHeadShot&id=" .. LOCAL_VARS.LOCKED_TARGET.UserId .. "&w=150&h=150"
                    })
                end

            elseif INPUT.KeyCode == Enum.KeyCode.V then
                LOCAL_VARS.IS_SIGMA_SHOT_ENABLED = not LOCAL_VARS.IS_SIGMA_SHOT_ENABLED
                STARTER_GUI:SetCore("SendNotification", {
                    Title = "Sigma Shot", 
                    Text = LOCAL_VARS.IS_SIGMA_SHOT_ENABLED and "Enabled" or "Disabled", 
                    Duration = 1
                })

            elseif INPUT.KeyCode == Enum.KeyCode.F then
                LOCAL_VARS.MULTI_TARGET_ENABLED = not LOCAL_VARS.MULTI_TARGET_ENABLED
                LOCAL_VARS.Q_ADD_TARGETS_ENABLED = LOCAL_VARS.MULTI_TARGET_ENABLED
                LOCAL_VARS.TARGET_LIST = {}
                LOCAL_VARS.CURRENT_TARGET_INDEX = 1
                LOCAL_VARS.ATTACK_ALL_TARGETS = false
                SECTION_2.CLEAR_ALL_TARGET_HIGHLIGHTS()

                if LOCAL_VARS.MULTI_TARGET_ENABLED and LOCAL_VARS.LOCKED_TARGET then
                    table.insert(LOCAL_VARS.TARGET_LIST, LOCAL_VARS.LOCKED_TARGET)
                    SECTION_2.UPDATE_TARGET_LIST_HIGHLIGHTS(LOCAL_VARS.TARGET_LIST, SECTION_1.IS_PLAYER_DOWNED_OR_DEAD, LOCAL_VARS.DOWN_CHECK)
                end

                -- Update Section 4 with new values
                SECTION_4.UPDATE_VARS({
                    TARGET_LIST = LOCAL_VARS.TARGET_LIST,
                    CURRENT_TARGET_INDEX = LOCAL_VARS.CURRENT_TARGET_INDEX,
                    MULTI_TARGET_ENABLED = LOCAL_VARS.MULTI_TARGET_ENABLED
                })

                STARTER_GUI:SetCore("SendNotification", {
                    Title = "Multi-Target Mode",
                    Text = LOCAL_VARS.MULTI_TARGET_ENABLED and "Enabled - Press Q to add targets" or "Disabled",
                    Duration = LOCAL_VARS.MULTI_TARGET_ENABLED and 3 or 2
                })

            elseif INPUT.KeyCode == Enum.KeyCode.T then
                LOCAL_VARS.DOWN_CHECK = not LOCAL_VARS.DOWN_CHECK
                SECTION_4.SET_DOWN_CHECK(LOCAL_VARS.DOWN_CHECK)

                STARTER_GUI:SetCore("SendNotification", {
                    Title = "Down Check",
                    Text = LOCAL_VARS.DOWN_CHECK and "Enabled - Skip downed players" or "Disabled - Target all players",
                    Duration = 3
                })
                
                if LOCAL_VARS.MULTI_TARGET_ENABLED then 
                    SECTION_2.UPDATE_TARGET_LIST_HIGHLIGHTS(LOCAL_VARS.TARGET_LIST, SECTION_1.IS_PLAYER_DOWNED_OR_DEAD, LOCAL_VARS.DOWN_CHECK) 
                end

            elseif INPUT.KeyCode == Enum.KeyCode.H then
                if not LOCAL_VARS.MULTI_TARGET_ENABLED or not LOCAL_VARS.LOCKED_TARGET then
                    STARTER_GUI:SetCore("SendNotification", {
                        Title = not LOCAL_VARS.MULTI_TARGET_ENABLED and "Multi-Target Mode" or "Add Target Error",
                        Text = not LOCAL_VARS.MULTI_TARGET_ENABLED and "Enable multi-target mode first with F" or "Lock onto a target first with C",
                        Duration = 2
                    })
                    return LOCAL_VARS
                end

                if table.find(LOCAL_VARS.TARGET_LIST, LOCAL_VARS.LOCKED_TARGET) then
                    STARTER_GUI:SetCore("SendNotification", {
                        Title = "Target Already Added", 
                        Text = LOCAL_VARS.LOCKED_TARGET.Name .. " is already in the list", 
                        Duration = 2
                    })
                    return LOCAL_VARS
                end

                table.insert(LOCAL_VARS.TARGET_LIST, LOCAL_VARS.LOCKED_TARGET)
                SECTION_2.UPDATE_TARGET_LIST_HIGHLIGHTS(LOCAL_VARS.TARGET_LIST, SECTION_1.IS_PLAYER_DOWNED_OR_DEAD, LOCAL_VARS.DOWN_CHECK)
                SECTION_4.UPDATE_VARS({TARGET_LIST = LOCAL_VARS.TARGET_LIST})

                STARTER_GUI:SetCore("SendNotification", {
                    Title = "Target Added", 
                    Text = LOCAL_VARS.LOCKED_TARGET.Name .. " (#" .. #LOCAL_VARS.TARGET_LIST .. ")", 
                    Duration = 2,
                    Icon = "rbxthumb://type=AvatarHeadShot&id=" .. LOCAL_VARS.LOCKED_TARGET.UserId .. "&w=150&h=150"
                })

            elseif INPUT.KeyCode == Enum.KeyCode.M then
                if not LOCAL_VARS.MULTI_TARGET_ENABLED or #LOCAL_VARS.TARGET_LIST == 0 then
                    STARTER_GUI:SetCore("SendNotification", {
                        Title = "Clear List Error",
                        Text = LOCAL_VARS.MULTI_TARGET_ENABLED and "No targets to clear" or "Enable multi-target mode (F) first",
                        Duration = 2
                    })
                    return LOCAL_VARS
                end

                local TARGET_COUNT = #LOCAL_VARS.TARGET_LIST
                LOCAL_VARS.TARGET_LIST = {}
                LOCAL_VARS.CURRENT_TARGET_INDEX = 1
                SECTION_2.CLEAR_ALL_TARGET_HIGHLIGHTS()
                SECTION_4.UPDATE_VARS({
                    TARGET_LIST = LOCAL_VARS.TARGET_LIST,
                    CURRENT_TARGET_INDEX = LOCAL_VARS.CURRENT_TARGET_INDEX
                })

                for _, PLAYER in ipairs(PLAYERS:GetPlayers()) do
                    if PLAYER.Character then
                        for _, CHILD in ipairs(PLAYER.Character:GetChildren()) do
                            if CHILD:IsA("Highlight") or CHILD:IsA("BillboardGui") then 
                                CHILD:Destroy() 
                            end
                        end
                    end
                end

                STARTER_GUI:SetCore("SendNotification", {
                    Title = "Target List Cleared", 
                    Text = "Removed " .. TARGET_COUNT .. " targets", 
                    Duration = 2
                })

            elseif INPUT.KeyCode == Enum.KeyCode.N then
                if not LOCAL_VARS.LOCKED_TARGET then
                    STARTER_GUI:SetCore("SendNotification", {
                        Title = "Spectate Error", 
                        Text = "No target locked to spectate", 
                        Duration = 2
                    })
                    return LOCAL_VARS
                end

                if SECTION_3 and SECTION_3.IS_CURRENTLY_SPECTATING and SECTION_3.IS_CURRENTLY_SPECTATING() then
                    SECTION_3.STOP_SPECTATING()
                else
                    SECTION_3.START_SPECTATING(LOCAL_VARS.LOCKED_TARGET)
                end

            elseif INPUT.KeyCode == Enum.KeyCode.LeftAlt then
                if not LOCAL_VARS.MULTI_TARGET_ENABLED or #LOCAL_VARS.TARGET_LIST == 0 then 
                    return LOCAL_VARS 
                end

                local TARGET_TO_REMOVE = SECTION_4.GET_CLOSEST_TARGET_FROM_LIST()
                if TARGET_TO_REMOVE and SECTION_4.REMOVE_TARGET_FROM_LIST(TARGET_TO_REMOVE) then
                    STARTER_GUI:SetCore("SendNotification", {
                        Title = "Removed Target", 
                        Text = TARGET_TO_REMOVE.Name, 
                        Duration = 1,
                        Icon = "rbxthumb://type=AvatarHeadShot&id=" .. TARGET_TO_REMOVE.UserId .. "&w=150&h=150"
                    })

                    -- Get updated target list from Section 4
                    LOCAL_VARS.TARGET_LIST = SECTION_4.GET_TARGET_LIST()

                    if LOCAL_VARS.CURRENT_TARGET_INDEX > #LOCAL_VARS.TARGET_LIST then 
                        LOCAL_VARS.CURRENT_TARGET_INDEX = 1 
                    end
                end

                STARTER_GUI:SetCore("SendNotification", {
                    Title = "Target Count", 
                    Text = tostring(#LOCAL_VARS.TARGET_LIST), 
                    Duration = 1
                })
            end

            return LOCAL_VARS
        end

        local function GET_VARIABLES()
            return LOCAL_VARS
        end
        
        local function UPDATE_VARIABLES(NEW_VARS)
            if not NEW_VARS then return LOCAL_VARS end
            
            for key, value in pairs(NEW_VARS) do
                if LOCAL_VARS[key] ~= nil then
                    LOCAL_VARS[key] = value
                end
            end
            
            return LOCAL_VARS
        end

        local function SETUP_INPUT_HANDLER()
            -- Disconnect previous connection if it exists
            if inputConnection then
                inputConnection:Disconnect()
                inputConnection = nil
            end
            
            -- Create new connection
            inputConnection = USER_INPUT_SERVICE.InputBegan:Connect(function(INPUT, GAME_PROCESSED)
                -- Process input and update local variables
                local updated_vars = HANDLE_INPUT(INPUT, GAME_PROCESSED)
                if updated_vars then
                    for key, value in pairs(updated_vars) do
                        LOCAL_VARS[key] = value
                    end
                end
            end)
            
            return LOCAL_VARS
        end
        
        -- Return the module's public interface
        return {
            SETUP_INPUT_HANDLER = SETUP_INPUT_HANDLER,
            GET_VARIABLES = GET_VARIABLES,
            UPDATE_VARIABLES = UPDATE_VARIABLES
        }
    end
}
