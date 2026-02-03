local _, ns = ...
local Interface = gUI:NewModule("Interface", "AceEvent-3.0")

local PANELS = { "About", "General", "Blizzard", "Others" }

---------------------------------------------------------------------
-- INICIALIZACIÓN
---------------------------------------------------------------------
function Interface:OnInitialize()
    self.panels = {}
    for _, name in ipairs(PANELS) do
        local module = gUI:GetModule(name, true)
        if module then
            self.panels[name] = module
        end
    end
end

function Interface:OnEnable()
    -- componentes visuales base
    gUI:EnableModule("MinimapButton")
    gUI:EnableModule("MainFrame")

    -- Paneles
    for name in pairs(self.panels) do
        gUI:EnableModule(name)
    end

    self:RegisterMessage("GHOSTUI_GLOBAL_CHANGED", "OnGlobalChange")
end

---------------------------------------------------------------------
-- Control de UI
---------------------------------------------------------------------
function Interface:OnGlobalChange(_, field, value)
    if field == "addonEnabled" then
        local MainFrame = gUI:GetModule("MainFrame")
        
        -- Atualizamos visuales (NavBar, Header, etc)
        MainFrame:UpdateUIVisuals(value)
        
        -- Si apagamos el addon, mandamos a General
        if value == false and MainFrame.currentPanel ~= "General" then
            MainFrame:OpenPanel("General")
        end
    end
end

-- Determina qué panel mostrar al abrir la ventana por primera vez
function Interface:SetupInitialPanel()
    local Database = gUI:GetModule("Database")
    local MainFrame = gUI:GetModule("MainFrame")
    
    local addonEnabled = Database:GetGlobals().addonEnabled
    local target = addonEnabled and "About" or "General"

    MainFrame:OpenPanel(target)
end
