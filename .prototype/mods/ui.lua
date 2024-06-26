local UI_mod = HideUI:NewModule("UI_mod")
local DB_mod
local Core_mod

local frame_names = { "PlayerFrame", "TargetFrame", "FocusFrame", "PetFrame", "PetActionBar", "MinimapCluster", "ObjectiveTrackerFrame",
    "BuffFrame", "MicroMenuContainer", "BagsBar", "MainMenuBar", "BattlefieldMapFrame", "MultiBarBottomLeft", "MultiBarBottomRight",
    "MultiBarRight", "MultiBarLeft", "Multibar5", "Multibar6", "Multibar7", "PlayerCastingBarFrame", "MainStatusTrackingBarContainer",
    "EncounterBar", "StanceBar", "Chatbox",
}

function UI_mod:OnInitialize()
    DB_mod = HideUI:GetModule("DB_mod")
    Core_mod = HideUI:GetModule("Core_mod")
end

function UI_mod:OnEnable()
    self:LoadUI()
    self:UpdateUI()
end

function UI_mod:UpdateUI()
    -- Options Subpanel
    self.OptionsPanel.isEnabled:SetChecked(DB_mod:Find("isEnabled"))
    self.OptionsPanel.globalOpacity:SetValue(DB_mod:Find("globalOpacity"))
    self.OptionsPanel.isMouseover:SetChecked(DB_mod:Find("isMouseover"))
    self.OptionsPanel.mouseoverFadeIn:SetValue(DB_mod:Find("mouseoverFadeIn"))
    self.OptionsPanel.mouseoverFadeOut:SetValue(DB_mod:Find("mouseoverFadeOut"))
    self.OptionsPanel.isCombat:SetChecked(DB_mod:Find("isCombat"))
    self.OptionsPanel.isAFK:SetChecked(DB_mod:Find("isAFK"))
    
    --Individual Subpanel
    local frames_dic = DB_mod:Find("frames")
    for _, frame_name in ipairs(frame_names) do
        local frame_db = frames_dic[frame_name]
        self.IndividualOptionsPanel[frame_name .. "_enabledAlpha"]:SetChecked(frame_db.withAlpha)
        self.IndividualOptionsPanel[frame_name .. "_alphaAmount"]:SetValue(frame_db.alpha)
        -- self.IndividualOptionsPanel[frame_name .. "_inCombat"]:SetChecked(frame_db.combatEnable)
    end
end

-- ADDON UI Menus and Submenus
----------------------------------------------------------------------------
function UI_mod:CreateMenu(name)
    local parent = InterfaceOptionsFramePanelContainer
    local panel = CreateFrame("Frame", "HideUI" .. name .. "Panel", parent)
    panel.name = name
    panel.type = "Panel"
    InterfaceOptions_AddCategory(panel)

    return panel
end

function UI_mod:CreateOptionsMenu(name)
    local parent = self.menuPanel
    local panel = CreateFrame("Frame", "HideUI" .. name .. "Panel", parent)
    panel.name = name
    panel.type = "Panel"
    panel.parent = parent.name

    InterfaceOptions_AddCategory(panel)
    OptionsMenuPanel_Build(panel)

    return panel
end

function UI_mod:CreateIndividualOptionsMenu(name)
    local parent = self.menuPanel
    local panel = CreateFrame("Frame", "HideUI" .. name .. "Panel", parent)
    panel.name = name
    panel.type = "Panel"
    panel.parent = parent.name

    InterfaceOptions_AddCategory(panel)
    IndividualMenuPanel_Build(panel)

    return panel
end

function UI_mod:LoadUI()
    self.menuPanel = UI_mod:CreateMenu("HideUI")
    self.OptionsPanel = UI_mod:CreateOptionsMenu("Options")
    self.IndividualOptionsPanel = UI_mod:CreateIndividualOptionsMenu("Individual")
end

-- BUILDER
----------------------------------------------------------------------------
function OptionsMenuPanel_Build(panel)
    UI_mod:CreateScrollBox("scroll", panel, true)
    UI_mod:CreateHeader("header", "Options")

    --General Settings
    UI_mod:CreateTitle("title", "General Settings")
    UI_mod:CreateCheckbox("isEnabled", "Activate", true, function(checked) 
        Core_mod:OnActiveToggle(checked)
    end)
    UI_mod:CreateSlider("globalOpacity", "Overall Transparency", 0, 1, 0.5, 0.01, function(amount)
        Core_mod:UpdateGlobalTransparency(amount)
    end)

    --Mouseover Settings
    UI_mod:CreateTitle("titleMouseover", "Mouseover Settings")
    UI_mod:CreateCheckbox("isMouseover", "Show on Mouseover", true, function(checked)
        Core_mod:OnMouseoverToggle(checked)
    end)
    UI_mod:CreateSlider("mouseoverFadeIn", "Fade In Duration", 0, 5, 0.5, 0.1, function(amount)
        Core_mod:UpdateMouseoverFadeInAmount(amount)
    end)
    UI_mod:CreateSlider("mouseoverFadeOut", "Fade Out Duration", 0, 5, 0.5, 0.1, function(amount)
        Core_mod:UpdateMouseoverFadeOutAmount(amount)
    end)

    --Combat Settings
    UI_mod:CreateTitle("titleCombat", "Combat Settings")
    UI_mod:CreateCheckbox("isCombat", "Show During Combat", false, function(checked) 
        Core_mod:OnCombatToggle(checked)
    end)

    --AFK Settings
    UI_mod:CreateTitle("titleAFK", "AFK Settings")
    UI_mod:CreateCheckbox("isAFK", "AFK Mode", false, function(checked) 
        Core_mod:OnAFKToggle(checked)
    end)
end

function IndividualMenuPanel_Build(panel)
    UI_mod:CreateScrollBox("scroll", panel, true)
    UI_mod:CreateHeader("header", "Individual Options")

    for _, frame_name in ipairs(frame_names) do
        -- UI_mod:CreateTitle("title", frame_name)
        UI_mod:CreateCheckbox(frame_name .. "_enabledAlpha", frame_name .. " alpha", true, function(checked)
            Core_mod:OnFrameEnableAlpha(checked, frame_name)
        end)
        UI_mod:CreateSlider(frame_name .. "_alphaAmount", frame_name .. " alpha amount", 0, 1, 0.5, 0.01, function(amount)
            Core_mod:UpdateFrameAlphaAmount(amount, frame_name)
        end)
        -- UI_mod:CreateCheckbox(frame_name .. "_inCombat", "Enable in Combat", true, function(checked)
        --     Core_mod:OnFrameEnableCombat(checked, frame_name)
        -- end)
    end
end

-- AmigableUI
----------------------------------------------------------------------------
function UI_mod:CreateScrollBox(name, panel, isBarVisible)
    --Es lo primero a crear al usar un panel
    local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT")
    scrollFrame:SetPoint("BOTTOMRIGHT", -28, 8)
    
    if isBarVisible then
        scrollFrame.ScrollBar:Show()
    else
        scrollFrame.ScrollBar:Hide()
    end
    
    local scrollContainer = CreateFrame("Frame")
    scrollFrame:SetScrollChild(scrollContainer)
    scrollContainer:SetWidth(1)     -- 1 = ancho auto
    scrollContainer:SetHeight(1)    -- 1 = alto auto

    scrollContainer.panel = panel
    scrollContainer.type = "Scroll"
    self.lastElement = scrollContainer
    panel[name] = scrollContainer
end

function UI_mod:CreateHeader(name, text)
    --Solo hay un header por panel, y siempre uno después del scroll
    local parent = self.lastElement

    -- Title
    local title = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    title:SetPoint("TOPLEFT", parent, "TOPLEFT", 12,-26)
    title:SetText(text)

    --Separator
    local separator = parent:CreateTexture(nil, "BACKGROUND")
    separator:SetColorTexture(0.8, 0.8, 0.8, 0.3)
    separator:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -10)
    separator:SetHeight(1)
    separator:SetWidth(9999) --No queda de otra

    title.type = "Title"
    separator.type = "Separator"
    title.parent = parent
    separator.parent = parent
    parent["header_title"] = title
    parent["Header_separator"] = separator
    parent[name] = separator
    self.lastElement = separator
end

function UI_mod:CreateTitle(name, text)
    local before = self.lastElement
    local parent = before.parent

    local title = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("LEFT", parent, "LEFT")
    title:SetPoint("TOPLEFT", before, "BOTTOMLEFT", 0, -25)
    title:SetText(text)

    title.type = "Title"
    title.parent = parent
    self.lastElement = title
    parent.panel[name] = title
end

function UI_mod:CreateCheckbox(name, text, state, func)
    local before = self.lastElement
    local parent = before.parent

    local margin_top = -12
    if before.type == "Checkbox" then
        margin_top = 0
    end

    -- Box
    local checkbox = CreateFrame("CheckButton", "HideUICheckbox", parent, "UICheckButtonTemplate")
    checkbox:SetPoint("LEFT", parent, "LEFT")
    checkbox:SetPoint("TOPLEFT", before, "BOTTOMLEFT", 0, margin_top)

    -- Text
    checkbox.text:SetPoint("TOPLEFT", checkbox, "TOPLEFT", 48, -8.5)
    checkbox.text:SetText(text)
    checkbox.text:SetFont("Fonts\\FRIZQT__.TTF", 12.5)
    checkbox.text:SetTextColor(1, 1, 1, 0.8)
    checkbox:SetChecked(state or false) --SetChecked() para UpdateUI o RestoreUI
    --Attach event
    checkbox:SetScript("OnClick", function(self)
        if func then
            func(self:GetChecked())
        end
    end)

    checkbox.type = "Checkbox"
    checkbox.parent = parent
    parent.panel[name] = checkbox
    self.lastElement = checkbox
end

function UI_mod:CreateSlider(name, text, min, max, default, step, func)
    local before = self.lastElement
    local parent = before.parent
    max = max or 100
    min = min or 0
    default = default or (min + max) / 2
    step = step or 1

    local margin_top = -32
    if before.type == "Title" then
        margin_top = -42
    end

    local slider = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
    slider:SetOrientation("HORIZONTAL")
    slider:SetWidth(340)    -- Ancho del slider
    slider:SetHeight(20)    -- Alto...

    slider:SetPoint("LEFT", parent, "LEFT")
    slider:SetPoint("TOPLEFT", before, "BOTTOMLEFT", 0, margin_top)

    slider:SetMinMaxValues(min, max)
    slider:SetValueStep(step)
    slider:SetValue(default) --Invocar para restoreUI

    slider.Low:Hide() --Esconde low/high
    slider.High:Hide()

    --Stilize text
    slider.title = slider:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    slider.title:SetPoint("BOTTOMLEFT", slider, "TOPLEFT", 0, 7)
    slider.title:SetText(text)

    --Stilize text (max)
    slider.highText = slider:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    slider.highText:SetPoint("LEFT", slider, "RIGHT", 10, 0)
    slider.highText:SetText(max)

    --Stilize text (slider value)
    slider.valueText = slider:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    slider.valueText:SetPoint("TOP", slider, "BOTTOM", 0, -2)

    --Attach event
    slider:SetScript("OnValueChanged", function(self, amount)
        if step % 1 == 0 then
            self.valueText:SetText(format("%.0f", amount))
        else
            self.valueText:SetText(format("%.2f", amount))
        end
        if func then
            func(amount)
        end
    end)

    slider.type = "Slider"
    slider.parent = parent
    parent.panel[name] = slider
    self.lastElement = slider
end