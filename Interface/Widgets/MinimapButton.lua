local addonName, ns = ...
local MinimapButton = gUI:NewModule("MinimapButton")
local Database = gUI:GetModule("Database")

-- Constantes para fácil ajuste
local RADIUS = 105 -- Distancia al centro del minimapa
-- local ICON_PATH = "Interface\\Icons\\INV_Misc_Eye_01"
local ICON_PATH = "Interface\\AddOns\\gUI\\icon"
local GUI_NAME = "GhostUI"

---------------------------------------------------------------------
-- LÓGICA DE POSICIONAMIENTO (INTERNA)
---------------------------------------------------------------------
local function UpdatePosition(btn, angle)
    -- Ajustamos el radio dependiendo de si el minimapa es circular o cuadrado (opcional)
    local x = math.cos(math.rad(angle)) * RADIUS
    local y = math.sin(math.rad(angle)) * RADIUS
    
    btn:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

---------------------------------------------------------------------
-- MÉTODOS DEL MÓDULO
---------------------------------------------------------------------

function MinimapButton:OnEnable()
    local db = Database:GetGlobals()
    
    -- Frame principal
    local btn = CreateFrame("Button", "gUIMinimapButton", Minimap)
    btn:SetSize(31, 31)
    btn:SetFrameLevel(10)
    btn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    
    -- Capas visuales (Icono y Borde)
    btn.icon = btn:CreateTexture(nil, "BACKGROUND")
    btn.icon:SetTexture(ICON_PATH)
    btn.icon:SetSize(20, 20)
    btn.icon:SetPoint("CENTER", 0, 0)

    btn.border = btn:CreateTexture(nil, "OVERLAY")
    btn.border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    btn.border:SetSize(53, 53)
    btn.border:SetPoint("TOPLEFT", 0, 0)

    -- Scripts de Arrastre (Drag)
    btn:RegisterForDrag("LeftButton")
    btn:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", function(s)
            local x, y = GetCursorPosition()
            local cx, cy = Minimap:GetCenter()
            local scale = Minimap:GetEffectiveScale()
            
            -- Calculamos el ángulo basado en la posición del ratón
            local angle = math.deg(math.atan2(y/scale - cy, x/scale - cx))
            UpdatePosition(s, angle)
            Database:UpdateGlobal("minimapAngle", angle)
        end)
    end)

    btn:SetScript("OnDragStop", function(self) 
        self:SetScript("OnUpdate", nil) 
    end)

    -- Script de Click
    btn:RegisterForClicks("AnyUp")
    btn:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
            gUI:GetModule("MainFrame"):Toggle()
        end
    end)

    -- Tooltip
    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine(GUI_NAME)
        GameTooltip:AddLine("|cff00ff00Click|r to open the options", 1, 1, 1)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", GameTooltip_Hide)

    -- Guardar referencia e inicializar
    self.button = btn
    UpdatePosition(btn, db.minimapAngle or 45)
    
    -- Aplicar estado de visibilidad inicial
    self:SetVisibility(not db.hideMinimapButton)
end

---------------------------------------------------------------------
-- MÉTODOS DE CONTROL (Para usar desde el panel de opciones)
---------------------------------------------------------------------

-- Muestra u oculta el botón
function MinimapButton:SetVisibility(show)
    if not self.button then return end
    self.button:SetShown(show)
end

-- Permite cambiar el icono si en el futuro quieres añadir estados (ej. activado/desactivado)
function MinimapButton:SetIcon(path)
    if self.button and self.button.icon then
        self.button.icon:SetTexture(path or ICON_PATH)
    end
end
