local _, ns = ...

local Header = HideUI:NewModule("Header")
local Utils = HideUI:GetModule("Utils")

---------------------------------------------------------------------
-- CONSTRUCTOR DEL HEADER
---------------------------------------------------------------------
function Header:Create(parent, title, onDefaults, layout)
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

    -- Título
    frame.Title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightHuge")
    frame.Title:SetPoint("LEFT", config.left, 0)
    frame.Title:SetJustifyH("LEFT")
    frame.Title:SetText(title)

    -- Botón "Defaults"
    local btn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    btn:SetSize(config.buttonW, config.buttonH)
    btn:SetPoint("RIGHT", config.right, 0)
    btn:SetText(DEFAULTS or "Defaults")
    
    if onDefaults then
        btn:SetScript("OnClick", onDefaults)
    end
    frame.DefaultsButton = btn

    -- Separador (Divider)
    local divider = frame:CreateTexture(nil, "ARTWORK")
    divider:SetAtlas("Options_HorizontalDivider", true)
    divider:SetPoint("BOTTOMLEFT", 10, 0)
    divider:SetPoint("BOTTOMRIGHT", -10, 0)
    divider:SetAlpha(0.4)
    frame.Divider = divider

    -- API
    function frame:SetEnabled(enabled)
        self.DefaultsButton:SetEnabled(enabled)
        self.DefaultsButton:SetAlpha(enabled and 1 or 0.5)
    end

    return frame
end