-- Delver's Call - Midnight Storyline Tracker
-- Storyline ID: 6051

local addonName, DCT = ...
local wasShownBeforeCombat = false
local routeRestored = false

local function L(key)
    return DCT.L(key)
end

local function PrintHelp()
    print("|cff00d5ff" .. L("HELP_HEADER") .. "|r")
    print(L("HELP_OPEN"))
    print(L("HELP_SETTINGS"))
    print(L("HELP_COMBAT"))
    print(L("HELP_AUTOHIDE"))
    print(L("HELP_SHOW"))
end

local function PrintMapDebug()
    if not C_Map or not C_Map.GetBestMapForUnit then
        print("|cff00d5ff" .. L("ADDON_TITLE") .. ":|r C_Map no disponible.")
        return
    end

    local mapID = C_Map.GetBestMapForUnit("player")
    print("|cff00d5ff" .. L("ADDON_TITLE") .. ":|r mapID actual = " .. tostring(mapID))

    while type(mapID) == "number" do
        local mapInfo = C_Map.GetMapInfo and C_Map.GetMapInfo(mapID)
        if not mapInfo then
            print("  " .. tostring(mapID) .. " -> sin mapInfo")
            break
        end

        print(("  %s: %s parent=%s type=%s"):format(tostring(mapID), tostring(mapInfo.name), tostring(mapInfo.parentMapID), tostring(mapInfo.mapType)))
        if type(mapInfo.parentMapID) ~= "number" or mapInfo.parentMapID == mapID or mapInfo.parentMapID == 0 then
            break
        end
        mapID = mapInfo.parentMapID
    end

    if DCT.GetRouteDebugLines then
        for _, line in ipairs(DCT.GetRouteDebugLines()) do
            print(line)
        end
    end
end

local function HandleSlash(input)
    input = (input or ""):match("^%s*(.-)%s*$")
    if input == "" then
        DCT.ToggleFrame()
        return
    end

    local command, argument = input:match("^(%S+)%s*(.*)$")
    command = command and command:lower() or ""
    argument = (argument or ""):match("^%s*(.-)%s*$"):lower()

    if command == "settings" or command == "options" or command == "config" then
        DCT.OpenSettings()
    elseif command == "help" or command == "?" then
        PrintHelp()
    elseif command == "debug" or command == "map" then
        PrintMapDebug()
    elseif command == "show" or command == "open" then
        DCT.UpdateTexts()
        DCT.GetFrame():Show()
    elseif command == "hide" or command == "close" then
        DCT.CloseFrame()
    elseif command == "toggle" then
        DCT.ToggleFrame()
    elseif command == "combat" then
        if argument == "enable" or argument == "on" or argument == "hide" then
            DCT.GetUiConfig().hideInCombat = true
            if InCombatLockdown() then
                DCT.GetFrame():Hide()
            end
            print("|cff00d5ff" .. L("ADDON_TITLE") .. ":|r " .. L("COMBAT_ENABLED"))
        elseif argument == "disable" or argument == "off" or argument == "show" then
            DCT.GetUiConfig().hideInCombat = false
            DCT.ApplyStartupVisibility()
            print("|cff00d5ff" .. L("ADDON_TITLE") .. ":|r " .. L("COMBAT_DISABLED"))
        else
            PrintHelp()
        end
    elseif command == "autohide" then
        if argument == "enable" or argument == "on" then
            DCT.GetUiConfig().autohide = true
            DCT.ApplyAutohide()
            print("|cff00d5ff" .. L("ADDON_TITLE") .. ":|r " .. L("AUTOHIDE_ENABLED"))
        elseif argument == "disable" or argument == "off" then
            DCT.GetUiConfig().autohide = false
            DCT.ApplyAutohide()
            print("|cff00d5ff" .. L("ADDON_TITLE") .. ":|r " .. L("AUTOHIDE_DISABLED"))
        else
            PrintHelp()
        end
    else
        PrintHelp()
    end
end

SLASH_DELVERSCALLTRACKER1 = "/dcall"
SLASH_DELVERSCALLTRACKER2 = "/dct"
SLASH_DELVERSCALLTRACKER3 = "/delverscall"
SLASH_DELVERSCALLTRACKER4 = "/delvercalltracker"
SlashCmdList.DELVERSCALLTRACKER = HandleSlash

local eventFrame = CreateFrame("Frame")
local function RestoreRouteOnce()
    if routeRestored then
        return
    end

    routeRestored = true
    if DCT.RestoreActiveRoute then
        DCT.RestoreActiveRoute()
    end
end

eventFrame:SetScript("OnEvent", function(_, event, loadedAddon, ...)
    if event == "ADDON_LOADED" and loadedAddon == addonName then
        DCT.GetConfig()
        DCT.CreateUI()
        DCT.RegisterSettings()
        DCT.ApplyStartupVisibility()
        if C_Timer then
            C_Timer.After(0.2, RestoreRouteOnce)
        else
            RestoreRouteOnce()
        end
        print("|cff00d5ff" .. L("ADDON_TITLE") .. "|r " .. L("LOADED"))
    elseif event == "PLAYER_REGEN_DISABLED" then
        local frame = DCT.GetFrame()
        wasShownBeforeCombat = frame and frame:IsShown()
        if wasShownBeforeCombat and DCT.GetUiConfig().hideInCombat then
            frame:Hide()
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        local frame = DCT.GetFrame()
        if wasShownBeforeCombat and DCT.GetUiConfig().hideInCombat then
            DCT.UpdateTexts()
            frame:Show()
            DCT.ApplyAutohide()
        end
        wasShownBeforeCombat = false
    elseif event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED" or event == "ZONE_CHANGED_NEW_AREA" or event == "ZONE_CHANGED_INDOORS" then
        if event == "PLAYER_ENTERING_WORLD" then
            local isInitialLogin, isReloadingUi = loadedAddon, ...
            RestoreRouteOnce()
            if isInitialLogin or isReloadingUi then
                DCT.ApplyStartupVisibility()
            end
        end
        DCT.ScheduleActiveRouteUpdate()
        local frame = DCT.GetFrame()
        if frame and frame:IsShown() then
            DCT.UpdateQuestStatuses()
        end
    elseif event == "QUEST_LOG_UPDATE" or event == "QUEST_TURNED_IN" or event == "QUEST_ACCEPTED" then
        local frame = DCT.GetFrame()
        if frame and frame:IsShown() then
            DCT.UpdateQuestStatuses()
        end
    end
end)

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("ZONE_CHANGED")
eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
eventFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
eventFrame:RegisterEvent("QUEST_LOG_UPDATE")
eventFrame:RegisterEvent("QUEST_TURNED_IN")
eventFrame:RegisterEvent("QUEST_ACCEPTED")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
