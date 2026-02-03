local _, ns = ...
local Section = gUI:NewModule("Section")
local Utils = gUI:GetModule("Utils")

---------------------------------------------------------------------
-- MÉTODOS INTERNOS
---------------------------------------------------------------------

-- Calcula el espacio vertical que ocupa la cabecera de la sección
local function GetHeaderHeight(frame, config)
    if not frame.Title then return config.padding.top end
    return config.padding.top + frame.titleHeight + config.titleSpacing
end

---------------------------------------------------------------------
-- CONSTRUCTOR
---------------------------------------------------------------------

function Section:Create(parent, title, layout)
    local config = Utils:GetLayout(layout, {
        padding = { x = 10, y = 10 },
        spacing = 10,      -- Espacio entre widgets internos
        titleSpacing = 15  -- Espacio entre título y primer widget
    })

    -- Contenedor Maestro (invisible, sirve para el VStack del padre)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(1, 1)

    -- 1. Título de la Sección
    if title then
        local fs = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        fs:SetPoint("TOPLEFT", frame, "TOPLEFT", config.padding.left - 12, -config.padding.top)
        fs:SetText(title:upper())
        fs:SetAlpha(0.5)
        
        frame.Title = fs
        frame.titleHeight = 12
    else
        frame.titleHeight = 0
    end

    -- 2. Contenedor de Widgets (Lienzo interno)
    local content = CreateFrame("Frame", nil, frame)
    local headerH = GetHeaderHeight(frame, config)
    
    content:SetPoint("TOPLEFT", frame, "TOPLEFT", config.padding.left, -headerH)
    content:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -config.padding.right, -headerH)

    -- 3. Configuración interna (Anulamos padding para que los widgets usen el del Section)
    local internalLayout = Utils:GetLayout(layout)
    internalLayout.padding = { top = 0, bottom = 0, left = 0, right = 0 }

    frame.Content = content
    frame.Content.layoutConfig = internalLayout
    frame.layoutConfig = config

    -- API de Actualización
    function frame:Refresh()
        -- Organiza los widgets hijos
        Utils:VStack(self.Content)

        -- Ajusta la altura del Section para que el padre sepa cuánto ocupa
        local widgetsH = self.Content:GetHeight()
        local headerArea = GetHeaderHeight(self, self.layoutConfig)
        
        self:SetHeight(widgetsH + headerArea + self.layoutConfig.padding.bottom)
    end

    return frame
end