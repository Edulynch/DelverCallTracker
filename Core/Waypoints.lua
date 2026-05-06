local addonName, DCT = ...

local activeRoute
local activeRouteIndex = 0
local activeRouteStepMapID
local activeTomTomUID
local routeTicker

local ROUTE_ADVANCE_DISTANCE_YARDS = 1
local ROUTE_ADVANCE_DISTANCE_FALLBACK = 0.15

local function L(key)
    return DCT.L(key)
end

local function SetWaypointPoint(mapID, xPercent, yPercent, title)
    local x = xPercent / 100
    local y = yPercent / 100
    local usedTomTom = false

    if C_Map and C_Map.SetUserWaypoint and UiMapPoint and UiMapPoint.CreateFromCoordinates then
        C_Map.SetUserWaypoint(UiMapPoint.CreateFromCoordinates(mapID, x, y))

        if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then
            C_SuperTrack.SetSuperTrackedUserWaypoint(true)
        end
    end

    if TomTom and TomTom.AddWaypoint then
        if activeTomTomUID and TomTom.RemoveWaypoint then
            pcall(TomTom.RemoveWaypoint, TomTom, activeTomTomUID)
            activeTomTomUID = nil
        end

        local opts = {
            title = title,
            from = addonName,
            crazy = true,
            arrivaldistance = ROUTE_ADVANCE_DISTANCE_YARDS,
            cleardistance = 0,
            persistent = false,
            silent = true,
        }
        local uid = TomTom:AddWaypoint(mapID, x, y, opts)
        activeTomTomUID = uid
        if uid and TomTom.SetCrazyArrow then
            TomTom:SetCrazyArrow(uid, opts.arrivaldistance, title)
        end
        usedTomTom = true
        return true, "tomtom"
    end

    if not usedTomTom and C_Map and C_Map.SetUserWaypoint and UiMapPoint and UiMapPoint.CreateFromCoordinates then
        return true, "native"
    end

    return false
end

local function StopRouteTicker()
    if routeTicker then
        routeTicker:Cancel()
        routeTicker = nil
    end
end

local function NormalizePoint(mapID, x, y, descKey, title)
    if type(mapID) ~= "number" or type(x) ~= "number" or type(y) ~= "number" then
        return nil
    end

    if x <= 1 and y <= 1 then
        x = x * 100
        y = y * 100
    end

    return { mapID = mapID, x = x, y = y, descKey = descKey, title = title }
end

local function GetQuestPOIMapID(questID)
    if _G.GetQuestUiMapID then
        local ok, mapID = pcall(_G.GetQuestUiMapID, questID)
        if ok and type(mapID) == "number" then
            return mapID
        end
    end

    if C_QuestLog.GetMapForQuestPOIs then
        local ok, mapID = pcall(C_QuestLog.GetMapForQuestPOIs)
        if ok and type(mapID) == "number" then
            return mapID
        end
    end

    return nil
end

local function GetQuestPOIWaypoint(quest)
    if not QuestPOIGetIconInfo then
        return nil
    end

    if C_QuestLog.SetSelectedQuest then
        pcall(C_QuestLog.SetSelectedQuest, quest.id)
    end

    if C_QuestLog.GetNextWaypoint then
        pcall(C_QuestLog.GetNextWaypoint, quest.id)
    end

    if QuestPOIUpdateIcons then
        pcall(QuestPOIUpdateIcons)
    end

    local ok, _, x, y = pcall(QuestPOIGetIconInfo, quest.id)
    if not ok then
        return nil
    end

    local mapID = GetQuestPOIMapID(quest.id)
    return NormalizePoint(mapID, x, y, "ROUTE_TURNIN", L("TURNIN_TITLE"):format(quest.name))
end

local function GetQuestLogWaypoint(quest)
    if not C_QuestLog then
        return nil
    end

    if C_QuestLog.SetSelectedQuest then
        pcall(C_QuestLog.SetSelectedQuest, quest.id)
    end

    if C_QuestLog.GetNextWaypoint then
        local ok, mapID, x, y = pcall(C_QuestLog.GetNextWaypoint, quest.id)
        if ok then
            if type(mapID) == "table" then
                local point = mapID
                mapID = point.uiMapID or point.mapID or point[1]
                x = point.x or point[2]
                y = point.y or point[3]
            end

            local point = NormalizePoint(mapID, x, y, "ROUTE_TURNIN", L("TURNIN_TITLE"):format(quest.name))
            if point then
                return point
            end
        end
    end

    local point = GetQuestPOIWaypoint(quest)
    if point then
        return point
    end

    local currentMapID = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
    if currentMapID and C_QuestLog.GetNextWaypointForMap then
        local ok, x, y = pcall(C_QuestLog.GetNextWaypointForMap, quest.id, currentMapID)
        if ok then
            local point = NormalizePoint(currentMapID, x, y, "ROUTE_TURNIN", L("TURNIN_TITLE"):format(quest.name))
            if point then
                return point
            end
        end

        ok, x, y = pcall(C_QuestLog.GetNextWaypointForMap, currentMapID, quest.id)
        if ok then
            local point = NormalizePoint(currentMapID, x, y, "ROUTE_TURNIN", L("TURNIN_TITLE"):format(quest.name))
            if point then
                return point
            end
        end
    end

    return nil
end

local function GetStaticTurnInWaypoint(quest)
    local point = DCT.TURN_IN_POINTS and DCT.TURN_IN_POINTS[quest.id]
    if not point then
        return nil
    end

    return NormalizePoint(point.mapID, point.x, point.y, "ROUTE_TURNIN", L("TURNIN_TITLE"):format(quest.name))
end

local function GetRouteZone(mapID)
    while type(mapID) == "number" do
        local routeZone = DCT.ROUTE_ZONE_BY_MAP_ID[mapID]
        if routeZone then
            return routeZone
        end

        if not C_Map or not C_Map.GetMapInfo then
            return nil
        end

        local mapInfo = C_Map.GetMapInfo(mapID)
        local parentMapID = mapInfo and mapInfo.parentMapID
        if type(parentMapID) ~= "number" or parentMapID == mapID then
            return nil
        end
        mapID = parentMapID
    end

    return nil
end

local function BuildRouteToPoint(point, currentMapID)
    local route = {}
    local currentRouteZone = GetRouteZone(currentMapID)
    local targetRouteZone = GetRouteZone(point.mapID)
    local needsZoneRoute = currentMapID ~= point.mapID and currentRouteZone ~= targetRouteZone

    if needsZoneRoute and currentRouteZone then
        local silvermoonStep = DCT.ROUTE_TO_SILVERMOON[currentRouteZone]
        if silvermoonStep then
            table.insert(route, silvermoonStep)
        end
    end

    if needsZoneRoute and targetRouteZone then
        local silvermoonStep = DCT.ROUTE_FROM_SILVERMOON[targetRouteZone]
        if silvermoonStep then
            table.insert(route, silvermoonStep)
        end
    end

    table.insert(route, point)
    return route
end

local function BuildRoute(quest, currentMapID)
    return BuildRouteToPoint({ mapID = quest.mapID, x = quest.x, y = quest.y, descKey = "ROUTE_FINAL", title = "Delver's Call: " .. quest.name }, currentMapID)
end

local function IsPlayerNearStep(step, currentMapID)
    if not step or currentMapID ~= step.mapID or not C_Map or not C_Map.GetPlayerMapPosition then
        return false
    end

    local position = C_Map.GetPlayerMapPosition(currentMapID, "player")
    if not position or not position.GetXY then
        return false
    end

    local playerX, playerY = position:GetXY()
    if type(playerX) ~= "number" or type(playerY) ~= "number" then
        return false
    end

    local stepX = step.x / 100
    local stepY = step.y / 100

    if C_Map.GetWorldPosFromMapPos and UiMapPoint and UiMapPoint.CreateFromCoordinates then
        local okPlayer, playerInstanceID, playerWorldPos = pcall(C_Map.GetWorldPosFromMapPos, currentMapID, UiMapPoint.CreateFromCoordinates(currentMapID, playerX, playerY))
        local okStep, stepInstanceID, stepWorldPos = pcall(C_Map.GetWorldPosFromMapPos, currentMapID, UiMapPoint.CreateFromCoordinates(currentMapID, stepX, stepY))

        if okPlayer and okStep and playerInstanceID == stepInstanceID and playerWorldPos and stepWorldPos and playerWorldPos.GetXY and stepWorldPos.GetXY then
            local playerWorldX, playerWorldY = playerWorldPos:GetXY()
            local stepWorldX, stepWorldY = stepWorldPos:GetXY()
            if type(playerWorldX) == "number" and type(playerWorldY) == "number" and type(stepWorldX) == "number" and type(stepWorldY) == "number" then
                local worldDx = playerWorldX - stepWorldX
                local worldDy = playerWorldY - stepWorldY
                return (worldDx * worldDx + worldDy * worldDy) <= (ROUTE_ADVANCE_DISTANCE_YARDS * ROUTE_ADVANCE_DISTANCE_YARDS)
            end
        end
    end

    local maxDistance = ROUTE_ADVANCE_DISTANCE_FALLBACK / 100
    local dx = playerX - stepX
    local dy = playerY - stepY

    return (dx * dx + dy * dy) <= (maxDistance * maxDistance)
end

local function EnsureRouteTicker()
    if routeTicker or not C_Timer or not activeRoute or activeRouteIndex <= 0 or activeRouteIndex >= #activeRoute then
        return
    end

    routeTicker = C_Timer.NewTicker(0.5, function()
        if not activeRoute or activeRouteIndex <= 0 or activeRouteIndex >= #activeRoute then
            StopRouteTicker()
            return
        end

        DCT.UpdateActiveRoute()
    end)
end

local function ShouldAdvanceAfterMapChange(currentMapID, nextStep)
    if not nextStep or activeRouteStepMapID == currentMapID then
        return false
    end

    if currentMapID == nextStep.mapID then
        return true
    end

    local currentRouteZone = GetRouteZone(currentMapID)
    local nextRouteZone = GetRouteZone(nextStep.mapID)
    local previousRouteZone = GetRouteZone(activeRouteStepMapID)

    if currentRouteZone == "SM" and previousRouteZone and previousRouteZone ~= "SM" then
        return true
    end

    return currentRouteZone and currentRouteZone == nextRouteZone and currentRouteZone ~= previousRouteZone
end

local function FindPendingStepForCurrentMap(currentMapID)
    local currentRouteZone = GetRouteZone(currentMapID)
    local previousRouteZone = GetRouteZone(activeRouteStepMapID)

    if activeRouteStepMapID == currentMapID or (currentRouteZone and currentRouteZone == previousRouteZone) then
        return nil
    end

    for index = activeRouteIndex + 1, #activeRoute do
        local step = activeRoute[index]
        if step.mapID == currentMapID then
            return index
        end

        local stepRouteZone = GetRouteZone(step.mapID)
        if currentRouteZone and currentRouteZone == stepRouteZone then
            return index
        end
    end

    return nil
end

local function SaveActiveRoute()
    local config = DCT.GetConfig()
    if not activeRoute or activeRouteIndex <= 0 then
        config.activeRoute = nil
        return
    end

    local savedRoute = {}
    for index, step in ipairs(activeRoute) do
        savedRoute[index] = {
            mapID = step.mapID,
            x = step.x,
            y = step.y,
            descKey = step.descKey,
            title = step.title,
        }
    end

    config.activeRoute = {
        index = activeRouteIndex,
        stepMapID = activeRouteStepMapID,
        route = savedRoute,
    }
end

function DCT.ClearActiveRoute()
    if activeTomTomUID and TomTom and TomTom.RemoveWaypoint then
        pcall(TomTom.RemoveWaypoint, TomTom, activeTomTomUID)
    end

    activeTomTomUID = nil
    activeRoute = nil
    activeRouteIndex = 0
    activeRouteStepMapID = nil
    StopRouteTicker()

    if C_Map and C_Map.ClearUserWaypoint then
        C_Map.ClearUserWaypoint()
    end

    DCT.GetConfig().activeRoute = nil
end

local function SetRouteStep(index)
    if not activeRoute or not activeRoute[index] then
        activeRoute = nil
        activeRouteIndex = 0
        activeRouteStepMapID = nil
        SaveActiveRoute()
        StopRouteTicker()
        return
    end

    activeRouteIndex = index
    activeRouteStepMapID = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
    local step = activeRoute[index]
    local title = step.title or L(step.descKey)
    local ok, source = SetWaypointPoint(step.mapID, step.x, step.y, title)

    if not ok then
        print("|cff00d5ff" .. L("ADDON_TITLE") .. ":|r " .. L("WAYPOINT_FAILED"))
        return
    end

    SaveActiveRoute()

    if activeRouteIndex >= #activeRoute then
        StopRouteTicker()
    else
        EnsureRouteTicker()
    end

    if index > 1 then
        print("|cff00d5ff" .. L("ADDON_TITLE") .. ":|r " .. L("ROUTE_NEXT"):format(L(step.descKey)))
    elseif source == "tomtom" then
        print(("|cff00d5ff%s:|r " .. L("WAYPOINT_TOMTOM")):format(L("ADDON_TITLE"), title, step.mapID, step.x, step.y))
    else
        print(("|cff00d5ff%s:|r " .. L("WAYPOINT_NATIVE")):format(L("ADDON_TITLE"), title, step.mapID, step.x, step.y))
    end
end

function DCT.RestoreActiveRoute()
    local saved = DCT.GetConfig().activeRoute
    if type(saved) ~= "table" or type(saved.route) ~= "table" or type(saved.index) ~= "number" then
        return
    end

    activeRoute = saved.route
    activeRouteIndex = 0
    activeRouteStepMapID = nil

    local savedStepMapID = saved.stepMapID
    SetRouteStep(saved.index)
    activeRouteStepMapID = savedStepMapID
    SaveActiveRoute()
    EnsureRouteTicker()

    if C_Timer then
        C_Timer.After(0.2, DCT.UpdateActiveRoute)
        C_Timer.After(0.8, DCT.UpdateActiveRoute)
    else
        DCT.UpdateActiveRoute()
    end
end

function DCT.SetWaypoint(quest)
    local currentMapID = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
    activeRoute = BuildRoute(quest, currentMapID)
    activeRouteIndex = 0
    activeRouteStepMapID = nil

    local startIndex = 1
    if currentMapID == quest.mapID then
        startIndex = #activeRoute
    end

    print("|cff00d5ff" .. L("ADDON_TITLE") .. ":|r " .. L("ROUTE_STARTED"):format(quest.name))
    SetRouteStep(startIndex)
    EnsureRouteTicker()
end

function DCT.SetQuestWaypoint(quest, status)
    if status == DCT.STATUS.READY then
        local turnInPoint = GetStaticTurnInWaypoint(quest) or GetQuestLogWaypoint(quest)
        if turnInPoint then
            local currentMapID = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
            activeRoute = BuildRouteToPoint(turnInPoint, currentMapID)
            activeRouteIndex = 0
            activeRouteStepMapID = nil

            local startIndex = 1
            if currentMapID == turnInPoint.mapID then
                startIndex = #activeRoute
            end

            print("|cff00d5ff" .. L("ADDON_TITLE") .. ":|r " .. L("ROUTE_STARTED"):format(quest.name))
            SetRouteStep(startIndex)
            EnsureRouteTicker()
            return
        end
    end

    DCT.SetWaypoint(quest)
end

function DCT.UpdateActiveRoute()
    if not activeRoute or activeRouteIndex <= 0 then
        return
    end

    local currentMapID = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
    if not currentMapID then
        return
    end

    local nextStep = activeRoute[activeRouteIndex + 1]
    if ShouldAdvanceAfterMapChange(currentMapID, nextStep) then
        SetRouteStep(activeRouteIndex + 1)
        return
    end

    local pendingStepIndex = FindPendingStepForCurrentMap(currentMapID)
    if pendingStepIndex then
        SetRouteStep(pendingStepIndex)
        return
    end

    if nextStep and nextStep.mapID == currentMapID and IsPlayerNearStep(activeRoute[activeRouteIndex], currentMapID) then
        SetRouteStep(activeRouteIndex + 1)
    end
end

function DCT.GetRouteDebugLines()
    local lines = {}
    table.insert(lines, "routeActive=" .. tostring(activeRoute ~= nil) .. " index=" .. tostring(activeRouteIndex) .. " stepMap=" .. tostring(activeRouteStepMapID))

    if not activeRoute then
        return lines
    end

    for index, step in ipairs(activeRoute) do
        table.insert(lines, ("  step %d: map=%s zone=%s x=%.2f y=%.2f desc=%s"):format(index, tostring(step.mapID), tostring(GetRouteZone(step.mapID)), step.x or 0, step.y or 0, tostring(step.descKey)))
    end

    return lines
end

function DCT.ScheduleActiveRouteUpdate()
    DCT.UpdateActiveRoute()

    if not C_Timer then
        return
    end

    C_Timer.After(0.2, DCT.UpdateActiveRoute)
    C_Timer.After(0.8, DCT.UpdateActiveRoute)
    C_Timer.After(2.0, DCT.UpdateActiveRoute)
end
