local _, ns = ...
local CheckboxSlider = HideUI:NewModule("CheckboxSlider")
local Utils = HideUI:GetModule("Utils")

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
        sliderControl:SetButtonState(isChecked)
        
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
    local Checkbox = HideUI:GetModule("Checkbox")
    local Slider   = HideUI:GetModule("Slider")

    -- Contenedor Maestro
    local root = CreateFrame("Frame", nil, parent)
    root:SetSize(280, 55)

    -- 2. Checkbox
    local cb = Checkbox:Create(root, label, nil, tooltip, settings.cbDefault)
    cb:SetPoint("TOPLEFT", 0, 0)

    -- 3. Slider
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

    -- 4. Unión de piezas
    BindComboEvents(cb, slider, onUpdate)

    -- Inicialización de estado visual
    slider:SetButtonState(settings.cbDefault)

    -- 5. API Pública
    root.Checkbox = cb
    root.Slider   = slider

    function root:SetButtonState(enabled)
        self:SetAlpha(enabled and 1 or 0.4)
        self.Checkbox:SetButtonState(enabled)
        
        -- Lógica en cascada: el slider solo se activa si el root está activo Y el checkbox marcado
        local shouldEnableSlider = enabled and self.Checkbox.Checkbox:GetChecked()
        self.Slider:SetButtonState(shouldEnableSlider)
    end

    return root
end