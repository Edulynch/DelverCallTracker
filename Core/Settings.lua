local _, DCT = ...

local settingsCategoryID

local function L(key)
    return DCT.L(key)
end

function DCT.OpenSettings()
    if settingsCategoryID and Settings and Settings.OpenToCategory then
        Settings.OpenToCategory(settingsCategoryID)
        print("|cff00d5ff" .. L("ADDON_TITLE") .. ":|r " .. L("SETTINGS_OPENED"))
    end
end

function DCT.RegisterSettings()
    if not Settings or not Settings.RegisterVerticalLayoutCategory then
        return
    end

    local category, layout = Settings.RegisterVerticalLayoutCategory(L("ADDON_TITLE"))
    settingsCategoryID = category:GetID()
    local appearanceSubcategory, appearanceLayout = Settings.RegisterVerticalLayoutSubcategory(category, L("SETTINGS_APPEARANCE"))
    local howToUseSubcategory, howToUseLayout = Settings.RegisterVerticalLayoutSubcategory(category, L("HOW_TO_USE"))
    Settings.RegisterAddOnCategory(category)
    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L("SETTINGS_GENERAL")))

    local function GetLanguageOptions()
        local container = Settings.CreateControlTextContainer()
        container:Add("auto", L("LANG_AUTO"))
        container:Add("en", L("LANG_EN"))
        container:Add("es", L("LANG_ES"))
        return container:GetData()
    end

    local setting = Settings.RegisterProxySetting(
        category,
        "DCT_Language",
        Settings.VarType.String,
        L("SETTINGS_LANGUAGE"),
        "auto",
        function() return DCT.GetConfig().language end,
        function(value)
            DCT.GetConfig().language = value
            if DCT.GetFrame() then
                DCT.UpdateTexts()
            end
        end
    )

    Settings.CreateDropdown(category, setting, GetLanguageOptions, L("SETTINGS_LANGUAGE_TIP"))

    do
        local setting = Settings.RegisterProxySetting(
            category,
            "DCT_HideInCombat",
            Settings.VarType.Boolean,
            L("HIDE_IN_COMBAT"),
            DCT.DEFAULT_CONFIG.ui.hideInCombat,
            function() return DCT.GetUiConfig().hideInCombat end,
            function(value)
                DCT.GetUiConfig().hideInCombat = value
                if value and InCombatLockdown() and DCT.GetFrame() then
                    DCT.GetFrame():Hide()
                elseif not value then
                    DCT.ApplyStartupVisibility()
                end
            end
        )
        Settings.CreateCheckbox(category, setting, L("HIDE_IN_COMBAT_TIP"))
    end

    do
        local setting = Settings.RegisterProxySetting(
            category,
            "DCT_Autohide",
            Settings.VarType.Boolean,
            L("AUTOHIDE"),
            DCT.DEFAULT_CONFIG.ui.autohide,
            function() return DCT.GetUiConfig().autohide end,
            function(value)
                DCT.GetUiConfig().autohide = value
                DCT.ApplyAutohide()
            end
        )
        Settings.CreateCheckbox(category, setting, L("AUTOHIDE_TIP"))
    end

    do
        local setting = Settings.RegisterProxySetting(
            category,
            "DCT_HideAtLevel90",
            Settings.VarType.Boolean,
            L("HIDE_AT_LEVEL_90"),
            DCT.DEFAULT_CONFIG.ui.hideAtLevel90,
            function() return DCT.GetUiConfig().hideAtLevel90 end,
            function(value)
                DCT.GetUiConfig().hideAtLevel90 = value
                if not value then
                    DCT.ApplyStartupVisibility()
                end
            end
        )
        Settings.CreateCheckbox(category, setting, L("HIDE_AT_LEVEL_90_TIP"))
    end

    appearanceLayout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L("SETTINGS_APPEARANCE")))

    local function CreateSlider(variableName, labelKey, tooltipKey, defaultValue, minValue, maxValue, step, getter, setter, formatter)
        local setting = Settings.RegisterProxySetting(
            appearanceSubcategory,
            variableName,
            Settings.VarType.Number,
            L(labelKey),
            defaultValue,
            getter,
            setter
        )
        local options = Settings.CreateSliderOptions(minValue, maxValue, step)
        options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, formatter or function(value)
            return string.format("%d", value)
        end)
        Settings.CreateSlider(appearanceSubcategory, setting, options, L(tooltipKey))
    end

    CreateSlider("DCT_FontSize", "FONT_SIZE", "FONT_SIZE_TIP", DCT.DEFAULT_CONFIG.ui.fontSize, 9, 18, 1,
        function() return DCT.GetUiConfig().fontSize end,
        function(value) DCT.GetUiConfig().fontSize = value; DCT.ApplyUiOptions() end)

    CreateSlider("DCT_PanelWidth", "PANEL_WIDTH", "PANEL_WIDTH_TIP", DCT.DEFAULT_CONFIG.ui.width, 360, 620, 10,
        function() return DCT.GetUiConfig().width end,
        function(value) DCT.GetUiConfig().width = value; DCT.ApplyUiOptions() end)

    CreateSlider("DCT_RowHeight", "ROW_HEIGHT", "ROW_HEIGHT_TIP", DCT.DEFAULT_CONFIG.ui.rowHeight, 26, 48, 1,
        function() return DCT.GetUiConfig().rowHeight end,
        function(value) DCT.GetUiConfig().rowHeight = value; DCT.ApplyUiOptions() end)

    CreateSlider("DCT_UiScale", "UI_SCALE", "UI_SCALE_TIP", DCT.DEFAULT_CONFIG.ui.scale, 0.7, 1.5, 0.05,
        function() return DCT.GetUiConfig().scale end,
        function(value) DCT.GetUiConfig().scale = value; DCT.ApplyUiOptions() end,
        function(value) return string.format("%.2f", value) end)

    appearanceLayout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L("SETTINGS_COLORS")))

    local function CreateColor(variableName, labelKey, colorKey)
        local setting = Settings.RegisterProxySetting(
            appearanceSubcategory,
            variableName,
            Settings.VarType.String,
            L(labelKey),
            DCT.DEFAULT_CONFIG.ui.colors[colorKey],
            function() return DCT.GetUiConfig().colors[colorKey] end,
            function(value)
                DCT.GetUiConfig().colors[colorKey] = value
                DCT.ApplyUiOptions()
            end
        )
        Settings.CreateColorSwatch(appearanceSubcategory, setting, L("COLOR_TIP"))
    end

    CreateColor("DCT_ColorPending", "COLOR_PENDING", "pending")
    CreateColor("DCT_ColorActive", "COLOR_ACTIVE", "active")
    CreateColor("DCT_ColorReady", "COLOR_READY", "ready")
    CreateColor("DCT_ColorCompleted", "COLOR_COMPLETED", "completed")

    howToUseLayout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L("CREATOR_TITLE")))
    howToUseLayout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L("CREATOR_BODY")))
    howToUseLayout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L("CREATOR_CREDITS")))
    howToUseLayout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L("HELP_HEADER")))
    howToUseLayout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L("HELP_OPEN")))
    howToUseLayout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L("HELP_SETTINGS")))
    howToUseLayout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L("HELP_COMBAT")))
    howToUseLayout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L("HELP_AUTOHIDE")))
    howToUseLayout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L("HELP_SHOW")))
end
