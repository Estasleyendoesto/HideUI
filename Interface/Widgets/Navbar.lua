local _, ns = ...
local Navbar = gUI:NewModule("Navbar")
local Utils  = gUI:GetModule("Utils")

local CFG = {
    HEIGHT  = 30,
    PADDING = 5,
    SPACING = 7
}

---------------------------------------------------------------------
-- LÓGICA VISUAL (INTERNO)
---------------------------------------------------------------------

-- Gestiona el estado visual y funcional de cada botón según el contexto
local function RefreshButtonState(navbar, btn)
    local isEnabled = navbar.isEnabled
    local isActive  = (navbar.activeBtn == btn)
    local isGeneral = (btn:GetText() == "General")

    -- 1. Si el botón es el activo, se deshabilita para evitar clics redundantes
    if isActive then
        btn:Disable()
        btn:SetAlpha(1)
        return
    end

    -- 2. Si el sistema está desactivado, solo el botón "General" permanece habilitado
    if not isEnabled and not isGeneral then
        btn:Disable()
        btn:SetAlpha(0.3)
    else
        btn:Enable()
        btn:SetAlpha(0.7)
    end
end

local function UpdateAllButtons(navbar)
    if not navbar.buttons then return end
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
    
    nav.buttons   = {}
    nav.isEnabled = true -- Estado inicial por defecto
    return nav
end

function Navbar:AddButton(navbar, text, onClick, isActive)
    local Button = gUI:GetModule("Button")

    -- Usamos el estilo moderno para la navegación
    local btn = Button:CreateModern(navbar, text, function(self)
        navbar.activeBtn = self
        UpdateAllButtons(navbar)
        if onClick then onClick(self) end
    end)

    table.insert(navbar.buttons, btn)
    if isActive then navbar.activeBtn = btn end
    
    RefreshButtonState(navbar, btn)
    return btn
end

-- Bloquea o desbloquea el acceso a otros paneles (excepto General)
function Navbar:SetEnabled(navbar, isEnabled)
    navbar.isEnabled = isEnabled
    UpdateAllButtons(navbar)
end

function Navbar:SetActiveButton(navbar, activeBtn)
    navbar.activeBtn = activeBtn
    UpdateAllButtons(navbar)
end

-- Ajusta la posición de los botones y refresca el layout del padre
function Navbar:Refresh(nav, alignment, xOffset)
    local align = (alignment or "CENTER"):upper()
    
    -- Calculamos el offset según la alineación
    local x = 0
    if align == "RIGHT" then x = xOffset or 0
    elseif align == "LEFT" then x = -(xOffset or 0) end

    nav.customAlign = {
        alignment = align,
        x = x
    }

    Utils:HStack(nav) -- Organiza botones horizontalmente
    Utils:VStack(nav:GetParent()) -- Re-apila el contenedor padre si es necesario
end