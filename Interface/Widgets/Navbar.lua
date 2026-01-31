local _, ns = ...
local Navbar = HideUI:NewModule("Navbar")
local Utils = HideUI:GetModule("Utils")

local CFG = {
    HEIGHT = 30,
    TOP    = -32,
    LEFT   = 15,
    RIGHT  = -15,
    PADDING = 5,
    SPACING = 7
}

---------------------------------------------------------------------
-- LÓGICA VISUA
---------------------------------------------------------------------
-- Esta función decide el estado de UN botón basándose en el contexto global
local function RefreshButtonState(navbar, btn)
    local isEnabled = (navbar.isEnabled ~= false)
    local isActive  = (navbar.activeBtn == btn)
    local isGeneral = (btn:GetText() == "General")

    if isActive then
        btn:Disable()
        btn:SetAlpha(1)
        return
    end

    if not isEnabled and not isGeneral then
        btn:Disable()
        btn:SetAlpha(0.3)
    else
        btn:Enable()
        btn:SetAlpha(0.7)
    end
end

local function UpdateAllButtons(navbar)
    for _, btn in ipairs(navbar.buttons) do
        RefreshButtonState(navbar, btn)
    end
end

---------------------------------------------------------------------
-- API PÚBLICA
---------------------------------------------------------------------
function Navbar:Create(parent)
    local nav = CreateFrame("Frame", nil, parent)
    nav:SetHeight(CFG.HEIGHT)
    Utils:RegisterLayout(nav, { padding = CFG.PADDING, spacing = CFG.SPACING })
    
    nav.buttons = {}
    nav.isEnabled = true -- Estado por defecto
    return nav
end

function Navbar:AddButton(navbar, text, onClick, isActive)
    local Button = HideUI:GetModule("Button")
    local btn = Button:CreateModern(navbar, text, function(self)
        self:GetParent().activeBtn = self -- Actualizamos referencia en el nav
        UpdateAllButtons(self:GetParent())
        if onClick then onClick(self) end
    end)

    table.insert(navbar.buttons, btn)
    if isActive then navbar.activeBtn = btn end
    
    RefreshButtonState(navbar, btn)
    return btn
end

function Navbar:SetEnabled(navbar, isEnabled)
    navbar.isEnabled = isEnabled
    UpdateAllButtons(navbar)
end

function Navbar:SetActiveButton(navbar, activeBtn)
    navbar.activeBtn = activeBtn
    UpdateAllButtons(navbar)
end

function Navbar:Refresh(nav, alignment)
    nav.customAlign = {
        alignment = (alignment or "CENTER"):upper(),
        x = (alignment == "RIGHT" and CFG.RIGHT) or (alignment == "LEFT" and CFG.LEFT) or 0
    }
    Utils:HStack(nav)
    Utils:VStack(nav:GetParent())
end