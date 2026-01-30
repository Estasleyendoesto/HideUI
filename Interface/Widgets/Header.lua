local _, ns = ...
local Header = HideUI:NewModule("Header")
local Utils = HideUI:GetModule("Utils")

---------------------------------------------------------------------
-- CONSTRUCTOR DEL HEADER
---------------------------------------------------------------------
function Header:Create(parent, title, onDefaults, layout)
    local config = Utils:GetLayout(layout, {
        height  = 50,
        left    = 40,
        right   = -30,
        buttonW = 96,
        buttonH = 22
    })

    -- 1. Contenedor Principal
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetHeight(config.height)
    frame:SetPoint("TOPLEFT", 0, -35)
    frame:SetPoint("TOPRIGHT", 0, -35)

    -- 2. Título
    frame.Title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightHuge")
    frame.Title:SetPoint("LEFT", config.left, 0)
    frame.Title:SetJustifyH("LEFT")
    frame.Title:SetText(title)

    -- 3. Botón "Defaults"
    local btn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    btn:SetSize(config.buttonW, config.buttonH)
    btn:SetPoint("RIGHT", config.right, 0)
    btn:SetText(DEFAULTS or "Defaults") -- Soporte opcional para localización
    
    if onDefaults then
        btn:SetScript("OnClick", onDefaults)
    end
    frame.DefaultsButton = btn

    -- 4. Separador (Divider)
    local divider = frame:CreateTexture(nil, "ARTWORK")
    divider:SetAtlas("Options_HorizontalDivider", true)
    divider:SetPoint("BOTTOMLEFT")
    divider:SetPoint("BOTTOMRIGHT")
    divider:SetAlpha(0.4)
    frame.Divider = divider

    -- 5. Métodos Públicos
    -- Nota: Usamos nombres que no pisen los métodos nativos de Blizzard
    function frame:SetButtonState(enabled)
        if enabled then
            self.DefaultsButton:Enable()
        else
            self.DefaultsButton:Disable()
        end
    end

    return frame
end