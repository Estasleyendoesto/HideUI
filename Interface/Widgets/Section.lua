local _, ns = ...
local Section = HideUI:NewModule("Section")
local Utils = HideUI:GetModule("Utils")

function Section:Create(parent, title, layout)
    local config = Utils:GetLayout(layout, {
        left = 72,
        right = -48,
        padding = 10,
        spacing = 10,
    })

    -- Contenedor maestro
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(1, 1)

    -- Título de la sección
    if title then
        frame.Title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        frame.Title:SetPoint("TOPLEFT", config.left + -12, 0)
        frame.Title:SetText(title:upper())
        frame.Title:SetAlpha(0.5)
    end

    -- Contenedor de Widgets
    local content = CreateFrame("Frame", nil, frame)
    content:SetPoint("TOPLEFT", frame, "TOPLEFT", config.left, title and -15 or 5)
    content:SetPoint("TOPRIGHT", frame, "TOPRIGHT", config.right, title and -15 or 5)

    -- Registro interno
    frame.Content = content
    frame.Content.layoutConfig = config

    -- Método Refresh
    function frame:Refresh()
        -- Apila los widgets internos
        Utils:VStack(self.Content)
        -- Actualiza altura del frame
        local h = self.Content:GetHeight()
        self:SetHeight(h + (title and 20 or 0))
    end

    return frame
end