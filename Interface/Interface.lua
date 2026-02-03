local _, ns = ...
local Interface = gUI:NewModule("Interface", "AceEvent-3.0")
Interface:SetDefaultModuleState(false)

-- Lista de paneles registrados en el sistema
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
    -- 1. Activar componentes base de la interfaz
    gUI:EnableModule("MinimapButton")
    gUI:EnableModule("MainFrame")

    -- 2. Activar los paneles de configuración
    for name in pairs(self.panels) do
        gUI:EnableModule(name)
    end

    -- 3. Escuchar cambios globales (activar/desactivar addon)
    self:RegisterMessage("GHOSTUI_GLOBAL_CHANGED", "OnGlobalChange")
end

---------------------------------------------------------------------
-- CONTROL DE FLUJO
---------------------------------------------------------------------

function Interface:OnGlobalChange(_, field, value)
    if field == "addonEnabled" then
        local MainFrame = gUI:GetModule("MainFrame")
        
        -- Actualizamos el estado visual de la NavBar y el Header actual
        MainFrame:UpdateUIVisuals(value)
        
        -- Si el usuario desactiva el addon, forzamos el panel "General"
        -- para que el botón de reactivación siempre esté disponible.
        if value == false and MainFrame.currentPanel ~= "General" then
            MainFrame:OpenPanel("General")
        end
    end
end

-- Determina el panel de inicio al abrir la ventana (OnShow del MainFrame)
function Interface:SetupInitialPanel()
    local Database = gUI:GetModule("Database")
    local MainFrame = gUI:GetModule("MainFrame")
    
    local addonEnabled = Database:GetGlobals().addonEnabled
    
    -- Si el addon está activo, mostramos "About" (presentación).
    -- Si está inactivo, mandamos a "General" para que lo active.
    local target = addonEnabled and "About" or "General"

    MainFrame:OpenPanel(target)
end