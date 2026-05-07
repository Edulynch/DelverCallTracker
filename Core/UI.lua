local _, DCT = ...

local frame, progressBar, progressText, autohideButton
local trackerPage, tabsFrame, tabDescriptionText, listContainer, emptyText
local closeButton
local questRows = {}
local zoneSections = {}
local tabButtons = {}
local LayoutQuestRows
local activeTabKey = "not_started"
local highlightedQuestID

local function L(key)
    return DCT.L(key)
end

local function IsQuestOnLog(questID)
    if C_QuestLog.IsOnQuest then
        return C_QuestLog.IsOnQuest(questID)
    end

    if C_QuestLog.GetLogIndexForQuestID then
        local logIndex = C_QuestLog.GetLogIndexForQuestID(questID)
        return logIndex ~= nil and logIndex > 0
    end

    return false
end

local function GetQuestStatus(questID)
    if C_QuestLog.IsQuestFlaggedCompleted(questID) then
        return DCT.STATUS.COMPLETED
    end

    if C_QuestLog.IsComplete and C_QuestLog.IsComplete(questID) then
        return DCT.STATUS.READY
    end

    if IsQuestOnLog(questID) then
        return DCT.STATUS.IN_PROGRESS
    end

    return DCT.STATUS.NOT_STARTED
end

local function GetStatusText(status)
    if status == DCT.STATUS.COMPLETED then
        return L("STATUS_DONE")
    elseif status == DCT.STATUS.READY then
        return L("STATUS_READY")
    elseif status == DCT.STATUS.IN_PROGRESS then
        return L("STATUS_ACTIVE")
    end
    return L("STATUS_PENDING")
end

local function GetActiveTab()
    for _, tab in ipairs(DCT.TABS) do
        if tab.key == activeTabKey then
            return tab
        end
    end
    return DCT.TABS[1]
end

local function IsValidTabKey(tabKey)
    for _, tab in ipairs(DCT.TABS) do
        if tab.key == tabKey then
            return true
        end
    end
    return false
end

local function SetActiveTabKey(tabKey)
    if not IsValidTabKey(tabKey) then
        tabKey = DCT.DEFAULT_CONFIG.ui.activeTabKey
    end

    activeTabKey = tabKey
    DCT.GetUiConfig().activeTabKey = tabKey
end

local function IsStatusVisible(status)
    local tab = GetActiveTab()
    return tab and tab.statuses[status]
end

local function UpdateTabButtons(counts)
    counts = counts or {}
    local activeTab = GetActiveTab()
    local button = tabButtons.filter
    if button and activeTab then
        button.text:SetText(L("FILTER_LABEL"):format(L(activeTab.labelKey), counts[activeTab.key] or 0))
        button.text:SetTextColor(1, 0.92, 0.55)
        button.background:SetVertexColor(0.20, 0.14, 0.04, 0.95)
    end

    if tabDescriptionText and activeTab then
        tabDescriptionText:SetText(L(activeTab.descriptionKey))
    end
end

local function LayoutTabButtons(contentWidth)
    local button = tabButtons.filter
    if button then
        button:ClearAllPoints()
        button:SetPoint("LEFT", tabsFrame, "LEFT", 0, 0)
        button:SetSize(contentWidth, 22)
    end
end

local function CreateStatusTabs(parent)
    local button = CreateFrame("Button", nil, parent)
    button:SetHighlightTexture([[Interface\Buttons\UI-Listbox-Highlight2]], "ADD")

    button.background = button:CreateTexture(nil, "BACKGROUND")
    button.background:SetAllPoints()
    button.background:SetTexture("Interface/BUTTONS/WHITE8X8")

    button.text = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    button.text:SetPoint("CENTER")

    button:SetScript("OnClick", function()
        local nextIndex = 1
        for index, tab in ipairs(DCT.TABS) do
            if tab.key == activeTabKey then
                nextIndex = (index % #DCT.TABS) + 1
                break
            end
        end
        SetActiveTabKey(DCT.TABS[nextIndex].key)
        DCT.UpdateQuestStatuses()
    end)
    button:SetScript("OnEnter", function(self)
        DCT.ShowAutohideFrame()
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText(L("FILTER_TOOLTIP"))
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
        DCT.HideAutohideFrame()
    end)
    tabButtons.filter = button
end

local function ShowWaypointTooltip(self, quest)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L("TOOLTIP_ENTRY"), 1, 1, 1)
    GameTooltip:AddLine(quest.name, 0.9, 0.9, 0.9)
    GameTooltip:AddLine(("%s %d: %.2f, %.2f"):format(L("MAP_ID"), quest.mapID, quest.x, quest.y), 0.35, 0.85, 1)
    GameTooltip:AddLine(self.status == DCT.STATUS.READY and L("TOOLTIP_CLICK_READY") or L("TOOLTIP_CLICK"), 0.6, 0.6, 0.6)
    GameTooltip:Show()
end

local function UpdateAutohideButton()
    if not autohideButton then
        return
    end

    local texture = DCT.GetUiConfig().autohide
        and [[Interface\AddOns\MyusKnowledgePointsTracker\Textures\MKPT_AutohideOn.tga]]
        or [[Interface\AddOns\MyusKnowledgePointsTracker\Textures\MKPT_AutohideOff.tga]]

    autohideButton:SetNormalTexture(texture)
    autohideButton:SetHighlightTexture(texture, "BLEND")
    autohideButton:GetNormalTexture():SetVertexColor(DCT.GOLD[1], DCT.GOLD[2], DCT.GOLD[3])
    autohideButton:GetHighlightTexture():SetVertexColor(1, 0.82, 0)
end

function DCT.ShowAutohideFrame()
    if frame and DCT.GetUiConfig().autohide then
        UIFrameFadeIn(frame, 0.12, frame:GetAlpha(), 1)
    end
end

function DCT.HideAutohideFrame()
    if not frame or not DCT.GetUiConfig().autohide or not frame:IsShown() then
        return
    end

    C_Timer.After(0.08, function()
        if frame and frame:IsShown() and DCT.GetUiConfig().autohide and not frame:IsMouseOver() then
            UIFrameFadeOut(frame, 0.20, frame:GetAlpha(), 0)
        end
    end)
end

function DCT.ApplyAutohide()
    UpdateAutohideButton()

    if not frame or not frame:IsShown() then
        return
    end

    if DCT.GetUiConfig().autohide and not frame:IsMouseOver() then
        frame:SetAlpha(0)
    else
        frame:SetAlpha(1)
    end
end

local function AnchorFrameToTopLeft()
    if not frame then
        return
    end

    local left, top = frame:GetLeft(), frame:GetTop()
    if not left or not top then
        return
    end

    local parent = frame:GetParent() or UIParent
    local scale = frame:GetEffectiveScale()
    local parentScale = parent:GetEffectiveScale()
    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", left * scale / parentScale, top * scale / parentScale)
end

local function SetFrameHeightFromTop(height)
    if not frame then
        return
    end

    AnchorFrameToTopLeft()
    frame:SetHeight(height)
end

local function CreateIconButton(parent, texturePath, tooltipText, onClick)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(16, 16)
    button:SetNormalTexture(texturePath)
    button:SetHighlightTexture(texturePath, "BLEND")
    button:GetNormalTexture():SetVertexColor(DCT.GOLD[1], DCT.GOLD[2], DCT.GOLD[3])
    button:GetHighlightTexture():SetVertexColor(1, 0.82, 0)
    button:SetScript("OnClick", onClick)
    button:SetScript("OnEnter", function(self)
        DCT.ShowAutohideFrame()
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText(tooltipText())
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
        DCT.HideAutohideFrame()
    end)
    return button
end

local function ShouldHideAtPlayerLevel()
    local level = UnitLevel and UnitLevel("player") or 0
    return DCT.GetUiConfig().hideAtLevel90 and type(level) == "number" and level >= 90
end

local function SetRowHighlighted(row, highlighted)
    if not row or not row.selectionBorder then
        return
    end

    for _, texture in ipairs(row.selectionBorder) do
        texture:SetShown(highlighted)
    end
end

local function UpdateHighlightedRows()
    for questID, row in pairs(questRows) do
        SetRowHighlighted(row, questID == highlightedQuestID)
    end
end

local function FlashRow(row)
    if not row or not row.selectionFlash then
        return
    end

    row.selectionFlash:Show()
    row.selectionFlash:SetAlpha(0)
    row.selectionFlashAnim:Stop()
    row.selectionFlashAnim:Play()
end

function DCT.HighlightQuest(questID)
    highlightedQuestID = questID
    DCT.GetConfig().highlightedQuestID = questID
    UpdateHighlightedRows()
    FlashRow(questRows[questID])
end

local function CreateRow(parent, quest)
    local ui = DCT.GetUiConfig()
    local row = CreateFrame("Button", nil, parent)
    row:SetSize(ui.width - (DCT.PANEL_PADDING * 2), ui.rowHeight)
    row:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    row.quest = quest

    row.background = row:CreateTexture(nil, "BACKGROUND")
    row.background:SetAllPoints()
    row.background:SetTexture("Interface/BUTTONS/WHITE8X8")
    row.background:SetVertexColor(0.04, 0.04, 0.04, 0.58)

    row.leftText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.leftText:SetPoint("LEFT", row, "LEFT", 9, 0)
    row.leftText:SetWidth(28)
    row.leftText:SetJustifyH("LEFT")
    row.leftText:SetText(quest.step .. ".")

    row.middleText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.middleText:SetPoint("LEFT", row.leftText, "RIGHT", 2, 0)
    row.middleText:SetPoint("RIGHT", row, "RIGHT", -126, 0)
    row.middleText:SetJustifyH("LEFT")
    row.middleText:SetText(quest.name)

    row.rightText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.rightText:SetPoint("RIGHT", row, "RIGHT", -44, 0)
    row.rightText:SetWidth(78)
    row.rightText:SetJustifyH("RIGHT")

    row.pin = row:CreateTexture(nil, "OVERLAY")
    row.pin:SetPoint("RIGHT", row, "RIGHT", -10, 0)
    row.pin:SetSize(18, 18)
    row.pin:SetAtlas("Waypoint-MapPin-Untracked", true)

    row.highlight = row:CreateTexture(nil, "HIGHLIGHT")
    row.highlight:SetAtlas("Professions_Recipe_Hover", false)
    row.highlight:SetPoint("TOPLEFT", row, "TOPLEFT", 34, 0)
    row.highlight:SetPoint("BOTTOMRIGHT")
    row.highlight:SetAlpha(0.7)

    row.glow = row:CreateTexture(nil, "OVERLAY")
    row.glow:SetAtlas("Professions_Recipe_Active", false)
    row.glow:SetPoint("TOPLEFT", row, "TOPLEFT", 34, 0)
    row.glow:SetPoint("BOTTOMRIGHT")
    row.glow:SetAlpha(0.55)
    row.glow:Hide()

    row.selectionFlash = row:CreateTexture(nil, "OVERLAY")
    row.selectionFlash:SetAllPoints()
    row.selectionFlash:SetTexture("Interface/BUTTONS/WHITE8X8")
    row.selectionFlash:SetVertexColor(1, 0.82, 0.12, 0.45)
    row.selectionFlash:SetAlpha(0)
    row.selectionFlash:Hide()

    row.selectionFlashAnim = row.selectionFlash:CreateAnimationGroup()
    local flashIn = row.selectionFlashAnim:CreateAnimation("Alpha")
    flashIn:SetFromAlpha(0)
    flashIn:SetToAlpha(0.45)
    flashIn:SetDuration(0.12)
    flashIn:SetOrder(1)
    local flashOut = row.selectionFlashAnim:CreateAnimation("Alpha")
    flashOut:SetFromAlpha(0.45)
    flashOut:SetToAlpha(0)
    flashOut:SetDuration(0.55)
    flashOut:SetOrder(2)
    row.selectionFlashAnim:SetScript("OnFinished", function()
        row.selectionFlash:Hide()
    end)

    row.selectionBorder = {}
    local borderColor = { 1, 0.76, 0.12, 0.95 }
    local top = row:CreateTexture(nil, "OVERLAY")
    top:SetPoint("TOPLEFT")
    top:SetPoint("TOPRIGHT")
    top:SetHeight(2)
    local bottom = row:CreateTexture(nil, "OVERLAY")
    bottom:SetPoint("BOTTOMLEFT")
    bottom:SetPoint("BOTTOMRIGHT")
    bottom:SetHeight(2)
    local left = row:CreateTexture(nil, "OVERLAY")
    left:SetPoint("TOPLEFT")
    left:SetPoint("BOTTOMLEFT")
    left:SetWidth(2)
    local right = row:CreateTexture(nil, "OVERLAY")
    right:SetPoint("TOPRIGHT")
    right:SetPoint("BOTTOMRIGHT")
    right:SetWidth(2)
    row.selectionBorder = { top, bottom, left, right }
    for _, texture in ipairs(row.selectionBorder) do
        texture:SetTexture("Interface/BUTTONS/WHITE8X8")
        texture:SetVertexColor(borderColor[1], borderColor[2], borderColor[3], borderColor[4])
        texture:Hide()
    end

    row:SetScript("OnClick", function(self, button)
        if button == "RightButton" then
            DCT.ClearActiveRoute()
            DCT.HighlightQuest(nil)
            return
        end

        DCT.HighlightQuest(self.quest.id)
        DCT.SetQuestWaypoint(self.quest, self.status)
    end)
    row:SetScript("OnEnter", function(self)
        DCT.ShowAutohideFrame()
        ShowWaypointTooltip(self, self.quest)
    end)
    row:SetScript("OnLeave", function()
        GameTooltip:Hide()
        DCT.HideAutohideFrame()
    end)

    return row
end

local function CreateZoneHeader(parent, zoneKey)
    local ui = DCT.GetUiConfig()
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(ui.width - (DCT.PANEL_PADDING * 2), 24)
    button.zoneKey = zoneKey

    button.background = button:CreateTexture(nil, "BACKGROUND")
    button.background:SetAllPoints()
    button.background:SetTexture("Interface/BUTTONS/WHITE8X8")
    button.background:SetVertexColor(0.10, 0.08, 0.02, 0.85)

    button.arrow = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    button.arrow:SetPoint("LEFT", 8, 0)
    button.arrow:SetWidth(14)

    button.text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.text:SetPoint("LEFT", button.arrow, "RIGHT", 4, 0)
    button.text:SetTextColor(DCT.GOLD[1], DCT.GOLD[2], DCT.GOLD[3])

    button.line = button:CreateTexture(nil, "ARTWORK")
    button.line:SetPoint("LEFT", button.text, "RIGHT", 8, 0)
    button.line:SetPoint("RIGHT", button, "RIGHT", -6, 0)
    button.line:SetHeight(1)
    button.line:SetColorTexture(DCT.GOLD[1], DCT.GOLD[2], DCT.GOLD[3], 0.35)

    button:SetHighlightTexture([[Interface\Buttons\UI-Listbox-Highlight2]], "ADD")
    button:SetScript("OnEnter", DCT.ShowAutohideFrame)
    button:SetScript("OnLeave", DCT.HideAutohideFrame)

    return button
end

function DCT.UpdateQuestStatuses()
    local finishedCount = 0
    local tabCounts = {}

    for _, quest in ipairs(DCT.QUESTS) do
        local row = questRows[quest.id]
        local status = GetQuestStatus(quest.id)
        local color = DCT.GetStatusColor(status)

        if status >= DCT.STATUS.READY then
            finishedCount = finishedCount + 1
        end

        for _, tab in ipairs(DCT.TABS) do
            if tab.statuses[status] then
                tabCounts[tab.key] = (tabCounts[tab.key] or 0) + 1
            end
        end

        row.status = status
        row.rightText:SetText(GetStatusText(status))
        row.rightText:SetTextColor(color[1], color[2], color[3])
        row.glow:SetShown(status == DCT.STATUS.IN_PROGRESS or status == DCT.STATUS.READY)
        row.pin:SetVertexColor(color[1], color[2], color[3])
    end

    progressBar:SetValue(finishedCount)
    progressText:SetText(L("READY_COUNT"):format(finishedCount, #DCT.QUESTS))
    UpdateTabButtons(tabCounts)

    if LayoutQuestRows then
        LayoutQuestRows()
    end
end

function DCT.ApplyUiOptions()
    if not frame then
        return
    end

    local ui = DCT.GetUiConfig()
    local contentWidth = ui.width - (DCT.PANEL_PADDING * 2)
    frame:SetWidth(ui.width)
    frame:SetScale(ui.scale)
    trackerPage:SetPoint("TOPLEFT", frame, "TOPLEFT", DCT.PANEL_PADDING, -30)
    trackerPage:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -DCT.PANEL_PADDING, DCT.PANEL_PADDING)
    tabsFrame:SetWidth(contentWidth)
    listContainer:SetWidth(contentWidth)
    progressBar:SetHeight(math.max(14, ui.rowHeight * 0.52))
    LayoutTabButtons(contentWidth)

    frame.title:SetFontHeight(ui.fontSize + 1)
    progressText:SetFontHeight(ui.fontSize)
    tabDescriptionText:SetWidth(contentWidth)
    tabDescriptionText:SetFontHeight(math.max(10, ui.fontSize - 1))
    for _, button in pairs(tabButtons) do
        button.text:SetFontHeight(ui.fontSize)
    end

    for _, section in ipairs(zoneSections) do
        section.header:SetWidth(contentWidth)
        section.header.text:SetFontHeight(ui.fontSize)
        section.header.arrow:SetFontHeight(ui.fontSize)
    end

    for _, row in pairs(questRows) do
        row:SetSize(contentWidth, ui.rowHeight)
        row.leftText:SetFontHeight(ui.fontSize)
        row.middleText:SetFontHeight(ui.fontSize)
        row.rightText:SetFontHeight(ui.fontSize)
        row.pin:SetSize(math.min(20, math.max(14, ui.rowHeight - 14)), math.min(20, math.max(14, ui.rowHeight - 14)))
    end

    DCT.UpdateQuestStatuses()
    DCT.ApplyAutohide()
end

function DCT.UpdateTexts()
    frame.title:SetText(L("HEADER"))
    closeButton.tooltipText = L("CLOSE")
    local activeTab = GetActiveTab()
    if tabDescriptionText and activeTab then
        tabDescriptionText:SetText(L(activeTab.descriptionKey))
    end

    for _, section in ipairs(zoneSections) do
        section.header.text:SetText((DCT.ZONE_LABELS[DCT.GetLanguage()] and DCT.ZONE_LABELS[DCT.GetLanguage()][section.zoneKey]) or section.zoneName)
    end

    for _, quest in ipairs(DCT.QUESTS) do
        local row = questRows[quest.id]
        row.quest = quest
        row.middleText:SetText(quest.name)
    end

    DCT.ApplyUiOptions()
end

local function CreateTrackerPage(parent)
    trackerPage = CreateFrame("Frame", nil, parent)
    trackerPage:SetPoint("TOPLEFT", parent, "TOPLEFT", DCT.PANEL_PADDING, -30)
    trackerPage:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -DCT.PANEL_PADDING, DCT.PANEL_PADDING)

    progressBar = CreateFrame("StatusBar", nil, trackerPage)
    progressBar:SetPoint("TOPLEFT", trackerPage, "TOPLEFT", 0, 0)
    progressBar:SetPoint("RIGHT", trackerPage, "RIGHT", 0, 0)
    progressBar:SetHeight(18)
    progressBar:SetMinMaxValues(0, #DCT.QUESTS)
    progressBar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
    progressBar:SetStatusBarColor(0.10, 0.45, 0.86)

    local progressBg = progressBar:CreateTexture(nil, "BACKGROUND")
    progressBg:SetAllPoints()
    progressBg:SetTexture("Interface/BUTTONS/WHITE8X8")
    progressBg:SetVertexColor(0.04, 0.04, 0.04, 0.9)

    progressText = progressBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    progressText:SetPoint("CENTER")

    tabsFrame = CreateFrame("Frame", nil, trackerPage)
    tabsFrame:SetPoint("TOPLEFT", progressBar, "BOTTOMLEFT", 0, -8)
    tabsFrame:SetPoint("RIGHT", trackerPage, "RIGHT", 0, 0)
    tabsFrame:SetHeight(24)
    CreateStatusTabs(tabsFrame)

    tabDescriptionText = trackerPage:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    tabDescriptionText:SetPoint("TOPLEFT", tabsFrame, "BOTTOMLEFT", 4, -7)
    tabDescriptionText:SetPoint("RIGHT", trackerPage, "RIGHT", -4, 0)
    tabDescriptionText:SetJustifyH("LEFT")
    tabDescriptionText:SetText(L("TAB_NOT_STARTED_DESC"))

    listContainer = CreateFrame("Frame", nil, trackerPage)
    listContainer:SetPoint("TOPLEFT", tabDescriptionText, "BOTTOMLEFT", -4, -8)
    listContainer:SetSize(DCT.GetUiConfig().width - (DCT.PANEL_PADDING * 2), 1)

    emptyText = listContainer:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    emptyText:SetPoint("TOPLEFT", listContainer, "TOPLEFT", 9, -10)
    emptyText:SetText(L("EMPTY_TAB"))
    emptyText:Hide()

    local currentSection
    for _, quest in ipairs(DCT.QUESTS) do
        if not currentSection or currentSection.zoneKey ~= quest.zoneKey then
            local header = CreateZoneHeader(listContainer, quest.zoneKey)
            currentSection = {
                zoneKey = quest.zoneKey,
                zoneName = quest.zone,
                header = header,
                rows = {},
                collapsed = false,
            }
            local section = currentSection
            header:SetScript("OnClick", function()
                section.collapsed = not section.collapsed
                LayoutQuestRows()
            end)
            table.insert(zoneSections, currentSection)
        end

        local row = CreateRow(listContainer, quest)
        questRows[quest.id] = row
        table.insert(currentSection.rows, row)
    end

    LayoutQuestRows = function()
        local yOffset = 0
        local visibleRows = 0
        for _, section in ipairs(zoneSections) do
            local sectionHasVisibleRows = false

            for _, row in ipairs(section.rows) do
                if IsStatusVisible(row.status or DCT.STATUS.NOT_STARTED) then
                    sectionHasVisibleRows = true
                    break
                end
            end

            section.header:ClearAllPoints()
            if sectionHasVisibleRows then
                section.header:SetPoint("TOPLEFT", listContainer, "TOPLEFT", 0, -yOffset)
                section.header.arrow:SetText(section.collapsed and "+" or "-")
                section.header:Show()
                yOffset = yOffset + 26
            else
                section.header:Hide()
            end

            for _, row in ipairs(section.rows) do
                row:ClearAllPoints()
                if section.collapsed or not IsStatusVisible(row.status or DCT.STATUS.NOT_STARTED) then
                    row:Hide()
                else
                    row:SetPoint("TOPLEFT", listContainer, "TOPLEFT", 0, -yOffset)
                    row:Show()
                    yOffset = yOffset + DCT.GetUiConfig().rowHeight + 2
                    visibleRows = visibleRows + 1
                end
            end
        end

        if visibleRows == 0 then
            emptyText:SetText(L("EMPTY_TAB"))
            emptyText:Show()
            yOffset = 32
        else
            emptyText:Hide()
        end

        listContainer:SetHeight(yOffset)

        if frame then
            SetFrameHeightFromTop(math.max(DCT.MIN_FRAME_HEIGHT, yOffset + 118))
        end
    end
end

function DCT.CreateUI()
    SetActiveTabKey(DCT.GetUiConfig().activeTabKey)

    frame = CreateFrame("Frame", "DelverCallTrackerFrame", UIParent, "BackdropTemplate")
    frame:SetPoint("CENTER")
    frame:SetSize(DCT.GetUiConfig().width, 220)
    frame:SetFrameStrata("LOW")
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        AnchorFrameToTopLeft()
    end)
    frame:SetScript("OnEnter", DCT.ShowAutohideFrame)
    frame:SetScript("OnLeave", DCT.HideAutohideFrame)
    frame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    frame:SetBackdropColor(0.02, 0.02, 0.02, 0.86)
    frame:Hide()

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.title:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 4, 2)
    frame.title:SetTextColor(DCT.GOLD[1], DCT.GOLD[2], DCT.GOLD[3])

    autohideButton = CreateIconButton(frame, [[Interface\AddOns\MyusKnowledgePointsTracker\Textures\MKPT_AutohideOff.tga]], function() return L("AUTOHIDE") end, function()
        DCT.GetUiConfig().autohide = not DCT.GetUiConfig().autohide
        DCT.ApplyAutohide()
        print("|cff00d5ff" .. L("ADDON_TITLE") .. ":|r " .. (DCT.GetUiConfig().autohide and L("AUTOHIDE_ENABLED") or L("AUTOHIDE_DISABLED")))
    end)
    autohideButton:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", -20, 0)

    closeButton = CreateIconButton(frame, [[Interface\AddOns\MyusKnowledgePointsTracker\Textures\MKPT_Close.tga]], function() return closeButton.tooltipText or L("CLOSE") end, function()
        frame:Hide()
        print("|cff00d5ff" .. L("ADDON_TITLE") .. ":|r " .. L("CLOSE_MESSAGE"))
    end)
    closeButton:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 0, 0)

    CreateTrackerPage(frame)
    highlightedQuestID = DCT.GetConfig().highlightedQuestID
    UpdateHighlightedRows()
    LayoutQuestRows()
    DCT.UpdateTexts()
end

function DCT.ApplyStartupVisibility()
    if not frame then
        return
    end

    if ShouldHideAtPlayerLevel() then
        frame:Hide()
        return
    end

    if DCT.GetUiConfig().hideInCombat and InCombatLockdown() then
        frame:Hide()
        return
    end

    frame:Show()
    DCT.ApplyAutohide()
end

function DCT.ToggleFrame()
    if frame:IsShown() then
        frame:Hide()
        return
    end

    DCT.UpdateTexts()
    frame:SetAlpha(1)
    frame:Show()
end

function DCT.CloseFrame()
    frame:Hide()
    print("|cff00d5ff" .. L("ADDON_TITLE") .. ":|r " .. L("CLOSE_MESSAGE"))
end

function DCT.GetFrame()
    return frame
end
