local _, ns = ...
local Header = gUI:NewModule("Header")
local Utils  = gUI:GetModule("Utils")

---------------------------------------------------------------------
-- CONSTRUCTOR
---------------------------------------------------------------------

function Header:Create(parent, title, onDefaults, layout)
    -- Configuración de dimensiones y offsets
    local config = Utils:GetLayout(layout, {
        height  = 50,
        left    = 35,
        right   = -30,
        buttonW = 96,
        buttonH = 22
    })

    -- Contenedor Principal
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetHeight(config.height)
    frame:SetPoint("TOPLEFT")
    frame:SetPoint("TOPRIGHT")

    -- 1. Título del Panel
    frame.Title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightHuge")
    frame.Title:SetPoint("LEFT", config.left, 0)
    frame.Title:SetJustifyH("LEFT")
    frame.Title:SetText(title)

    -- 2. Botón de Restaurar (Defaults)
    local btn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    btn:SetSize(config.buttonW, config.buttonH)
    btn:SetPoint("RIGHT", config.right, 0)
    btn:SetText("Defaults") -- Cambiado a string literal para evitar nils
    
    if onDefaults then
        btn:SetScript("OnClick", onDefaults)
    end
    frame.DefaultsButton = btn

    -- 3. Separador Horizontal (Estilo Blizzard)
    local divider = frame:CreateTexture(nil, "ARTWORK")
    divider:SetAtlas("Options_HorizontalDivider", true)
    divider:SetPoint("BOTTOMLEFT", 10, 0)
    divider:SetPoint("BOTTOMRIGHT", -10, 0)
    divider:SetAlpha(0.4)
    frame.Divider = divider

    -- API Pública
    function frame:SetEnabled(enabled)
        self.DefaultsButton:SetEnabled(enabled)
        self.DefaultsButton:SetAlpha(enabled and 1 or 0.5)
    end

    return frame
end