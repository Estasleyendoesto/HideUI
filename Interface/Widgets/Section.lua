local _, ns = ...
local Section = gUI:NewModule("Section")
local Utils = gUI:GetModule("Utils")

function Section:Create(parent, title, layout)
    local config = Utils:GetLayout(layout, {
        padding = { x = 10, y = 10 },
        spacing = 10, -- Espacio entre widgets
        titleSpacing = 15 -- Espacio entre el título y el content
    })

    -- Contenedor maestro
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(1, 1)

    -- Título de la sección
    if title then
        frame.Title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        frame.Title:SetPoint("TOPLEFT", frame, "TOPLEFT", config.padding.left - 12, -config.padding.top)
        frame.Title:SetText(title:upper())
        frame.Title:SetAlpha(0.5)
        frame.titleHeight = 12
    else
        frame.titleHeight = 0
    end

    -- Contenedor de Widgets
    local content = CreateFrame("Frame", nil, frame)
    local headerHeight = config.padding.top + (title and (frame.titleHeight + config.titleSpacing) or 0)
    content:SetPoint("TOPLEFT", frame, "TOPLEFT", config.padding.left, -headerHeight)
    content:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -config.padding.right, -headerHeight)

    -- El padding del content de los widgets no se us
    local internalLayout = Utils:GetLayout(layout)
    internalLayout.padding.left = 0
    internalLayout.padding.right = 0
    internalLayout.padding.top = 0
    internalLayout.padding.bottom = 0

    frame.Content = content
    frame.Content.layoutConfig = internalLayout
    frame.layoutConfig = config

    -- API
    function frame:Refresh()
        Utils:VStack(self.Content)

        local widgetsHeight = self.Content:GetHeight()
        local headerArea = self.layoutConfig.padding.top + (title and (self.titleHeight + self.layoutConfig.titleSpacing) or 0)
        
        -- Altura total real: Superior + Widgets + Inferior
        self:SetHeight(widgetsHeight + headerArea + self.layoutConfig.padding.bottom)
    end

    return frame
end
