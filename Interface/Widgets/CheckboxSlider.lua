local _, ns = ...
local CheckboxSlider = gUI:NewModule("CheckboxSlider")

---------------------------------------------------------------------
-- COMPORTAMIENTO (INTERNO)
---------------------------------------------------------------------

local function BindComboEvents(cbControl, sliderControl, onUpdate)
    local cb = cbControl.Checkbox

    -- Vinculamos el estado del slider al valor del checkbox
    cb:HookScript("OnClick", function(self)
        local isChecked = self:GetChecked()
        
        -- El slider se habilita/deshabilita dinámicamente
        sliderControl:SetEnabled(isChecked)
        
        -- Ejecutamos el callback pasando ambos valores
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

    -- 1. Checkbox (Elemento Maestro)
    local cb = Checkbox:Create(root, label, nil, tooltip, settings.cbDefault)
    cb:SetPoint("TOPLEFT", 0, 0)

    -- 2. Configuración del Slider (Elemento Esclavo)
    local sliderSettings = {
        min     = settings.min or 0,
        max     = settings.max or 1,
        step    = settings.step or 0.1,
        default = settings.sliderDefault or 0.5,
        unit    = settings.unit or ""
    }
    
    -- El callback del slider también debe informar del estado del checkbox
    local slider = Slider:Create(root, "", function(_, value)
        if onUpdate then onUpdate(cb.Checkbox:GetChecked(), value) end
    end, nil, sliderSettings)
    
    -- Posicionamiento relativo al Checkbox
    -- Ocultamos su label para usar el del Checkbox y ahorrar espacio
    slider:SetPoint("TOPLEFT", cb, "BOTTOMLEFT", 38, 18)
    slider:SetPoint("TOPRIGHT", 0, 18)
    slider.Label:Hide()

    -- 3. Unión de piezas y lógica de dependencia
    BindComboEvents(cb, slider, onUpdate)

    -- Estado inicial: el slider nace según esté el checkbox
    slider:SetEnabled(settings.cbDefault)

    -- API Pública
    root.Checkbox = cb
    root.Slider   = slider

    function root:SetEnabled(enabled)
        self:SetAlpha(enabled and 1 or 0.4)
        self.Checkbox:SetEnabled(enabled)

        -- Lógica de cascada: el slider solo se activa si el root Y el checkbox lo permiten
        local shouldEnableSlider = enabled and self.Checkbox.Checkbox:GetChecked()
        self.Slider:SetEnabled(shouldEnableSlider)

        self:EnableMouse(enabled)
    end

    return root
end