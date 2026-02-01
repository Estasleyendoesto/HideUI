local _, ns = ...
local CheckboxSlider = gUI:NewModule("CheckboxSlider")
local Utils = gUI:GetModule("Utils")

---------------------------------------------------------------------
-- COMPORTAMIENTO (INTERNO)
---------------------------------------------------------------------
local function BindComboEvents(cbControl, sliderControl, onUpdate)
    -- Referencia al CheckButton real
    local cb = cbControl.Checkbox

    -- Hook al OnClick del checkbox
    cb:HookScript("OnClick", function(self)
        local isChecked = self:GetChecked()
        
        -- El slider se habilita/deshabilita según el checkbox
        sliderControl:SetEnabled(isChecked)
        
        -- Callback general: (checked, sliderValue)
        if onUpdate then 
            onUpdate(isChecked, sliderControl.Widget:GetValue()) 
        end
    end)
end

---------------------------------------------------------------------
-- CONSTRUCTOR
---------------------------------------------------------------------
function CheckboxSlider:Create(parent, label, onUpdate, tooltip, settings)
    local Checkbox = gUI:GetModule("Checkbox")
    local Slider   = gUI:GetModule("Slider")

    -- Contenedor Maestro
    local root = CreateFrame("Frame", nil, parent)
    root:SetSize(280, 55)

    -- Checkbox
    local cb = Checkbox:Create(root, label, nil, tooltip, settings.cbDefault)
    cb:SetPoint("TOPLEFT", 0, 0)

    -- Slider
    local sliderSettings = {
        min     = settings.min or 0,
        max     = settings.max or 1,
        step    = settings.step or 0.1,
        default = settings.sliderDefault or 0.5,
        unit    = settings.unit or ""
    }
    
    -- Creamos el slider como hijo del root
    local slider = Slider:Create(root, "", function(self, value)
        if onUpdate then onUpdate(cb.Checkbox:GetChecked(), value) end
    end, nil, sliderSettings)
    
    -- Posicionamiento del slider
    slider:SetPoint("TOPLEFT", cb, "BOTTOMLEFT", 38, 18)
    slider:SetPoint("TOPRIGHT", 0, 18)
    slider.Label:Hide()

    -- Unión de piezas
    BindComboEvents(cb, slider, onUpdate)

    -- Inicialización de estado visual
    slider:SetEnabled(settings.cbDefault)

    -- API Pública
    root.Checkbox = cb
    root.Slider   = slider

    function root:SetEnabled(enabled)
        self:SetAlpha(enabled and 1 or 0.4)
        self.Checkbox:SetEnabled(enabled)

        local shouldEnableSlider = enabled and self.Checkbox.Checkbox:GetChecked()
        self.Slider:SetEnabled(shouldEnableSlider)

        self:EnableMouse(enabled)
    end

    return root
end
