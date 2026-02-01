local _, ns = ...
local Slider = gUI:NewModule("Slider")
local Utils = gUI:GetModule("Utils")

---------------------------------------------------------------------
-- ESTÉTICA (INTERNO)
---------------------------------------------------------------------
local function ApplyStyle(frame)
    -- Botón Atrás
    frame.Back:SetSize(11, 18)
    frame.Back.tex = frame.Back:CreateTexture(nil, "BACKGROUND")
    frame.Back.tex:SetAtlas("Minimal_SliderBar_Button_Left", true)
    frame.Back.tex:SetAllPoints()

    -- Botón Adelante
    frame.Forward:SetSize(9, 18)
    frame.Forward.tex = frame.Forward:CreateTexture(nil, "BACKGROUND")
    frame.Forward.tex:SetAtlas("Minimal_SliderBar_Button_Right", true)
    frame.Forward.tex:SetAllPoints()
end

---------------------------------------------------------------------
-- FORMATEO DE TEXTO (INTERNO)
---------------------------------------------------------------------
local function UpdateValueText(frame, value, unit)
    local text = ""
    if unit == "%" then
        text = string.format("%.0f%%", value * 100)
    else
        text = string.format("%.1f%s", value, unit or "")
    end
    frame.ValueText:SetText(text)
end

---------------------------------------------------------------------
-- EVENTOS (INTERNO)
---------------------------------------------------------------------
local function BindEvents(frame, onUpdate, tooltip, label, settings)
    local s = frame.Widget
    local step = settings.step or 0.1

    -- Cambio de valor
    s:SetScript("OnValueChanged", function(self, value)
        local rounded = tonumber(string.format("%.2f", value))
        UpdateValueText(frame, rounded, settings.unit)
        if onUpdate then onUpdate(self, rounded) end
    end)

    -- Botones de paso fino
    frame.Back:SetScript("OnClick", function() s:SetValue(s:GetValue() - step) end)
    frame.Forward:SetScript("OnClick", function() s:SetValue(s:GetValue() + step) end)

    -- Tooltip
    if tooltip then
        frame:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(label, 1, 1, 1)
            GameTooltip:AddLine(tooltip, nil, nil, nil, true)
            GameTooltip:Show()
        end)
        frame:SetScript("OnLeave", GameTooltip_Hide)
    end
end

---------------------------------------------------------------------
-- CONSTRUCTOR
---------------------------------------------------------------------
function Slider:Create(parent, label, onUpdate, tooltip, settings)
    settings = settings or { min = 0, max = 1, step = 0.1, default = 0.5, unit = "" }

    -- Contenedor maestro
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(280, 42) -- Un poco más alto para que respire el texto

    -- Label Superior
    frame.Label = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.Label:SetPoint("TOPLEFT", 5, 0)
    frame.Label:SetText(label)

    -- Slider (Widget)
    local s = CreateFrame("Slider", nil, frame, "MinimalSliderTemplate")
    s:SetPoint("TOPLEFT", 20, -18)
    s:SetPoint("TOPRIGHT", -45, -18)
    s:SetMinMaxValues(settings.min, settings.max)
    s:SetValueStep(settings.step)
    s:SetObeyStepOnDrag(true)
    s:SetValue(settings.default)
    frame.Widget = s

    -- Botones y Texto de Valor
    frame.Back = CreateFrame("Button", nil, frame)
    frame.Back:SetPoint("RIGHT", s, "LEFT", -5, 0)

    frame.Forward = CreateFrame("Button", nil, frame)
    frame.Forward:SetPoint("LEFT", s, "RIGHT", 5, 0)

    frame.ValueText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.ValueText:SetPoint("LEFT", frame.Forward, "RIGHT", 5, 0)
    
    -- Inicializar
    ApplyStyle(frame)
    BindEvents(frame, onUpdate, tooltip, label, settings)
    UpdateValueText(frame, settings.default, settings.unit)

    -- API Pública
    function frame:SetEnabled(enabled)
        self:SetAlpha(enabled and 1 or 0.4)

        self.Widget:SetEnabled(enabled)
        self.Back:SetEnabled(enabled)
        self.Forward:SetEnabled(enabled)

        self:EnableMouse(enabled)
    end

    return frame
end
