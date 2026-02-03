local _, ns = ...
local Separator = gUI:NewModule("Separator")
local Utils = gUI:GetModule("Utils")

---------------------------------------------------------------------
-- CONSTRUCTOR
---------------------------------------------------------------------

function Separator:Create(parent, layout)
    -- Configuración por defecto para una línea sutil
    local config = Utils:GetLayout(layout, {
        height    = 12,
        left      = 15,
        right     = -15,
        opacity   = 0.4,
        thickness = 1,
    })

    -- Contenedor (Define el espacio que ocupa en el VStack)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetHeight(config.height)

    -- Textura de la línea (Usando el divisor estándar de Blizzard)
    local line = frame:CreateTexture(nil, "ARTWORK")
    line:SetAtlas("Options_HorizontalDivider", true)
    
    -- Ajuste de dimensiones y posición
    line:SetHeight(config.thickness)
    line:SetPoint("LEFT", config.left, 0)
    line:SetPoint("RIGHT", config.right, 0)
    line:SetPoint("CENTER", 0, 0)
    line:SetAlpha(config.opacity)
    
    frame.Line = line

    -- API de compatibilidad para el Builder (No realiza acción)
    function frame:SetButtonState() end

    return frame
end