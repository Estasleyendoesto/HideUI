local _, ns = ...
local Separator = HideUI:NewModule("Separator")
local Utils = HideUI:GetModule("Utils")

---------------------------------------------------------------------
-- CONSTRUCTOR
---------------------------------------------------------------------
function Separator:Create(parent, layout)
    local config = Utils:GetLayout(layout, {
        height    = 12,
        left      = 15,
        right     = -15,
        opacity   = 0.4,
        thickness = 1,
    })

    -- Contenedor
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetHeight(config.height)

    -- Textura de la línea
    local line = frame:CreateTexture(nil, "ARTWORK")
    line:SetAtlas("Options_HorizontalDivider", true)
    
    -- Ajustamos altura (thickness) y puntos laterales
    line:SetHeight(config.thickness)
    line:SetPoint("LEFT", config.left, 0)
    line:SetPoint("RIGHT", config.right, 0)
    line:SetPoint("CENTER", 0, 0)
    line:SetAlpha(config.opacity)
    
    frame.Line = line

    function frame:SetButtonState() end

    return frame
end