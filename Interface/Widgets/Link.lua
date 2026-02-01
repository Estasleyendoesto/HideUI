local _, ns = ...
local Link = HideUI:NewModule("Link")
local Utils = HideUI:GetModule("Utils")

-- Scripts compartidos
local function OnEditFocusGained(self) self:HighlightText() end
local function OnEditFocusLost(self) self:HighlightText(0, 0) end
local function OnMouseDown(self) self:SetFocus() end

function Link:Create(parent, label, url, layout)
    local config = Utils:GetLayout(layout, {
        height = 20,
        width = 250, 
        padding = { left = 15, right = 15 }
    })

    local f = CreateFrame("Frame", nil, parent)
    f:SetHeight(config.height)

    -- EditBox: Solo motor de texto
    local eb = CreateFrame("EditBox", nil, f)
    eb:SetSize(config.width, config.height)
    eb:SetPoint("RIGHT", -config.padding.right, 0)
    eb:SetFontObject("ChatFontNormal")
    eb:SetJustifyH("RIGHT")
    eb:SetText(url)
    eb:SetAutoFocus(false)
    eb:SetTextColor(0.5, 0.7, 1) -- Blanco azulado tipo link

    -- Etiqueta
    f.Label = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f.Label:SetPoint("LEFT", config.padding.left, 0)
    f.Label:SetText(label)

    -- Lógica de Interacción y Protección
    eb:SetScript("OnEditFocusGained", OnEditFocusGained)
    eb:SetScript("OnEditFocusLost", OnEditFocusLost)
    eb:SetScript("OnMouseDown", OnMouseDown)
    eb:SetScript("OnTextChanged", function(self, userInput)
        if userInput then 
            self:SetText(url) 
            self:HighlightText() 
        end
    end)

    f.EditBox = eb
    return f
end