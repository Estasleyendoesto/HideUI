local _, ns = ...
local Checkbox = HideUI:NewModule("Checkbox")
local Utils = HideUI:GetModule("Utils")

---------------------------------------------------------------------
-- ESTÉTICA (INTERNO)
---------------------------------------------------------------------
local function ApplyStyle(cb)
    -- Texturas Minimalistas (Settings Panel Style)
    cb:SetNormalTexture("checkbox-minimal")
    cb:GetNormalTexture():SetAtlas("checkbox-minimal")
    
    cb:SetPushedTexture("checkbox-minimal")
    cb:GetPushedTexture():SetAtlas("checkbox-minimal")
    
    cb:SetCheckedTexture("checkmark-minimal")
    cb:GetCheckedTexture():SetAtlas("checkmark-minimal")
    
    cb:SetDisabledCheckedTexture("checkmark-minimal-disabled")
    cb:GetDisabledCheckedTexture():SetAtlas("checkmark-minimal-disabled")

    -- Highlight (Hover)
    local hl = cb:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAtlas("checkbox-minimal")
    hl:SetAlpha(0.2)
    cb:SetHighlightTexture(hl)
end

---------------------------------------------------------------------
-- EVENTOS Y TOOLTIP (INTERNO)
---------------------------------------------------------------------
local function BindEvents(frame, cb, label, onUpdate, tooltip)
    -- Click handler
    cb:SetScript("OnClick", function(self)
        if onUpdate then onUpdate(self, self:GetChecked()) end
    end)

    -- Tooltip handler
    if tooltip then
        frame:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(label, 1, 1, 1)
            GameTooltip:AddLine(tooltip, nil, nil, nil, true)
            GameTooltip:Show()
        end)
        frame:SetScript("OnLeave", GameTooltip_Hide)
    end
end

---------------------------------------------------------------------
-- CONSTRUCTOR
---------------------------------------------------------------------
function Checkbox:Create(parent, label, onUpdate, tooltip, default)
    -- Condenedor maestro
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(280, 29)


    -- El Widget (CheckButton)
    local cb = CreateFrame("CheckButton", nil, frame, "BackdropTemplate")
    cb:SetSize(30, 29)
    cb:SetPoint("LEFT", 0, 0)
    cb:SetChecked(default or false)
    
    ApplyStyle(cb)

    -- Label
    frame.Text = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.Text:SetPoint("LEFT", cb, "RIGHT", 10, 0)
    frame.Text:SetText(label)

    -- Unión de Lógica
    BindEvents(frame, cb, label, onUpdate, tooltip)

    -- API Pública
    frame.Checkbox = cb
    
    function frame:SetEnabled(enabled)
        self:SetAlpha(enabled and 1 or 0.4)
        self.Checkbox:SetEnabled(enabled)
        self:EnableMouse(enabled)
    end

    return frame
end