local UI_mod = HideUI:NewModule("UI_mod")
local Core_mod

function UI_mod:OnInitialize()
    Core_mod = HideUI:GetModule("Core_mod")
    self:RestoreUI()
    self.lastElement = nil
end

function UI_mod:OnEnable()
    self.menuPanel = UI_mod:CreateMenu("HideUI")
    self.OptionsPanel = UI_mod:CreateOptionsMenu("Options")
    self:UpdateUI() --Actualiza los parámetros desde la BD
end

function UI_mod:RestoreUI()
    --Este método únicamente recupera los cambios que afectan a los frames del juego
    --Desde los parámetros almacenanos en la BD al iniciar sesión
    if self.db.profile.isEnabled then
        Core_mod:UpdateFramesOpacity(
            Core_mod:GetNormalFrames(),
            self.db.profile.globalOpacity
        )
    end
end

function UI_mod:UpdateUI()
    -- Global Settings
    self.OptionsPanel.isEnabled:SetChecked(self.db.profile.isEnabled)
    self.OptionsPanel.globalOpacity:SetValue(self.db.profile.globalOpacity)
end

-- BUILDER
----------------------------------------------------------------------------
local function OptionsMenuPanel_Build(panel)
    panel.header           = UI_mod:CreateHeader("Options", panel)
    
    panel.titleGeneral     = UI_mod:CreateTitle("General Settings")
    panel.isEnabled        = UI_mod:CreateCheckbox("Activate", true, function(checked)
        Core_mod:OnActiveToggle(checked)
    end)
    panel.globalOpacity    = UI_mod:CreateSlider("Overall Transparency", 0, 100, 50, function(amount)
        Core_mod:UpdateGlobalTransparency(amount)
    end)

    panel.titleMouseover   = UI_mod:CreateTitle("Mouseover Settings")
    panel.isMouseover      = UI_mod:CreateCheckbox("Show on Mouseover", true)
    panel.mouseoverIsFade  = UI_mod:CreateCheckbox("Enable Fade Effect", true)
    panel.mouseoverFadeIn  = UI_mod:CreateSlider("Fade In Duration")
    panel.mouseoverFadeOut = UI_mod:CreateSlider("Fade Out Duration")

    panel.titleCombat      = UI_mod:CreateTitle("Combat Settings")
    panel.isCombat         = UI_mod:CreateCheckbox("Show During Combat", false)
    panel.combatIsFade     = UI_mod:CreateCheckbox("Enable Combat Fade", false)
    panel.combatFadeIn     = UI_mod:CreateSlider("Combat Fade In Duration")
    panel.combatFadeOut    = UI_mod:CreateSlider("Combat Fade Out Duration")
end

local function GetPanel(frame)
    local panel = nil
    if frame.type == "Panel" then
        panel = frame
    else
        panel = frame.panel
    end
    return panel
end

-- ADDON Menus and Submenus
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

-- AmigableUI
----------------------------------------------------------------------------
-- TITLE Frame
function UI_mod:CreateTitle(text)
    local to = self.lastElement
    local panel = GetPanel(to)
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("LEFT", panel, "LEFT", 12, 0)
    title:SetPoint("TOP", to, "BOTTOM", 0, -20)
    title:SetText(text)

    title.panel = panel
    title.type = "Title"
    title.text = text

    self.lastElement = title
    return title
end

-- HEADER Frame
function UI_mod:CreateHeader(text, panel)
    --Title
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    title:SetPoint("TOPLEFT", panel, "TOPLEFT", 12,-26)
    title:SetText(text)

    --Separator
    local separator = panel:CreateTexture(nil, "BACKGROUND")
    separator:SetColorTexture(0.8, 0.8, 0.8, 0.3)
    separator:SetPoint("TOPLEFT", panel, "TOPLEFT", 6, 0)
    separator:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -10)
    separator:SetPoint("RIGHT", panel, "RIGHT", -26, 0)
    separator:SetHeight(1)

    title.panel = panel
    separator.panel = panel
    self.lastElement = separator
    return {
        panel = panel,
        type = "Header",
        text = text,
        title = title,
        separator = separator,
        next = separator,
    }
end

-- CHECKBOX Frame
function UI_mod:CreateCheckbox(text, state, func)
    local to = self.lastElement
    local panel = GetPanel(to)
    local margin_top = -12

    if to.type == "Checkbox" then
        margin_top = 0 -- Impide que checkbox juntos no estén muy separados
    end

    local checkbox = CreateFrame("CheckButton", "HideUICheckbox", panel, "UICheckButtonTemplate")
    checkbox:SetPoint("LEFT", panel, "LEFT", 18, 0)
    checkbox:SetPoint("TOP", to, "BOTTOM", 0, margin_top)

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

    checkbox.panel = panel
    checkbox.type = "Checkbox"

    self.lastElement = checkbox
    return checkbox
end

-- SLIDER Frame
function UI_mod:CreateSlider(text, min, max, default, func)
    local to = self.lastElement
    local panel = GetPanel(to)
    max = max or 100
    min = min or 0
    default = default or (min + max) / 2

    local slider = CreateFrame("Slider", nil, panel, "OptionsSliderTemplate")
    slider:SetOrientation("HORIZONTAL")
    slider:SetWidth(340)    -- Ancho del slider
    slider:SetHeight(20)    -- Alto...
    slider:SetPoint("LEFT", panel, "LEFT", 23, 0)
    slider:SetPoint("TOP", to, "BOTTOM", 0, -26)
    slider:SetMinMaxValues(min, max)
    slider:SetValueStep(1)
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
        self.valueText:SetText(format("%.0f", amount)) --Live update of slider value
        if func then
            func(amount)
        end
    end)

    slider.panel = panel
    slider.type = "Slider"

    self.lastElement = slider
    return slider
end