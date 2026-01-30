local _, ns = ...
local Navbar = HideUI:NewModule("Navbar")
local Utils = HideUI:GetModule("Utils")

-- Configuración visual fija
local CFG = {
    HEIGHT = 30,
    TOP    = -32,
    LEFT   = 15,
    RIGHT  = -15,
    PADDING = 5,
    SPACING = 7
}

---------------------------------------------------------------------
-- CREACIÓN DEL NAV
---------------------------------------------------------------------
function Navbar:Create(parent)
    local nav = CreateFrame("Frame", nil, parent)
    nav:SetHeight(CFG.HEIGHT)
    nav:SetPoint("TOPLEFT", parent, "TOPLEFT", CFG.LEFT, CFG.TOP)
    nav:SetPoint("TOPRIGHT", parent, "TOPRIGHT", CFG.RIGHT, CFG.TOP)

    -- Registro para que HStack sepa qué hacer
    Utils:RegisterLayout(nav, {
        padding = CFG.PADDING,
        spacing = CFG.SPACING
    })
    
    -- Lista interna para gestionar estados de botones
    nav.buttons = {}
    
    return nav
end

---------------------------------------------------------------------
-- GESTIÓN DE BOTONES
---------------------------------------------------------------------
function Navbar:AddButton(navbar, text, onClick, isActive)
    local Button = HideUI:GetModule("Button")
    
    local btn = Button:CreateModern(navbar, text, function(self)
        Navbar:SetActiveButton(navbar, self)
        if onClick then onClick(self) end
    end)

    table.insert(navbar.buttons, btn)

    -- Si este botón es el activo por defecto, lo aplicamos ya
    if isActive then
        btn:Disable()
        btn:SetAlpha(1)
    else
        btn:Enable()
        btn:SetAlpha(0.7)
    end

    return btn
end

---------------------------------------------------------------------
-- ESTADOS VISUALES
---------------------------------------------------------------------
-- Resalta el botón activo y deshabilita visualmente los demás
function Navbar:SetActiveButton(navbar, activeBtn)
    for _, btn in ipairs(navbar.buttons) do
        if btn == activeBtn then
            btn:Disable() -- Blizzard template: Desactivado suele verse "presionado" o gris claro
            btn:SetAlpha(1)
        else
            btn:Enable()
            btn:SetAlpha(0.7) -- Un poco de transparencia a los no activos
        end
    end
end