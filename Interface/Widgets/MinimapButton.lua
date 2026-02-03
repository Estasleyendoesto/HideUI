local addonName, ns = ...
local MinimapButton = gUI:NewModule("MinimapButton")
local Database = gUI:GetModule("Database")

-- Constantes de configuración
local RADIUS    = 105
local ICON_PATH = [[Interface\AddOns\GhostUI\icon]]
local GUI_NAME  = "GhostUI"

---------------------------------------------------------------------
-- LÓGICA DE POSICIONAMIENTO
---------------------------------------------------------------------

-- Calcula la posición en el borde del minimapa basado en un ángulo (grados)
local function UpdatePosition(btn, angle)
    local rad = math.rad(angle)
    local x = math.cos(rad) * RADIUS
    local y = math.sin(rad) * RADIUS
    
    btn:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

---------------------------------------------------------------------
-- CICLO DE VIDA Y EVENTOS
---------------------------------------------------------------------

function MinimapButton:OnEnable()
    local db = Database:GetGlobals()
    
    -- 1. Crear el Frame Principal
    local btn = CreateFrame("Button", "gUIMinimapButton", Minimap)
    btn:SetSize(31, 31)
    btn:SetFrameLevel(10)
    btn:SetHighlightTexture([[Interface\Minimap\UI-Minimap-ZoomButton-Highlight]])
    
    -- Icono central
    btn.icon = btn:CreateTexture(nil, "BACKGROUND")
    btn.icon:SetTexture(ICON_PATH)
    btn.icon:SetSize(20, 20)
    btn.icon:SetPoint("CENTER", 0, 0)

    -- Borde clásico de Blizzard
    btn.border = btn:CreateTexture(nil, "OVERLAY")
    btn.border:SetTexture([[Interface\Minimap\MiniMap-TrackingBorder]])
    btn.border:SetSize(53, 53)
    btn.border:SetPoint("TOPLEFT", 0, 0)

    -- 2. Lógica de Arrastre (Drag)
    btn:RegisterForDrag("LeftButton")
    btn:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", function(s)
            local mx, my = GetCursorPosition()
            local cx, cy = Minimap:GetCenter()
            local scale  = Minimap:GetEffectiveScale()
            
            -- Calculamos el ángulo relativo al centro del minimapa
            local angle = math.deg(math.atan2(my/scale - cy, mx/scale - cx))
            UpdatePosition(s, angle)
            
            -- Guardamos en DB para persistencia
            Database:UpdateGlobal("minimapAngle", angle)
        end)
    end)

    btn:SetScript("OnDragStop", function(self) 
        self:SetScript("OnUpdate", nil) 
    end)

    -- 3. Interacción (Click y Tooltip)
    btn:RegisterForClicks("AnyUp")
    btn:SetScript("OnClick", function(_, button)
        if button == "LeftButton" then
            gUI:GetModule("MainFrame"):Toggle()
        end
    end)

    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine(GUI_NAME)
        GameTooltip:AddLine("|cff00ff00Click|r para abrir opciones", 1, 1, 1)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", GameTooltip_Hide)

    -- 4. Inicialización
    self.button = btn
    UpdatePosition(btn, db.minimapAngle or 45)
    self:SetVisibility(not db.hideMinimapButton)
end

---------------------------------------------------------------------
-- API PÚBLICA
---------------------------------------------------------------------

-- Control de visibilidad (usado por el panel de opciones)
function MinimapButton:SetVisibility(show)
    if self.button then self.button:SetShown(show) end
end

-- Actualización dinámica de icono
function MinimapButton:SetIcon(path)
    if self.button and self.button.icon then
        self.button.icon:SetTexture(path or ICON_PATH)
    end
end